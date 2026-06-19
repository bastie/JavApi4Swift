/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A container used to create a multiple-document interface (MDI) or a
  /// virtual desktop.
  ///
  /// `JDesktopPane` extends `JLayeredPane` and acts as the parent container for
  /// `JInternalFrame` instances.  It keeps track of all internal frames and
  /// provides methods to tile, cascade, or query them.
  ///
  /// ## Typical usage
  ///
  /// ```swift
  /// let desktop = JDesktopPane()
  /// frame.setContentPane(desktop)
  ///
  /// let internal = JInternalFrame("Document", true, true, true, true)
  /// internal.setSize(300, 200)
  /// desktop.add(internal)
  /// internal.setVisible(true)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JDesktopPane: javax.swing.JLayeredPane, @unchecked Sendable {

    // MARK: - Drag mode constants

    /// Components are continuously redrawn as the user drags an internal frame.
    public static let LIVE_DRAG_MODE: Int = 0

    /// Only the outline of the internal frame is drawn while dragging.
    public static let OUTLINE_DRAG_MODE: Int = 1

    // MARK: - State

    private var dragMode: Int = JDesktopPane.LIVE_DRAG_MODE
    private weak var selectedFrame: JInternalFrame? = nil
    private var desktopManager: DesktopManager? = nil

    // MARK: - Init

    public override init() {
      super.init()
      // JDesktopPane uses absolute positioning — frames manage their own bounds.
      setLayout(nil)
    }

    // MARK: - Drag mode

    /// Returns the current drag mode (`LIVE_DRAG_MODE` or `OUTLINE_DRAG_MODE`).
    public func getDragMode() -> Int { dragMode }

    /// Sets the drag mode used when moving or resizing internal frames.
    public func setDragMode(_ mode: Int) { dragMode = mode }

    // MARK: - Desktop manager

    /// Returns the `DesktopManager` that handles internal frame behaviour.
    /// A default `DefaultDesktopManager` is created lazily if none was set.
    public func getDesktopManager() -> DesktopManager {
      if let dm = desktopManager { return dm }
      let dm = DefaultDesktopManager()
      desktopManager = dm
      return dm
    }

    /// Replaces the desktop manager.
    public func setDesktopManager(_ dm: DesktopManager) {
      desktopManager = dm
    }

    // MARK: - Internal frame access

    /// Returns the currently active (selected) `JInternalFrame`, or `nil`.
    public func getSelectedFrame() -> JInternalFrame? { selectedFrame }

    /// Sets the currently active internal frame.
    public func setSelectedFrame(_ frame: JInternalFrame?) { selectedFrame = frame }

    /// Returns all `JInternalFrame` children in the given layer.
    ///
    /// - Parameter layer: One of `JLayeredPane`'s layer constants.
    public func getAllFramesInLayer(_ layer: Int) -> [JInternalFrame] {
      children.compactMap { $0 as? JInternalFrame }
             .filter { getLayer($0) == layer }
    }

    /// Returns all `JInternalFrame` children across all layers.
    public func getAllFrames() -> [JInternalFrame] {
      children.compactMap { $0 as? JInternalFrame }
    }

    // MARK: - Add helpers

    /// Adds an internal frame to the `DEFAULT_LAYER`.
    public func add(_ frame: JInternalFrame) {
      add(frame, layer: JLayeredPane.DEFAULT_LAYER)
    }

    // MARK: - Z-order

    /// Moves `frame` to the top of the paint order (drawn last = on top).
    public func bringToFront(_ frame: JInternalFrame) {
      guard let idx = children.firstIndex(where: { $0 === frame }) else { return }
      children.remove(at: idx)
      children.append(frame)
    }
  }
}
