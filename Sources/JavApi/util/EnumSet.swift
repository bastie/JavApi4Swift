/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A specialized `Set` implementation for use with enum-like elements.
  ///
  /// Elements must conform to `CaseIterable & Hashable`.  Storage is a `[Bool]`
  /// array indexed by ordinal (position in `E.allCases`), giving O(1) add/remove/contains.
  /// Iteration order follows `E.allCases` (declaration order), matching Java semantics.
  ///
  /// Differences from `java.util.EnumSet`:
  /// - The element constraint is `CaseIterable & Hashable` rather than `java.lang.Enum`.
  /// - Factory methods are `static func` on the Swift type rather than on a companion.
  /// - `range(_:_:)` is inclusive on both ends — matching Java semantics exactly.
  public final class EnumSet<E>
    where E: CaseIterable & Hashable, E.AllCases.Element == E {

    // MARK: - Storage

    private let _allCases: [E]
    private var _bits: [Bool]

    // MARK: - Private init

    private init(bits: [Bool], allCases: [E]) {
      _bits     = bits
      _allCases = allCases
    }

    // MARK: - Factory methods

    /// Returns an empty `EnumSet`.
    public static func noneOf() -> EnumSet<E> {
      let cases = Array(E.allCases)
      return EnumSet(bits: Array(repeating: false, count: cases.count), allCases: cases)
    }

    /// Returns an `EnumSet` containing all cases.
    public static func allOf() -> EnumSet<E> {
      let cases = Array(E.allCases)
      return EnumSet(bits: Array(repeating: true, count: cases.count), allCases: cases)
    }

    /// Returns an `EnumSet` containing the specified elements.
    public static func of(_ elements: E...) -> EnumSet<E> {
      let set = noneOf()
      for e in elements { set.add(e) }
      return set
    }

    /// Returns a copy of `other`.
    public static func copyOf(_ other: EnumSet<E>) -> EnumSet<E> {
      EnumSet(bits: other._bits, allCases: other._allCases)
    }

    /// Returns an `EnumSet` built from a Swift `Array` of elements (Swiftify).
    ///
    /// Mirrors `java.util.EnumSet.copyOf(Collection<E> c)`.
    public static func copyOf(_ elements: [E]) -> EnumSet<E> {
      let set = noneOf()
      for e in elements { set.add(e) }
      return set
    }

    /// Returns the complement of `other` (all cases NOT in `other`).
    public static func complementOf(_ other: EnumSet<E>) -> EnumSet<E> {
      let bits = other._bits.map { !$0 }
      return EnumSet(bits: bits, allCases: other._allCases)
    }

    /// Returns an `EnumSet` with all elements whose ordinal is in the
    /// closed range `[from, to]` (inclusive on both ends).
    public static func range(_ from: E, _ to: E) -> EnumSet<E> {
      let cases = Array(E.allCases)
      guard let lo = cases.firstIndex(of: from),
            let hi = cases.firstIndex(of: to),
            lo <= hi else {
        return EnumSet(bits: Array(repeating: false, count: cases.count), allCases: cases)
      }
      var bits = Array(repeating: false, count: cases.count)
      for i in lo...hi { bits[i] = true }
      return EnumSet(bits: bits, allCases: cases)
    }

    // MARK: - Ordinal helper

    @inline(__always)
    private func _ordinal(of element: E) -> Int? {
      _allCases.firstIndex(of: element)
    }

    // MARK: - Core Set operations

    /// Adds `element` to the set.  Returns `true` if the set changed.
    @discardableResult
    public func add(_ element: E) -> Bool {
      guard let i = _ordinal(of: element) else { return false }
      if _bits[i] { return false }
      _bits[i] = true
      return true
    }

    /// Removes `element` from the set.  Returns `true` if the set changed.
    @discardableResult
    public func remove(_ element: E) -> Bool {
      guard let i = _ordinal(of: element) else { return false }
      if !_bits[i] { return false }
      _bits[i] = false
      return true
    }

    /// Returns `true` if the set contains `element`.
    public func contains(_ element: E) -> Bool {
      guard let i = _ordinal(of: element) else { return false }
      return _bits[i]
    }

    /// Returns the number of elements in the set.
    public func size() -> Int {
      _bits.reduce(0) { $0 + ($1 ? 1 : 0) }
    }

    /// Returns `true` if the set contains no elements.
    public func isEmpty() -> Bool {
      _bits.allSatisfy { !$0 }
    }

    /// Removes all elements.
    public func clear() {
      for i in _bits.indices { _bits[i] = false }
    }

    // MARK: - Bulk operations

    /// Adds all elements from `other` into this set.
    public func addAll(_ other: EnumSet<E>) {
      for i in _bits.indices { _bits[i] = _bits[i] || other._bits[i] }
    }

    /// Removes all elements that are also in `other`.
    public func removeAll(_ other: EnumSet<E>) {
      for i in _bits.indices { if other._bits[i] { _bits[i] = false } }
    }

    /// Retains only elements that are also in `other`.
    public func retainAll(_ other: EnumSet<E>) {
      for i in _bits.indices { _bits[i] = _bits[i] && other._bits[i] }
    }

    /// Returns `true` if all elements of `other` are contained in this set.
    public func containsAll(_ other: EnumSet<E>) -> Bool {
      for i in _bits.indices where other._bits[i] {
        if !_bits[i] { return false }
      }
      return true
    }

    // MARK: - Sequence / iteration

    /// Returns all elements of the set in declaration order.
    public func toArray() -> [E] {
      _allCases.enumerated().compactMap { _bits[$0.offset] ? $0.element : nil }
    }

    /// Applies `action` to each element in declaration order.
    public func forEach(_ action: (E) -> Void) {
      for e in toArray() { action(e) }
    }

    // MARK: - clone / equals / hashCode

    /// Returns a copy of this set.
    public func clone() -> EnumSet<E> {
      EnumSet(bits: _bits, allCases: _allCases)
    }

    public func equals(_ other: EnumSet<E>) -> Bool { _bits == other._bits }

    public func hashCode() -> Int {
      var hasher = Hasher()
      for b in _bits { hasher.combine(b) }
      return hasher.finalize()
    }
  }
}

// MARK: - Sequence conformance

extension java.util.EnumSet: Sequence
  where E: CaseIterable & Hashable, E.AllCases.Element == E {

  public func makeIterator() -> IndexingIterator<[E]> {
    toArray().makeIterator()
  }
}
