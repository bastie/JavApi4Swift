/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A top-level window with a title bar and window decorations.
  ///
  /// `JFrame` is the standard top-level container for Swing applications.
  /// It extends `java.awt.Frame` (which provides the native title bar and
  /// close/minimise/maximise buttons via the OS window manager) and adds
  /// Swing's root-pane architecture.
  ///
  /// ## Quickstart
  ///
  /// ```swift
  /// let frame = javax.swing.JFrame("My Application")
  /// frame.setSize(800, 600)
  /// frame.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE)
  ///
  /// let label = javax.swing.JLabel("Hello, Swing!")
  /// frame.add(label)   // delegates to the content pane
  ///
  /// frame.setVisible(true)
  /// ```
  ///
  /// ## Root pane hierarchy
  ///
  /// ```
  /// JFrame  (native OS window with title bar)
  ///   └── JRootPane
  ///         ├── glassPane    (invisible overlay)
  ///         └── layeredPane  (JLayeredPane)
  ///               └── contentPane  (JPanel, BorderLayout)  ← add widgets here
  /// ```
  ///
  /// ## defaultCloseOperation
  ///
  /// Controls what happens when the user clicks the close button:
  ///
  /// | Constant | Value | Behaviour |
  /// |---|---|---|
  /// | `DO_NOTHING_ON_CLOSE` | 0 | Nothing — handle it in a `WindowListener` |
  /// | `HIDE_ON_CLOSE` | 1 | Hide the frame (`setVisible(false)`) |
  /// | `DISPOSE_ON_CLOSE` | 2 | Dispose the frame and release resources |
  /// | `EXIT_ON_CLOSE` | 3 | Terminate the application (`System.exit(0)`) |
  ///
  /// The default is `HIDE_ON_CLOSE`.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// java.awt.Component
  ///   └── java.awt.Container
  ///         └── java.awt.Window
  ///               └── java.awt.Frame
  ///                     └── javax.swing.JFrame   ← this class
  /// ```
  ///
  @MainActor
  open class JFrame: java.awt.Frame, javax.swing.RootPaneContainer {

    // -------------------------------------------------------------------------
    // MARK: DefaultCloseOperation constants
    // -------------------------------------------------------------------------

    /// Do nothing when the close button is clicked.
    /// The application must handle the event via a `WindowListener`.
    public static let DO_NOTHING_ON_CLOSE: Int = 0

    /// Hide the frame when the close button is clicked (`setVisible(false)`).
    /// This is the default.
    public static let HIDE_ON_CLOSE: Int = 1

    /// Dispose the frame when the close button is clicked.
    /// Releases all native resources; the JVM may exit if no other windows remain.
    public static let DISPOSE_ON_CLOSE: Int = 2

    /// Exit the application when the close button is clicked (`System.exit(0)`).
    public static let EXIT_ON_CLOSE: Int = 3

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    /// Controls what happens when the user closes this frame.
    /// Default: `HIDE_ON_CLOSE`.
    public var defaultCloseOperation: Int = HIDE_ON_CLOSE

    // -------------------------------------------------------------------------
    // MARK: Root pane
    // -------------------------------------------------------------------------

    private let rootPane: javax.swing.JRootPane = javax.swing.JRootPane()

    // -------------------------------------------------------------------------
    // MARK: Initialisierung
    // -------------------------------------------------------------------------

    public override init(_ title: String = "") {
      super.init(title)
      // Add the root pane as the sole direct child of this frame
      super.add(rootPane)
    }

    /// Fills the root pane to the full frame bounds, then lets rootPane
    /// lay out its own children (menuBar, contentPane, etc.).
    /// Does NOT call super.doLayout() — JFrame has no LayoutManager and
    /// the inherited FlowLayout would overwrite the bounds we just set.
    override public func doLayout() {
      rootPane.bounds = java.awt.Rectangle(0, 0, bounds.width, bounds.height)
      rootPane.validate()
    }

    // -------------------------------------------------------------------------
    // MARK: RootPaneContainer
    // -------------------------------------------------------------------------

    public func getRootPane() -> javax.swing.JRootPane {
      return rootPane
    }

    public func getContentPane() -> java.awt.Container {
      return rootPane.getContentPane()
    }

    public func setContentPane(_ contentPane: java.awt.Container) {
      rootPane.setContentPane(contentPane)
    }

    public func getGlassPane() -> java.awt.Component {
      return rootPane.getGlassPane()
    }

    public func setGlassPane(_ glassPane: java.awt.Component) {
      rootPane.setGlassPane(glassPane)
    }

    public func getLayeredPane() -> javax.swing.JLayeredPane {
      return rootPane.getLayeredPane()
    }

    public func setLayeredPane(_ layeredPane: javax.swing.JLayeredPane) {
      rootPane.setLayeredPane(layeredPane)
    }

    // -------------------------------------------------------------------------
    // MARK: Menu bar
    // -------------------------------------------------------------------------

    /// Installs `menuBar` in the root pane's layered pane (`FRAME_CONTENT_LAYER`).
    ///
    /// Unlike `java.awt.Frame.setMenuBar(_:)`, which delegates to the native OS
    /// menu system, `setJMenuBar(_:)` places the bar inside the Swing layer stack
    /// so it is drawn by the Look & Feel delegate (`BasicMenuBarUI`).
    public func setJMenuBar(_ menuBar: javax.swing.JMenuBar?) {
      rootPane.setMenuBar(menuBar)
    }

    public func getJMenuBar() -> javax.swing.JMenuBar? {
      rootPane.getMenuBar()
    }

    // -------------------------------------------------------------------------
    // MARK: Delegate add() / remove() to content pane
    // -------------------------------------------------------------------------

    /// Adds `comp` to the content pane (not directly to the frame).
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

    /// Processes the WINDOW_CLOSING event according to `defaultCloseOperation`.
    ///
    /// Called automatically when the user clicks the native close button.
    override open func dispose() {
      switch defaultCloseOperation {
      case JFrame.DO_NOTHING_ON_CLOSE:
        break
      case JFrame.HIDE_ON_CLOSE:
        setVisible(false)
      case JFrame.DISPOSE_ON_CLOSE:
        super.dispose()
      case JFrame.EXIT_ON_CLOSE:
        java.lang.System.exit(0)
      default:
        super.dispose()
      }
    }

    // -------------------------------------------------------------------------
    // MARK: defaultCloseOperation accessor
    // -------------------------------------------------------------------------

    public func getDefaultCloseOperation() -> Int { defaultCloseOperation }
    public func setDefaultCloseOperation(_ operation: Int) {
      defaultCloseOperation = operation
    }
  }
}
