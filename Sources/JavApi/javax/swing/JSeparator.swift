/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A thin dividing line between groups of components.
  ///
  /// `JSeparator` is a `JComponent` whose appearance is controlled by a
  /// `SeparatorUI` delegate (default: `BasicSeparatorUI`).  It can be
  /// horizontal (the default, used in menus) or vertical (used in toolbars).
  ///
  /// The orientation constants are the same as `SwingConstants`:
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `HORIZONTAL` | 0 |
  /// | `VERTICAL`   | 1 |
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // In a toolbar:
  /// toolbar.addSeparator()          // preferred — JToolBar wraps this
  ///
  /// // Explicitly:
  /// let sep = javax.swing.JSeparator(JSeparator.VERTICAL)
  /// panel.add(sep)
  /// ```
  ///
  @MainActor
  open class JSeparator: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _orientation: Int

    public func getOrientation() -> Int { _orientation }
    public func setOrientation(_ orientation: Int) {
      _orientation = orientation
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a horizontal separator.
    public override convenience init() {
      self.init (JSeparator.HORIZONTAL)
    }

    /// Creates a separator with the given orientation.
    public init(_ orientation: Int) {
      _orientation = orientation
      super.init()
      setOpaque(false)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------
    
    override open func getUIClassID() -> String { "SeparatorUI" }
    
    override open func updateUI() {
      super.updateUI()
    }
  }
}
