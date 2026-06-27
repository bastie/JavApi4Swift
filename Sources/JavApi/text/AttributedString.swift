/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  // ---------------------------------------------------------------------------
  // MARK: Concrete AttributedCharacterIterator implementation
  // ---------------------------------------------------------------------------

  /// Concrete ``AttributedCharacterIterator`` returned by
  /// ``AttributedString/getIterator()``.
  ///
  /// This class is package-internal; callers use the protocol type.
  final internal class AttributedStringIterator : AttributedCharacterIterator, @unchecked Sendable {

    // Typealias to satisfy the protocol requirement (already set in the protocol,
    // but the concrete type must also see it).
    typealias Attribute = java.text.AttributedCharacterIteratorAttribute

    // The attributed string we iterate over.
    private let owner: AttributedString

    // Current position.
    private var pos: Int

    init(_ owner: AttributedString) {
      self.owner = owner
      self.pos   = owner.beginIndex
    }

    // -------------------------------------------------------------------------
    // MARK: CharacterIterator
    // -------------------------------------------------------------------------

    func first() -> Character {
      pos = owner.beginIndex
      return current()
    }

    func last() -> Character {
      if owner.endIndex == owner.beginIndex {
        pos = owner.endIndex
        return Self.DONE
      }
      pos = owner.endIndex - 1
      return current()
    }

    func current() -> Character {
      guard pos >= owner.beginIndex && pos < owner.endIndex else { return Self.DONE }
      return owner.chars[pos]
    }

    func next() -> Character {
      pos += 1
      if pos >= owner.endIndex {
        pos = owner.endIndex
        return Self.DONE
      }
      return owner.chars[pos]
    }

    func previous() -> Character {
      if pos <= owner.beginIndex { return Self.DONE }
      pos -= 1
      return owner.chars[pos]
    }

    func setIndex(_ position: Int) -> Character {
      guard position >= owner.beginIndex && position <= owner.endIndex else {
        fatalError("AttributedStringIterator.setIndex: \(position) out of range")
      }
      pos = position
      return current()
    }

    func getBeginIndex() -> Int { owner.beginIndex }
    func getEndIndex()   -> Int { owner.endIndex   }
    func getIndex()      -> Int { pos              }

    func clone() -> any CharacterIterator {
      let copy = AttributedStringIterator(owner)
      copy.pos = self.pos
      return copy
    }

    // -------------------------------------------------------------------------
    // MARK: AttributedCharacterIterator
    // -------------------------------------------------------------------------

    func getRunStart() -> Int {
      // The run containing `pos` starts at the first index that has exactly
      // the same attribute map as `pos`.
      let current = owner.attributesAt(pos)
      var start = pos
      while start > owner.beginIndex {
        let prev = owner.attributesAt(start - 1)
        guard attributeMapsEqual(prev, current) else { break }
        start -= 1
      }
      return start
    }

    func getRunLimit() -> Int {
      let current = owner.attributesAt(pos)
      var end = pos + 1
      while end < owner.endIndex {
        let next = owner.attributesAt(end)
        guard attributeMapsEqual(next, current) else { break }
        end += 1
      }
      return end
    }

    func getAttributes() -> [Attribute : Any] {
      return owner.attributesAt(pos)
    }

    func getAttribute(_ attribute: Attribute) -> Any? {
      return owner.attributesAt(pos)[attribute]
    }

    func getAllAttributeKeys() -> Set<Attribute> {
      var keys: Set<Attribute> = []
      for i in owner.beginIndex..<owner.endIndex {
        keys.formUnion(owner.attributesAt(i).keys)
      }
      return keys
    }

    // -------------------------------------------------------------------------
    // MARK: Private helper
    // -------------------------------------------------------------------------

    private func attributeMapsEqual(_ a: [Attribute: Any], _ b: [Attribute: Any]) -> Bool {
      guard a.count == b.count else { return false }
      for (key, _) in a {
        guard b[key] != nil else { return false }
      }
      return true
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: AttributedString
  // ---------------------------------------------------------------------------

  /// A `String` together with associated attributes for subranges.
  ///
  /// Mirrors `java.text.AttributedString`.
  ///
  /// Attributes are keyed by ``AttributedCharacterIterator/Attribute`` and can
  /// be any `Any`-typed value. Ranges are specified in character-index terms
  /// (0-based, exclusive end).
  ///
  /// ```swift
  /// var as = java.text.AttributedString("Hello")
  /// let key = java.text.AttributedCharacterIterator.Attribute.LANGUAGE
  /// as.addAttribute(key, value: "en", beginIndex: 0, endIndex: 5)
  /// let iter = as.getIterator()
  /// print(iter.getAttribute(key) as? String ?? "")  // "en"
  /// ```
  ///
  /// - Since: Java 1.2
  open class AttributedString {

    // -------------------------------------------------------------------------
    // MARK: Types
    // -------------------------------------------------------------------------

    public typealias Attribute = java.text.AttributedCharacterIteratorAttribute

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    /// The characters of the string.
    var chars: [Character]

    /// The character range covered by this `AttributedString`.
    var beginIndex: Int { 0 }
    var endIndex:   Int { chars.count }

    /// Per-character attribute storage.
    /// `attrMap[i]` is a dictionary of attributes that apply at index `i`.
    private var attrMap: [[Attribute: Any]]

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates an `AttributedString` from a plain string with no attributes.
    public init(_ text: String) {
      chars   = Array(text)
      attrMap = Array(repeating: [:], count: chars.count)
    }

    /// Creates an `AttributedString` from a plain string with initial attributes
    /// applied to the entire string.
    public init(_ text: String, _ attributes: [Attribute: Any]) {
      chars   = Array(text)
      attrMap = Array(repeating: attributes, count: chars.count)
    }

    /// Creates an `AttributedString` from an existing ``AttributedCharacterIterator``.
    ///
    /// Copies the full range `[iter.getBeginIndex(), iter.getEndIndex())`.
    public init(_ iter: any AttributedCharacterIterator) {
      let begin = iter.getBeginIndex()
      let end   = iter.getEndIndex()
      var cs: [Character] = []
      var am: [[Attribute: Any]] = []
      _ = iter.setIndex(begin)
      for i in begin..<end {
        cs.append(iter.current())
        am.append(iter.getAttributes())
        _ = iter.next()
        _ = i  // suppress unused-variable warning
      }
      chars   = cs
      attrMap = am
    }

    /// Creates an `AttributedString` from the subrange `[beginIndex, endIndex)`
    /// of an existing ``AttributedCharacterIterator``.
    ///
    /// - Since: Java 1.2
    public init(_ iter: any AttributedCharacterIterator, _ beginIndex: Int, _ endIndex: Int) {
      let lo = max(iter.getBeginIndex(), beginIndex)
      let hi = min(iter.getEndIndex(),   endIndex)
      var cs: [Character] = []
      var am: [[Attribute: Any]] = []
      if lo < hi {
        _ = iter.setIndex(lo)
        for i in lo..<hi {
          cs.append(iter.current())
          am.append(iter.getAttributes())
          _ = iter.next()
          _ = i
        }
      }
      chars   = cs
      attrMap = am
    }

    // -------------------------------------------------------------------------
    // MARK: Attribute manipulation
    // -------------------------------------------------------------------------

    /// Adds `attribute` with `value` over the entire string.
    public func addAttribute(_ attribute: Attribute, _ value: Any) {
      addAttribute(attribute, value: value, beginIndex: 0, endIndex: chars.count)
    }

    /// Adds `attribute` with `value` over `[beginIndex, endIndex)`.
    ///
    /// - Parameters:
    ///   - beginIndex: Inclusive start index.
    ///   - endIndex:   Exclusive end index.
    public func addAttribute(_ attribute: Attribute, value: Any, beginIndex: Int, endIndex: Int) {
      let lo = max(0, beginIndex)
      let hi = min(chars.count, endIndex)
      guard lo < hi else { return }
      for i in lo..<hi {
        attrMap[i][attribute] = value
      }
    }

    /// Adds all entries in `attributes` over `[beginIndex, endIndex)`.
    public func addAttributes(_ attributes: [Attribute: Any], _ beginIndex: Int, _ endIndex: Int) {
      for (key, value) in attributes {
        addAttribute(key, value: value, beginIndex: beginIndex, endIndex: endIndex)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Iterator factory
    // -------------------------------------------------------------------------

    /// Returns an ``AttributedCharacterIterator`` over the entire string.
    public func getIterator() -> any AttributedCharacterIterator {
      return AttributedStringIterator(self)
    }

    /// Returns an ``AttributedCharacterIterator`` over the entire string,
    /// restricted to the given attribute keys.
    ///
    /// - Parameter attributes: Only these keys will be visible through the
    ///   iterator's `getAttributes()` and `getAttribute(_:)` methods.
    public func getIterator(_ attributes: [Attribute]) -> any AttributedCharacterIterator {
      // Create a filtered copy of attrMap
      let keySet = Set(attributes)
      let filtered = AttributedString(String(chars))
      for i in 0..<chars.count {
        for (k, v) in attrMap[i] {
          if keySet.contains(k) {
            filtered.attrMap[i][k] = v
          }
        }
      }
      return AttributedStringIterator(filtered)
    }

    /// Returns an ``AttributedCharacterIterator`` over `[beginIndex, endIndex)`.
    public func getIterator(_ beginIndex: Int, _ endIndex: Int) -> any AttributedCharacterIterator {
      let lo = max(0, beginIndex)
      let hi = min(chars.count, endIndex)
      let sub = AttributedString(String(chars[lo..<hi]))
      for i in lo..<hi {
        for (k, v) in attrMap[i] {
          sub.attrMap[i - lo][k] = v
        }
      }
      return AttributedStringIterator(sub)
    }

    // -------------------------------------------------------------------------
    // MARK: Package-internal helper
    // -------------------------------------------------------------------------

    /// Returns the attribute map at `index`, or empty if out of range.
    func attributesAt(_ index: Int) -> [Attribute: Any] {
      guard index >= 0 && index < attrMap.count else { return [:] }
      return attrMap[index]
    }
  }
}
