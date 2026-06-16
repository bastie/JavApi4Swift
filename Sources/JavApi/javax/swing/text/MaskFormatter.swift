/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Formats and validates text against a fixed mask pattern.
  ///
  /// Mirrors `javax.swing.text.MaskFormatter`.
  ///
  /// ## Mask characters
  ///
  /// | Character | Accepts |
  /// |-----------|---------|
  /// | `#`       | digit (0–9) |
  /// | `A`       | letter or digit |
  /// | `?`       | any letter |
  /// | `*`       | any character |
  /// | `U`       | any letter — converted to upper-case |
  /// | `L`       | any letter — converted to lower-case |
  /// | `H`       | hex digit (0–9, A–F, a–f) |
  /// | anything else | literal (copied as-is) |
  ///
  /// ## Example
  ///
  /// ```swift
  /// let fmt = try javax.swing.text.MaskFormatter("##/##/####")
  /// let field = javax.swing.JFormattedTextField(fmt)
  /// // user types: 01/01/2026
  /// ```
  ///
  /// - Since: Java 1.4
  open class MaskFormatter: DefaultFormatter {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var _mask: String = ""

    /// The placeholder character used for empty slots. Default: `_`
    private var _placeholderChar: Character = "_"

    /// An optional fixed placeholder string (same length as mask's editable slots).
    private var _placeholder: String? = nil

    /// Whether literal characters from the mask are included in `stringToValue`.
    /// Default: `true`.
    private var _valueContainsLiteralCharacters: Bool = true

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    /// Creates a `MaskFormatter` with the given mask.
    ///
    /// - Throws: `java.text.ParseException` if `mask` is not valid.
    public init(_ mask: String) throws {
      super.init()
      try setMask(mask)
    }

    // -------------------------------------------------------------------------
    // MARK: Configuration
    // -------------------------------------------------------------------------

    public func getMask() -> String { _mask }

    /// Sets the mask pattern.
    /// - Throws: `java.text.ParseException` if the mask is invalid.
    public func setMask(_ mask: String) throws {
      // Java validates the mask; we accept any non-empty string.
      guard !mask.isEmpty else {
        throw java.text.ParseException("Mask must not be empty", 0)
      }
      _mask = mask
    }

    public func getPlaceholderCharacter() -> Character { _placeholderChar }
    public func setPlaceholderCharacter(_ c: Character) { _placeholderChar = c }

    public func getPlaceholder() -> String? { _placeholder }
    public func setPlaceholder(_ s: String?) { _placeholder = s }

    public func getValueContainsLiteralCharacters() -> Bool { _valueContainsLiteralCharacters }
    public func setValueContainsLiteralCharacters(_ v: Bool) { _valueContainsLiteralCharacters = v }

    // -------------------------------------------------------------------------
    // MARK: AbstractFormatter overrides
    // -------------------------------------------------------------------------

    /// Formats `value` into the mask, filling empty slots with the placeholder.
    ///
    /// - Throws: `java.text.ParseException` if the value does not fit the mask.
    open override func valueToString(_ value: Any?) throws -> String {
      let raw: String
      if let v = value {
        raw = String(describing: v)
      } else {
        raw = ""
      }
      return try applyMask(to: raw)
    }

    /// Validates `text` against the mask and returns the value string.
    ///
    /// - Throws: `java.text.ParseException` if `text` does not match the mask.
    open override func stringToValue(_ text: String) throws -> Any? {
      // Validate and strip/keep literals depending on _valueContainsLiteralCharacters
      var result = ""
      var textIdx = text.startIndex
      var maskIdx = _mask.startIndex

      while maskIdx < _mask.endIndex {
        let maskChar = _mask[maskIdx]
        let isLiteral = !isSpecialMaskChar(maskChar)

        if isLiteral {
          // literal must match exactly (or be present in text)
          if textIdx < text.endIndex && text[textIdx] == maskChar {
            if _valueContainsLiteralCharacters { result.append(maskChar) }
            textIdx = text.index(after: textIdx)
          } else if textIdx >= text.endIndex {
            if _valueContainsLiteralCharacters { result.append(maskChar) }
          } else {
            // mismatch on literal
            let offset = text.distance(from: text.startIndex, to: textIdx)
            throw java.text.ParseException(
              "MaskFormatter: literal mismatch at index \(offset)", offset)
          }
        } else {
          // special char — consume one character from text
          if textIdx >= text.endIndex {
            // pad with placeholder
            result.append(_placeholderChar)
          } else {
            let c = text[textIdx]
            guard let converted = convert(c, using: maskChar) else {
              let offset = text.distance(from: text.startIndex, to: textIdx)
              throw java.text.ParseException(
                "MaskFormatter: '\(c)' does not match mask char '\(maskChar)' at index \(offset)",
                offset)
            }
            result.append(converted)
            textIdx = text.index(after: textIdx)
          }
        }
        maskIdx = _mask.index(after: maskIdx)
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// Applies the mask to `raw`, inserting literals and placeholder chars.
    private func applyMask(to raw: String) throws -> String {
      var result = ""
      var rawIdx = raw.startIndex
      var maskIdx = _mask.startIndex
      // placeholder source: placeholder string or repeated placeholderChar
      var phIdx = _placeholder?.startIndex

      while maskIdx < _mask.endIndex {
        let maskChar = _mask[maskIdx]
        if isSpecialMaskChar(maskChar) {
          if rawIdx < raw.endIndex {
            let c = raw[rawIdx]
            guard let converted = convert(c, using: maskChar) else {
              let offset = raw.distance(from: raw.startIndex, to: rawIdx)
              throw java.text.ParseException(
                "MaskFormatter: '\(c)' does not match mask char '\(maskChar)' at position \(offset)",
                offset)
            }
            result.append(converted)
            rawIdx = raw.index(after: rawIdx)
          } else {
            // fill with placeholder
            if let ph = _placeholder, let pi = phIdx, pi < ph.endIndex {
              result.append(ph[pi])
              phIdx = ph.index(after: pi)
            } else {
              result.append(_placeholderChar)
            }
          }
        } else {
          // literal
          result.append(maskChar)
          // If raw text contains the literal at this position, skip it
          if rawIdx < raw.endIndex && raw[rawIdx] == maskChar {
            rawIdx = raw.index(after: rawIdx)
          }
        }
        maskIdx = _mask.index(after: maskIdx)
      }
      return result
    }

    /// Returns `true` if `c` is one of the special mask characters.
    private func isSpecialMaskChar(_ c: Character) -> Bool {
      return "#A?*ULH".contains(c)
    }

    /// Validates and optionally transforms `char` against `maskChar`.
    /// Returns the (converted) character if valid, `nil` otherwise.
    private func convert(_ char: Character, using maskChar: Character) -> Character? {
      switch maskChar {
      case "#":
        return char.isNumber ? char : nil
      case "A":
        return (char.isLetter || char.isNumber) ? char : nil
      case "?":
        return char.isLetter ? char : nil
      case "*":
        return char
      case "U":
        guard char.isLetter else { return nil }
        return char.uppercased().first
      case "L":
        guard char.isLetter else { return nil }
        return char.lowercased().first
      case "H":
        let upper = char.uppercased().first ?? char
        let hexChars: Set<Character> = ["0","1","2","3","4","5","6","7","8","9",
                                         "A","B","C","D","E","F"]
        return hexChars.contains(upper) ? upper : nil
      default:
        return char == maskChar ? char : nil
      }
    }
  }
}
