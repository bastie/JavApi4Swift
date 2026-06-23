/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A lightweight component that provides many of the features of a native
  /// frame, including dragging, closing, becoming an icon, resizing,
  /// title display, and support for a menu bar.
  ///
  /// `JInternalFrame` is used inside a `JDesktopPane` to implement
  /// multiple-document interface (MDI) applications.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let desktop = JDesktopPane()
  /// contentPane.add(desktop)
  ///
  /// let doc = JInternalFrame("Document 1", resizable: true, closable: true,
  ///                           maximizable: true, iconifiable: true)
  /// doc.setSize(400, 300)
  /// desktop.add(doc)
  /// doc.setVisible(true)
  /// ```
  ///
  /// All visual rendering is handled by the UI delegate
  /// (`BasicInternalFrameUI` by default).  `JInternalFrame` itself only
  /// manages state and fires events.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JInternalFrame: javax.swing.JComponent, @unchecked Sendable {

    // MARK: - Layer constants (mirror JLayeredPane for convenience)

    public static let CONTENT_LAYER: Int = JLayeredPane.DEFAULT_LAYER

    // MARK: - Properties

    private var title: String
    private var resizable: Bool
    private var closable: Bool
    private var maximizable: Bool
    private var iconifiable: Bool

    private var _isMaximum:  Bool = false
    private var _isIcon:     Bool = false
    private var _isSelected: Bool = false
    private var _isClosed:   Bool = false

    private var contentPane_: java.awt.Container
    private var desktopIcon_: JDesktopIcon

    private var internalFrameListeners: [javax.swing.event.InternalFrameListener] = []

    // MARK: - Init

    /// Creates a `JInternalFrame` with the given title and capabilities.
    ///
    /// - Parameters:
    ///   - title:        The string to display in the title bar.
    ///   - resizable:    `true` if the frame can be resized by the user.
    ///   - closable:     `true` if the frame has a close button.
    ///   - maximizable:  `true` if the frame has a maximise button.
    ///   - iconifiable:  `true` if the frame has an iconify button.
    public init(
      _ title: String = "",
      resizable: Bool = false,
      closable: Bool = false,
      maximizable: Bool = false,
      iconifiable: Bool = false
    ) {
      self.title        = title
      self.resizable    = resizable
      self.closable     = closable
      self.maximizable  = maximizable
      self.iconifiable  = iconifiable
      self.contentPane_ = JPanel(java.awt.BorderLayout())
      self.desktopIcon_ = JDesktopIcon(nil)   // placeholder; fixed below
      super.init()
      self.desktopIcon_ = JDesktopIcon(self)
      setLayout(nil)   // doLayout positions contentPane_ directly
      setOpaque(true)
      // Register contentPane_ as a child component
      super.add(contentPane_)
      updateUI()
    }

    /// Java-style positional initialiser (`JInternalFrame(title, resizable, closable, maximizable, iconifiable)`).
    public convenience init(
      _ title: String,
      _ resizable: Bool,
      _ closable: Bool,
      _ maximizable: Bool,
      _ iconifiable: Bool
    ) {
      self.init(title, resizable: resizable, closable: closable,
                maximizable: maximizable, iconifiable: iconifiable)
    }

    // MARK: - UI delegate

    override open func updateUI() {
      setUI(javax.swing.plaf.basic.BasicInternalFrameUI())
    }

    override open func getUIClassID() -> String { "InternalFrameUI" }

    // MARK: - Paint

    /// Positions the content pane below the title bar.
    override open func doLayout() {
      let tbH = javax.swing.plaf.basic.BasicInternalFrameUI.TITLE_BAR_HEIGHT
      let inset = 1
      let w = bounds.width  - inset * 2
      let h = bounds.height - tbH - inset * 2
      contentPane_.setBounds(inset, tbH + inset, Swift.max(0, w), Swift.max(0, h))
      contentPane_.doLayout()
    }

    // MARK: - Title

    public func getTitle() -> String { title }
    public func setTitle(_ t: String) { title = t; repaint() }

    // MARK: - Capabilities

    public func isResizable()   -> Bool { resizable   }
    public func isClosable()    -> Bool { closable     }
    public func isMaximizable() -> Bool { maximizable  }
    public func isIconifiable() -> Bool { iconifiable  }

    // MARK: - State

    public func isMaximum()  -> Bool { _isMaximum  }
    public func isIcon()     -> Bool { _isIcon     }
    public func isClosed()   -> Bool { _isClosed  }
    public func isSelected() -> Bool { _isSelected }

    /// Selects / deselects this frame (activates / deactivates the title bar).
    public func setSelected(_ selected: Bool) {
      guard _isSelected != selected else { return }
      _isSelected = selected
      repaint()
      let id = selected
        ? javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_ACTIVATED
        : javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_DEACTIVATED
      fireInternalFrameEvent(id)
    }

    // MARK: - Content pane

    public func getContentPane() -> java.awt.Container { contentPane_ }

    public func setContentPane(_ pane: java.awt.Container) {
      super.remove(contentPane_)
      contentPane_ = pane
      super.add(pane)
      doLayout()
    }

    // MARK: - Desktop icon

    public func getDesktopIcon() -> JDesktopIcon { desktopIcon_ }
    public func setDesktopIcon(_ icon: JDesktopIcon) { desktopIcon_ = icon }

    // MARK: - Open / close

    /// Makes the frame visible and fires `INTERNAL_FRAME_OPENED` on first show.
    public override func setVisible(_ visible: Bool) {
      let wasVisible = self.visible
      super.setVisible(visible)
      if visible && !wasVisible {
        fireInternalFrameEvent(javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_OPENED)
      }
    }

    /// Shows the frame — deprecated Java 1.0 API, use `setVisible(true)`.
    @available(*, deprecated, renamed: "setVisible(_:)")
    public override func show() {
      setVisible(true)
    }

    /// Closes the frame if it is closable.
    ///
    /// Fires `INTERNAL_FRAME_CLOSING` and then `INTERNAL_FRAME_CLOSED`.
    public override func dispose() {
      fireInternalFrameEvent(javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_CLOSING)
      _isClosed = true
      setVisible(false)
      getParent()?.remove(self)
      getParent()?.repaint()
      fireInternalFrameEvent(javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_CLOSED)
    }

    // MARK: - Iconify / deiconify

    public func setIcon(_ icon: Bool) {
      guard isIconifiable() else { return }
      guard _isIcon != icon else { return }
      _isIcon = icon
      let desktop = getParent() as? JDesktopPane
      if icon {
        desktop?.getDesktopManager().iconifyFrame(self)
        fireInternalFrameEvent(javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_ICONIFIED)
      } else {
        desktop?.getDesktopManager().deiconifyFrame(self)
        fireInternalFrameEvent(javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_DEICONIFIED)
      }
    }

    // MARK: - Maximise / restore

    public func setMaximum(_ max: Bool) {
      guard isMaximizable() else { return }
      guard _isMaximum != max else { return }
      _isMaximum = max
      let desktop = getParent() as? JDesktopPane
      if max {
        desktop?.getDesktopManager().maximizeFrame(self)
      } else {
        desktop?.getDesktopManager().minimizeFrame(self)
      }
    }

    // MARK: - Listeners

    public func addInternalFrameListener(_ l: javax.swing.event.InternalFrameListener) {
      internalFrameListeners.append(l)
    }

    public func removeInternalFrameListener(_ l: javax.swing.event.InternalFrameListener) {
      internalFrameListeners.removeAll { $0 === l }
    }

    public func getInternalFrameListeners() -> [javax.swing.event.InternalFrameListener] {
      internalFrameListeners
    }

    // MARK: - Event dispatch

    private func fireInternalFrameEvent(_ id: Int) {
      guard !internalFrameListeners.isEmpty else { return }
      let e = javax.swing.event.InternalFrameEvent(self, id)
      for l in internalFrameListeners {
        switch id {
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_OPENED:      l.internalFrameOpened(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_CLOSING:     l.internalFrameClosing(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_CLOSED:      l.internalFrameClosed(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_ICONIFIED:   l.internalFrameIconified(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_DEICONIFIED: l.internalFrameDeiconified(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_ACTIVATED:   l.internalFrameActivated(e)
        case javax.swing.event.InternalFrameEvent.INTERNAL_FRAME_DEACTIVATED: l.internalFrameDeactivated(e)
        default: break
        }
      }
    }

    // MARK: - JDesktopIcon (nested class)

    /// The iconified representation of a `JInternalFrame` inside a `JDesktopPane`.
    @MainActor
    public class JDesktopIcon: javax.swing.JComponent, @unchecked Sendable {

      private weak var internalFrame: JInternalFrame?

      public init(_ frame: JInternalFrame?) {
        self.internalFrame = frame
        super.init()
        setSize(160, 40)
        setOpaque(true)
      }

      public func getInternalFrame() -> JInternalFrame? { internalFrame }

      /// Paints a compact icon bar showing the frame title.
      override open func paintComponent(_ g: java.awt.Graphics) {
        let w = bounds.width
        let h = bounds.height
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(0, 0, w, h)
        g.setColor(java.awt.SystemColor.controlDkShadow)
        g.drawRect(0, 0, w - 1, h - 1)
        g.setColor(java.awt.SystemColor.controlText)
        let title = internalFrame?.getTitle() ?? ""
        let fm = java.awt.FontMetrics.make(for: font)
        let textY = (h - fm.getHeight()) / 2 + fm.getAscent()
        g.drawString(title, 6, textY)
      }
    }
  }
}
