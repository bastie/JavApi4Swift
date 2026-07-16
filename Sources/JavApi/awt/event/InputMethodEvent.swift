/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Reports changes to text being composed by an input method (IME) —
  /// mirrors `java.awt.event.InputMethodEvent`.
  ///
  /// Fired either when composed text changes (`INPUT_METHOD_TEXT_CHANGED`) or
  /// when only the caret moves within existing composed text
  /// (`CARET_POSITION_CHANGED`). Delivered to components implementing the
  /// `java.awt.im` input-method-listener protocol (not yet ported).
  ///
  /// - Since: Java 1.2
  open class InputMethodEvent: java.awt.AWTEvent, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: - Event id range
    // -------------------------------------------------------------------------

    public static let INPUT_METHOD_FIRST         = 1100
    public static let INPUT_METHOD_TEXT_CHANGED  = 1100
    public static let CARET_POSITION_CHANGED     = 1101
    public static let INPUT_METHOD_LAST          = 1101

    // -------------------------------------------------------------------------
    // MARK: - Fields
    // -------------------------------------------------------------------------

    private let text: (any java.text.AttributedCharacterIterator)?
    public let committedCharacterCount: Int
    private let caret: java.awt.font.TextHitInfo?
    private let visiblePosition: java.awt.font.TextHitInfo?

    // -------------------------------------------------------------------------
    // MARK: - Init
    // -------------------------------------------------------------------------

    /// Full constructor — used for `INPUT_METHOD_TEXT_CHANGED`.
    public init(_ source: java.awt.Component,
                _ id: Int,
                _ text: (any java.text.AttributedCharacterIterator)?,
                _ committedCharacterCount: Int,
                _ caret: java.awt.font.TextHitInfo?,
                _ visiblePosition: java.awt.font.TextHitInfo?) {
      self.text = text
      self.committedCharacterCount = committedCharacterCount
      self.caret = caret
      self.visiblePosition = visiblePosition
      super.init(source, id)
    }

    /// Convenience constructor — used for `CARET_POSITION_CHANGED`
    /// (no text change, `committedCharacterCount` is always 0).
    public convenience init(_ source: java.awt.Component,
                            _ id: Int,
                            _ caret: java.awt.font.TextHitInfo?,
                            _ visiblePosition: java.awt.font.TextHitInfo?) {
      self.init(source, id, nil, 0, caret, visiblePosition)
    }

    // -------------------------------------------------------------------------
    // MARK: - Accessors
    // -------------------------------------------------------------------------

    /// The composed and/or committed text, or `nil` for caret-only events.
    public func getText() -> (any java.text.AttributedCharacterIterator)? { text }

    /// Number of characters in `getText()` that have been committed.
    public func getCommittedCharacterCount() -> Int { committedCharacterCount }

    /// The current caret position within the composed text, if any.
    public func getCaret() -> java.awt.font.TextHitInfo? { caret }

    /// The range of composed text that should remain visible, if any.
    public func getVisiblePosition() -> java.awt.font.TextHitInfo? { visiblePosition }

    // `consume()` / `isConsumed()` are inherited unchanged from `AWTEvent`.
  }
}
