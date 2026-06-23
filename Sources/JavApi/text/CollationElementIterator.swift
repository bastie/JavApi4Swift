/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Iterates over the collation elements of a string.
  ///
  /// Mirrors `java.text.CollationElementIterator`.
  ///
  /// A `CollationElementIterator` is used to walk through each collation element
  /// of an international string. Use the iterator to return the ordering priority
  /// of the positioned character. The ordering priority of a character, which we
  /// refer to as a key, defines how a character is collated in the given collation
  /// object.
  ///
  /// An instance is obtained from ``RuleBasedCollator/getCollationElementIterator(_:)-swift.method``:
  /// ```swift
  /// let col = try java.text.RuleBasedCollator("< a < b < c")
  /// let iter = col.getCollationElementIterator("abc")
  /// while true {
  ///   let order = iter.next()
  ///   if order == CollationElementIterator.NULLORDER { break }
  ///   print(CollationElementIterator.primaryOrder(order))
  /// }
  /// ```
  ///
  /// ## Collation element encoding
  ///
  /// Each collation element is encoded as a 32-bit `Int`:
  /// - Bits 31–16: primary order (16 bits)
  /// - Bits 15–8:  secondary order (8 bits)
  /// - Bits 7–0:   tertiary order (8 bits)
  ///
  /// - Since: Java 1.1
  public final class CollationElementIterator {

    // -------------------------------------------------------------------------
    // MARK: Sentinel
    // -------------------------------------------------------------------------

    /// Returned by ``next()`` and ``previous()`` when iteration is exhausted.
    public static let NULLORDER: Int = -1

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    /// The collation elements for the text, computed once on `setText`.
    private var elements: [Int] = []

    /// Current iteration position (0 … elements.count).
    private var index: Int = 0

    // -------------------------------------------------------------------------
    // MARK: Package-internal initialiser
    // -------------------------------------------------------------------------

    /// Creates an iterator over the collation elements of `text` using the
    /// provided `collator` to compute element weights.
    init(text: String, collator: RuleBasedCollator) {
      elements = CollationElementIterator.buildElements(text: text, collator: collator)
    }

    // -------------------------------------------------------------------------
    // MARK: Navigation
    // -------------------------------------------------------------------------

    /// Returns the next collation element, or ``NULLORDER`` if exhausted.
    public func next() -> Int {
      guard index < elements.count else { return Self.NULLORDER }
      let e = elements[index]
      index += 1
      return e
    }

    /// Returns the previous collation element, or ``NULLORDER`` if at start.
    public func previous() -> Int {
      guard index > 0 else { return Self.NULLORDER }
      index -= 1
      return elements[index]
    }

    /// Resets the iterator to the start of the text.
    public func reset() {
      index = 0
    }

    // -------------------------------------------------------------------------
    // MARK: Position
    // -------------------------------------------------------------------------

    /// Returns the current offset in the original text.
    ///
    /// Because one collation element corresponds to one character in this
    /// simplified implementation, `getOffset()` equals the current element index.
    public func getOffset() -> Int { index }

    /// Moves the iterator to the element at or after `offset` in the text.
    public func setOffset(_ offset: Int) {
      index = max(0, min(offset, elements.count))
    }

    // -------------------------------------------------------------------------
    // MARK: Text replacement
    // -------------------------------------------------------------------------

    /// Replaces the text being iterated and resets to the beginning.
    public func setText(_ text: String, collator: RuleBasedCollator) {
      elements = CollationElementIterator.buildElements(text: text, collator: collator)
      index = 0
    }

    /// Replaces the text being iterated with the text from `iterator`
    /// and resets to the beginning.
    ///
    /// Mirrors the `java.text.CollationElementIterator.setText(CharacterIterator)`
    /// overload.
    public func setText(_ iterator: any CharacterIterator, collator: RuleBasedCollator) {
      setText(textFrom(iterator), collator: collator)
    }

    // -------------------------------------------------------------------------
    // MARK: Private helper
    // -------------------------------------------------------------------------

    /// Drains a `CharacterIterator` into a `String`.
    private func textFrom(_ iter: any CharacterIterator) -> String {
      var result = ""
      var ch = iter.first()
      while ch != "\u{FFFF}" {   // CharacterIterator.DONE
        result.append(ch)
        ch = iter.next()
      }
      return result
    }

    // -------------------------------------------------------------------------
    // MARK: Order extraction (static)
    // -------------------------------------------------------------------------

    /// Returns the primary order from a collation element.
    ///
    /// The primary order occupies bits 31–16.
    public static func primaryOrder(_ order: Int) -> Int {
      return (order >> 16) & 0xFFFF
    }

    /// Returns the secondary order from a collation element.
    ///
    /// The secondary order occupies bits 15–8.
    public static func secondaryOrder(_ order: Int) -> Int {
      return (order >> 8) & 0xFF
    }

    /// Returns the tertiary order from a collation element.
    ///
    /// The tertiary order occupies bits 7–0.
    public static func tertiaryOrder(_ order: Int) -> Int {
      return order & 0xFF
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Encodes primary, secondary, and tertiary weights into one 32-bit Int.
    private static func encode(primary: Int, secondary: Int, tertiary: Int) -> Int {
      return ((primary & 0xFFFF) << 16)
           | ((secondary & 0xFF) << 8)
           |  (tertiary & 0xFF)
    }

    /// Computes the collation element array for `text`.
    ///
    /// For each character in `text`:
    /// - **Primary** weight: the collator's custom `orderTable` index if the
    ///   character appears in the rules; otherwise the Unicode scalar value
    ///   shifted into a high range so custom chars always sort first.
    /// - **Secondary** weight: 0 for uppercase characters (Java convention),
    ///   distinguishes accented variants where feasible.
    /// - **Tertiary** weight: 0 for uppercase, 1 for lowercase (Java convention).
    private static func buildElements(text: String, collator: RuleBasedCollator) -> [Int] {
      var result: [Int] = []
      for scalar in text.unicodeScalars {
        let ch = String(scalar)
        let primary: Int
        if let tableIdx = collator.orderTable[ch] {
          primary = tableIdx + 1   // +1 so 0 is reserved for "no weight"
        } else {
          // Unknown character: use code point, offset so it sorts after table chars
          primary = Int(scalar.value) + 0x1000
        }
        // Tertiary: uppercase = 0, lowercase = 8 (Java convention)
        let tertiary: Int
        if ch == ch.uppercased() && ch != ch.lowercased() {
          tertiary = 0  // uppercase
        } else if ch == ch.lowercased() && ch != ch.uppercased() {
          tertiary = 8  // lowercase
        } else {
          tertiary = 4  // no case distinction
        }
        result.append(encode(primary: primary, secondary: 0, tertiary: tertiary))
      }
      return result
    }
  }
}
