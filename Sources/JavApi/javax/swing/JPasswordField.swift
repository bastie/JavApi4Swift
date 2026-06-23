/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A single-line text field that masks its content — mirrors `javax.swing.JPasswordField`.
  ///
  /// The displayed text is replaced by the echo character (default `😎`) so that
  /// the actual password is not visible on screen.  The real text is still
  /// accessible via `getPassword()` (preferred) or `getText()`.
  ///
  /// ```swift
  /// let pw = javax.swing.JPasswordField(20)
  /// pw.addActionListener(loginListener)
  /// panel.add(pw)
  /// let password = String(pw.getPassword())
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JPasswordField: javax.swing.JTextField {

    // -------------------------------------------------------------------------
    // MARK: Echo character
    // -------------------------------------------------------------------------

    private var _echoChar: Character = "😎"

    /// The character shown in place of each real character.
    public func getEchoChar() -> Character { _echoChar }

    /// Sets the echo character.  Pass `"\0"` to show the real text.
    public func setEchoChar(_ c: Character) {
      _echoChar = c
      repaint()
    }

    /// Returns `true` when an echo character is set (i.e. input is masked).
    public func echoCharIsSet() -> Bool { _echoChar != "\0" }

    // -------------------------------------------------------------------------
    // MARK: Password access
    // -------------------------------------------------------------------------

    /// Returns the password as a `[Character]` array (Java-compatible API).
    ///
    /// Prefer this over `getText()` — it makes it easier to zero-out the
    /// array after use.
    public func getPassword() -> [Character] { Array(getText()) }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
      updateUI()
    }

    public override init(_ text: String) {
      super.init(text)
      updateUI()
    }

    public init(_ columns: Int) {
      super.init(columns: columns)
      updateUI()
    }

    public override init(_ text: String, _ columns: Int) {
      super.init(text, columns)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "PasswordFieldUI" }
  }
}
