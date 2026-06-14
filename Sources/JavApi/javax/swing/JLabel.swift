/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A display area for a short text string.
  ///
  /// `JLabel` is a non-interactive Swing component that displays a single line
  /// of read-only text, aligned horizontally and vertically within its bounds.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let label = javax.swing.JLabel("Hello, World!")
  /// label.setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
  /// panel.add(label)
  /// ```
  ///
  /// ## Alignment constants
  ///
  /// Use the `SwingConstants` values for alignment:
  ///
  /// | Constant | Value | Meaning |
  /// |---|---|---|
  /// | `LEFT` | 2 | Text flush-left (default) |
  /// | `CENTER` | 0 | Text centred |
  /// | `RIGHT` | 4 | Text flush-right |
  ///
  @MainActor
  open class JLabel: javax.swing.JComponent, javax.swing.SwingConstants {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var text: String
    private var horizontalAlignment: Int = JLabel.LEFT
    private var verticalAlignment:   Int = JLabel.CENTER

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ text: String = "") {
      self.text = text
      super.init()
      setOpaque(false)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func updateUI() {
      super.updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getText() -> String { text }
    public func setText(_ newText: String) {
      text = newText
      invalidate()
    }

    public func getHorizontalAlignment() -> Int { horizontalAlignment }
    public func setHorizontalAlignment(_ alignment: Int) {
      horizontalAlignment = alignment
      invalidate()
    }

    public func getVerticalAlignment() -> Int { verticalAlignment }
    public func setVerticalAlignment(_ alignment: Int) {
      verticalAlignment = alignment
      invalidate()
    }
  }
}
