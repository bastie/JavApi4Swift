/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Default implementation of `DesktopManager`.
  ///
  /// Provides standard MDI behaviour: frames are moved and resized by updating
  /// their bounds directly; iconification removes the frame from the desktop and
  /// adds its desktop icon instead; maximisation expands the frame to fill the
  /// desktop pane.
  ///
  /// All drawing is delegated to the component's UI delegate — this class only
  /// manages frame state and geometry.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultDesktopManager: DesktopManager, @unchecked Sendable {

    /// Stores the pre-maximise bounds so `minimizeFrame` can restore them.
    private var previousBounds: [ObjectIdentifier: java.awt.Rectangle] = [:]

    public init() {}

    // MARK: - DesktopManager

    open func openFrame(_ frame: JInternalFrame) {
      // Nothing extra required — the frame was added to the desktop pane by the caller.
    }

    open func closeFrame(_ frame: JInternalFrame) {
      frame.getParent()?.remove(frame)
      frame.getParent()?.repaint()
    }

    open func maximizeFrame(_ frame: JInternalFrame) {
      guard let desktop = frame.getParent() as? JDesktopPane else { return }
      // Save current bounds for later restore
      previousBounds[ObjectIdentifier(frame)] = frame.bounds
      setBoundsForFrame(frame, 0, 0, desktop.bounds.width, desktop.bounds.height)
      // Bring to front AFTER setting bounds so Z-order and bounds are consistent
      desktop.bringToFront(frame)
      desktop.repaint()
    }

    open func minimizeFrame(_ frame: JInternalFrame) {
      // Restore saved bounds if available
      if let saved = previousBounds.removeValue(forKey: ObjectIdentifier(frame)) {
        setBoundsForFrame(frame, saved.x, saved.y, saved.width, saved.height)
      }
    }

    open func iconifyFrame(_ frame: JInternalFrame) {
      guard let desktop = frame.getParent() as? JDesktopPane else { return }
      let icon = frame.getDesktopIcon()
      frame.setVisible(false)
      // Position icon at bottom-left, offset by number of existing icons
      let iconW = icon.bounds.width > 0  ? icon.bounds.width  : 160
      let iconH = icon.bounds.height > 0 ? icon.bounds.height : 40
      let existingIcons = desktop.getAllFrames()
        .filter { $0.isIcon() }
        .compactMap { $0.getDesktopIcon() }
        .filter { $0.parent != nil }
      let offsetX = existingIcons.count * (iconW + 4)
      let iconY = desktop.bounds.height - iconH - 4
      let iconX = 4 + offsetX
      icon.setBounds(iconX, Swift.max(0, iconY), iconW, iconH)
      desktop.add(icon)
      desktop.repaint()
    }

    open func deiconifyFrame(_ frame: JInternalFrame) {
      guard let desktop = frame.getParent() as? JDesktopPane else { return }
      let icon = frame.getDesktopIcon()
      desktop.remove(icon)
      frame.setVisible(true)
      activateFrame(frame)
    }

    open func activateFrame(_ frame: JInternalFrame) {
      // Find the desktop pane and update its selected frame
      if let desktop = frame.getParent() as? JDesktopPane {
        desktop.getSelectedFrame()?.setSelected(false)
        desktop.setSelectedFrame(frame)
      }
      frame.setSelected(true)
    }

    open func deactivateFrame(_ frame: JInternalFrame) {
      frame.setSelected(false)
      if let desktop = frame.getParent() as? JDesktopPane,
         desktop.getSelectedFrame() === frame {
        desktop.setSelectedFrame(nil)
      }
    }

    open func beginDraggingFrame(_ frame: JInternalFrame) {
      // Could start outline drawing here for OUTLINE_DRAG_MODE
    }

    open func dragFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int) {
      setBoundsForFrame(frame, newX, newY, frame.bounds.width, frame.bounds.height)
    }

    open func endDraggingFrame(_ frame: JInternalFrame) {
      // Finalise position; repaint to clean up any outline artefacts
      frame.getParent()?.repaint()
    }

    open func beginResizingFrame(_ frame: JInternalFrame, _ direction: Int) {}

    open func resizeFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int, _ newWidth: Int, _ newHeight: Int) {
      setBoundsForFrame(frame, newX, newY, newWidth, newHeight)
    }

    open func endResizingFrame(_ frame: JInternalFrame) {
      frame.getParent()?.repaint()
    }

    open func setBoundsForFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int, _ newWidth: Int, _ newHeight: Int) {
      frame.setBounds(newX, newY, newWidth, newHeight)
      frame.validate()
      frame.repaint()
    }
  }
}
