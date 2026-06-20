/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A `Document` that carries per-character and per-paragraph style attributes.
  ///
  /// `StyledDocument` extends `Document` with APIs for applying
  /// `AttributeSet`s to character runs and paragraphs.
  ///
  /// The primary concrete implementation is `DefaultStyledDocument`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol StyledDocument: javax.swing.text.Document {

    // -------------------------------------------------------------------------
    // MARK: Styled insert
    // -------------------------------------------------------------------------

    /// Inserts `string` at `offset` with the given character attributes.
    ///
    /// This is the styled analogue of `Document.insertString(_:_:)`.
    /// Errors (e.g. bad offset) are silently ignored — use the `throws`
    /// variant on `DefaultStyledDocument` directly when you need error handling.
    func insertString(_ offset: Int,
                      _ string: String,
                      _ attrs: javax.swing.text.AttributeSet?)

    // -------------------------------------------------------------------------
    // MARK: Character attributes
    // -------------------------------------------------------------------------

    /// Applies `attrs` to the character run `[offset, offset+length)`.
    ///
    /// - Parameters:
    ///   - offset: Start of the run.
    ///   - length: Length of the run.
    ///   - attrs:  Attributes to apply.
    ///   - replace: If `true`, existing attributes in the run are replaced;
    ///              if `false`, `attrs` is merged on top.
    func setCharacterAttributes(_ offset: Int,
                                _ length: Int,
                                _ attrs: javax.swing.text.AttributeSet,
                                _ replace: Bool)

    /// Returns the character attributes at `position`.
    func getCharacterElement(_ position: Int) -> javax.swing.text.AttributeSet?

    // -------------------------------------------------------------------------
    // MARK: Paragraph attributes
    // -------------------------------------------------------------------------

    /// Applies `attrs` to every paragraph that overlaps `[offset, offset+length)`.
    func setParagraphAttributes(_ offset: Int,
                                _ length: Int,
                                _ attrs: javax.swing.text.AttributeSet,
                                _ replace: Bool)

    /// Returns the paragraph attributes for the paragraph containing `position`.
    func getParagraphElement(_ position: Int) -> javax.swing.text.AttributeSet?

    // -------------------------------------------------------------------------
    // MARK: Foreground / background (convenience)
    // -------------------------------------------------------------------------

    func getForeground(_ attr: javax.swing.text.AttributeSet) -> java.awt.Color
    func getBackground(_ attr: javax.swing.text.AttributeSet) -> java.awt.Color
  }
}
