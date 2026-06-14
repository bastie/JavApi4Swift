/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A modal or non-modal dialog window with Swing's root-pane architecture.
  ///
  /// `JDialog` extends `java.awt.Dialog` and adds the same `JRootPane`
  /// hierarchy as `JFrame`:
  ///
  /// ```
  /// JDialog  (native OS dialog window)
  ///   └── JRootPane
  ///         ├── glassPane    (invisible overlay)
  ///         └── layeredPane  (JLayeredPane)
  ///               └── contentPane  (JPanel, BorderLayout)  ← add widgets here
  /// ```
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let dialog = javax.swing.JDialog(owner: frame, title: "Settings", modal: true)
  /// dialog.setSize(400, 300)
  ///
  /// let label = javax.swing.JLabel("Hello from JDialog!")
  /// dialog.add(label)   // delegates to content pane
  ///
  /// dialog.setVisible(true)   // blocks if modal
  /// ```
  ///
  /// ## defaultCloseOperation
  ///
  /// | Constant | Value | Behaviour |
  /// |---|---|---|
  /// | `DO_NOTHING_ON_CLOSE` | 0 | Nothing |
  /// | `HIDE_ON_CLOSE` | 1 | `setVisible(false)` (default) |
  /// | `DISPOSE_ON_CLOSE` | 2 | Dispose and release resources |
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// java.awt.Component
  ///   └── java.awt.Container
  ///         └── java.awt.Window
  ///               └── java.awt.Dialog
  ///                     └── javax.swing.JDialog   ← this class
  /// ```
  ///
  @MainActor
  open class JDialog: java.awt.Dialog, javax.swing.RootPaneContainer {

    // -------------------------------------------------------------------------
    // MARK: DefaultCloseOperation constants
    // -------------------------------------------------------------------------

    public static let DO_NOTHING_ON_CLOSE: Int = 0
    public static let HIDE_ON_CLOSE:       Int = 1
    public static let DISPOSE_ON_CLOSE:    Int = 2

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    public var defaultCloseOperation: Int = HIDE_ON_CLOSE

    // -------------------------------------------------------------------------
    // MARK: Root pane
    // -------------------------------------------------------------------------

    private let rootPane: javax.swing.JRootPane = javax.swing.JRootPane()

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a dialog owned by `owner` with the given title and modality.
    public init(owner: java.awt.Frame? = nil,
                title: String = "",
                modal: Bool = false) {
      super.init(owner ?? java.awt.Frame(), title, modal)
      super.add(rootPane)
    }

    /// Convenience: positional title first (matches Java API style).
    public convenience init(_ title: String, owner: java.awt.Frame? = nil, modal: Bool = false) {
      self.init(owner: owner, title: title, modal: modal)
    }

    // -------------------------------------------------------------------------
    // MARK: Layout
    // -------------------------------------------------------------------------

    /// Fills the root pane to the full dialog bounds, then lets JRootPane
    /// distribute space to contentPane etc.
    /// Does NOT call super.doLayout() to avoid FlowLayout interference.
    override public func doLayout() {
      rootPane.bounds = java.awt.Rectangle(0, 0, bounds.width, bounds.height)
      rootPane.validate()
    }

    // -------------------------------------------------------------------------
    // MARK: RootPaneContainer
    // -------------------------------------------------------------------------

    public func getRootPane() -> javax.swing.JRootPane { rootPane }

    public func getContentPane() -> java.awt.Container {
      rootPane.getContentPane()
    }
    public func setContentPane(_ contentPane: java.awt.Container) {
      rootPane.setContentPane(contentPane)
    }

    public func getGlassPane() -> java.awt.Component {
      rootPane.getGlassPane()
    }
    public func setGlassPane(_ glassPane: java.awt.Component) {
      rootPane.setGlassPane(glassPane)
    }

    public func getLayeredPane() -> javax.swing.JLayeredPane {
      rootPane.getLayeredPane()
    }
    public func setLayeredPane(_ layeredPane: javax.swing.JLayeredPane) {
      rootPane.setLayeredPane(layeredPane)
    }

    // -------------------------------------------------------------------------
    // MARK: Delegate add() / remove() to content pane
    // -------------------------------------------------------------------------

    override public func add(_ comp: java.awt.Component) {
      getContentPane().add(comp)
    }
    override public func add(_ comp: java.awt.Component, _ constraint: String) {
      getContentPane().add(comp, constraint)
    }
    override public func add(_ comp: java.awt.Component, _ constraints: AnyObject?) {
      getContentPane().add(comp, constraints)
    }
    override public func remove(_ comp: java.awt.Component) {
      getContentPane().remove(comp)
    }

    // -------------------------------------------------------------------------
    // MARK: Close handling
    // -------------------------------------------------------------------------

    public func getDefaultCloseOperation() -> Int { defaultCloseOperation }
    public func setDefaultCloseOperation(_ op: Int) { defaultCloseOperation = op }

    /// Processes WINDOW_CLOSING according to `defaultCloseOperation`.
    override open func processWindowEvent(_ e: java.awt.event.WindowEvent) {
      super.processWindowEvent(e)   // fires registered WindowListeners + disposes if !_disposing
      // super (java.awt.Dialog) already calls dispose() on WINDOW_CLOSING,
      // so we only need to handle HIDE here.
      if e.getID() == java.awt.event.WindowEvent.WINDOW_CLOSING {
        switch defaultCloseOperation {
        case JDialog.DO_NOTHING_ON_CLOSE:
          break   // super already notified listeners; stop here
        case JDialog.HIDE_ON_CLOSE:
          setVisible(false)
        default:  // DISPOSE_ON_CLOSE — super.processWindowEvent already called dispose()
          break
        }
      }
    }
  }
}
