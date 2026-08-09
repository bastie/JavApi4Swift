/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 *
 * Inspired by Apache Harmony java.util.BitSet
 */

import Foundation

extension java.util {

  /// A vector of bits that grows as needed.
  ///
  /// Mirrors `java.util.BitSet` from Java 1.0. Each bit is either `true`
  /// ("set") or `false` ("clear"). Bits are indexed from 0.
  ///
  /// Internally the bits are stored in an array of `UInt64` words (64 bits
  /// each), which grows automatically when a bit beyond the current capacity
  /// is addressed.
  ///
  /// ### Example
  /// ```swift
  /// let bs = java.util.BitSet(8)
  /// bs.set(0)
  /// bs.set(3)
  /// print(bs.get(0))   // true
  /// print(bs.get(1))   // false
  /// print(bs.size())   // 64  (one full word)
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  public final class BitSet {

    // MARK: - Storage

    /// Backing store — each element holds 64 bits.
    internal var words: [UInt64]

    /// Number of words needed to hold `nbits` bits.
    private static func wordCount(for nbits: Int) -> Int {
      return nbits <= 0 ? 1 : (nbits + 63) / 64
    }

    /// Word index for a given bit index.
    private static func wordIndex(_ bitIndex: Int) -> Int {
      return bitIndex >> 6   // bitIndex / 64
    }

    /// Bit mask for a given bit index within its word.
    private static func mask(_ bitIndex: Int) -> UInt64 {
      return UInt64(1) << (bitIndex & 63)
    }

    // MARK: - Initialisers

    /// Creates a new bit set with a default capacity of 64 bits.
    /// - Since: JavaApi (Java 1.0)
    public init() {
      words = [0]
    }

    /// Creates a new bit set with an initial capacity of at least `nbits` bits.
    ///
    /// All bits are initially `false`.
    /// - Parameter nbits: Initial capacity hint (rounded up to the next
    ///   multiple of 64).
    /// - Since: JavaApi (Java 1.0)
    public init(_ nbits: Int) {
      words = [UInt64](repeating: 0, count: BitSet.wordCount(for: nbits))
    }

    // MARK: - Private helpers

    /// Grows the backing store if `bitIndex` is beyond the current capacity.
    private func ensureCapacity(for bitIndex: Int) {
      let needed = BitSet.wordIndex(bitIndex) + 1
      if needed > words.count {
        words.append(contentsOf: [UInt64](repeating: 0, count: needed - words.count))
      }
    }

    // MARK: - Core bit operations

    /// Sets the bit at `bitIndex` to `true`.
    ///
    /// - Parameter bitIndex: Index of the bit to set. Must be ≥ 0.
    /// - Since: JavaApi (Java 1.0)
    public func set(_ bitIndex: Int) {
      precondition(bitIndex >= 0, "bitIndex < 0: \(bitIndex)")
      ensureCapacity(for: bitIndex)
      words[BitSet.wordIndex(bitIndex)] |= BitSet.mask(bitIndex)
    }

    /// Sets the bit at `bitIndex` to `false`.
    ///
    /// - Parameter bitIndex: Index of the bit to clear. Must be ≥ 0.
    /// - Since: JavaApi (Java 1.0)
    public func clear(_ bitIndex: Int) {
      precondition(bitIndex >= 0, "bitIndex < 0: \(bitIndex)")
      let wi = BitSet.wordIndex(bitIndex)
      guard wi < words.count else { return }
      words[wi] &= ~BitSet.mask(bitIndex)
    }

    /// Returns the value of the bit at `bitIndex`.
    ///
    /// - Parameter bitIndex: Index of the bit to read. Must be ≥ 0.
    /// - Returns: `true` if the bit is set, `false` otherwise.
    /// - Since: JavaApi (Java 1.0)
    public func get(_ bitIndex: Int) -> Bool {
      precondition(bitIndex >= 0, "bitIndex < 0: \(bitIndex)")
      let wi = BitSet.wordIndex(bitIndex)
      guard wi < words.count else { return false }
      return (words[wi] & BitSet.mask(bitIndex)) != 0
    }

    // MARK: - Logical operations

    /// Performs a logical **AND** of this bit set with `set`.
    ///
    /// This bit set is modified in place: a bit is set only if it was set in
    /// both this and `set`.
    /// - Parameter set: The other `BitSet`.
    /// - Since: JavaApi (Java 1.0)
    public func and(_ set: BitSet) {
      let minLen = Swift.min(words.count, set.words.count)
      for i in 0..<minLen {
        words[i] &= set.words[i]
      }
      // Bits beyond the other set's range are cleared
      if words.count > minLen {
        for i in minLen..<words.count {
          words[i] = 0
        }
      }
    }

    /// Performs a logical **OR** of this bit set with `set`.
    ///
    /// This bit set is modified in place: a bit is set if it was set in
    /// either this or `set`.
    /// - Parameter set: The other `BitSet`.
    /// - Since: JavaApi (Java 1.0)
    public func or(_ set: BitSet) {
      if set.words.count > words.count {
        words.append(contentsOf: [UInt64](repeating: 0, count: set.words.count - words.count))
      }
      for i in 0..<set.words.count {
        words[i] |= set.words[i]
      }
    }

    /// Performs a logical **XOR** of this bit set with `set`.
    ///
    /// This bit set is modified in place: a bit is set if it was set in
    /// exactly one of this or `set`.
    /// - Parameter set: The other `BitSet`.
    /// - Since: JavaApi (Java 1.0)
    public func xor(_ set: BitSet) {
      if set.words.count > words.count {
        words.append(contentsOf: [UInt64](repeating: 0, count: set.words.count - words.count))
      }
      for i in 0..<set.words.count {
        words[i] ^= set.words[i]
      }
    }

    // MARK: - Java 1.2 additions

    /// Clears all bits in this `BitSet` whose corresponding bit is set in `set`.
    ///
    /// Equivalent to Java's `BitSet.andNot(BitSet)`.
    ///
    /// - Parameter set: The `BitSet` whose set bits are cleared in this set.
    /// - Since: JavaApi (Java 1.2)
    public func andNot(_ set: BitSet) {
      let minLen = Swift.min(words.count, set.words.count)
      for i in 0..<minLen {
        words[i] &= ~set.words[i]
      }
    }

    // MARK: - Size / cardinality

    /// Returns the number of bits in this `BitSet` (always a multiple of 64).
    ///
    /// - Returns: The number of bits of space currently in use.
    /// - Since: JavaApi (Java 1.0)
    public func size() -> Int {
      return words.count * 64
    }

    /// Returns the index of the highest set bit plus one.
    ///
    /// Returns `0` if no bit is set.
    ///
    /// - Returns: Logical length of this `BitSet`.
    /// - Since: JavaApi (Java 1.4)
    public func length() -> Int {
      var i = words.count - 1
      while i >= 0 && words[i] == 0 { i -= 1 }
      guard i >= 0 else { return 0 }
      return i * 64 + (64 - words[i].leadingZeroBitCount)
    }

    /// Returns `true` if no bit is currently set.
    ///
    /// - Since: JavaApi (Java 1.4)
    public func isEmpty() -> Bool {
      return words.allSatisfy { $0 == 0 }
    }

    /// Returns the number of bits currently set to `true`.
    ///
    /// - Since: JavaApi (Java 1.4)
    public func cardinality() -> Int {
      return words.reduce(0) { $0 + $1.nonzeroBitCount }
    }

    /// Returns `true` if this `BitSet` has any bits set that are also set in `set`.
    ///
    /// - Parameter set: The `BitSet` to compare.
    /// - Since: JavaApi (Java 1.4)
    public func intersects(_ set: BitSet) -> Bool {
      let minLen = Swift.min(words.count, set.words.count)
      return (0..<minLen).contains { (words[$0] & set.words[$0]) != 0 }
    }

    // MARK: - Java 1.4 additions (flip, set/clear ranges, get range, nextBit)

    /// Flips the bit at `bitIndex`.
    ///
    /// - Parameter bitIndex: Index of the bit to flip. Must be ≥ 0.
    /// - Since: JavaApi (Java 1.4)
    public func flip(_ bitIndex: Int) {
      precondition(bitIndex >= 0, "bitIndex < 0: \(bitIndex)")
      ensureCapacity(for: bitIndex)
      words[BitSet.wordIndex(bitIndex)] ^= BitSet.mask(bitIndex)
    }

    /// Flips each bit in the range `[fromIndex, toIndex)`.
    ///
    /// - Parameters:
    ///   - fromIndex: First index to flip (inclusive). Must be ≥ 0.
    ///   - toIndex: Last index to flip (exclusive). Must be ≥ `fromIndex`.
    /// - Since: JavaApi (Java 1.4)
    public func flip(_ fromIndex: Int, _ toIndex: Int) {
      precondition(fromIndex >= 0 && fromIndex <= toIndex,
                   "fromIndex: \(fromIndex), toIndex: \(toIndex)")
      if fromIndex == toIndex { return }
      ensureCapacity(for: toIndex - 1)
      _applyRangeMask(from: fromIndex, to: toIndex) { words[$0] ^= $1 }
    }

    /// Sets the bit at `bitIndex` to `value`.
    ///
    /// - Parameters:
    ///   - bitIndex: Index of the bit. Must be ≥ 0.
    ///   - value: `true` to set; `false` to clear.
    /// - Since: JavaApi (Java 1.4)
    public func set(_ bitIndex: Int, _ value: Bool) {
      if value { set(bitIndex) } else { clear(bitIndex) }
    }

    /// Sets each bit in the range `[fromIndex, toIndex)` to `true`.
    ///
    /// - Parameters:
    ///   - fromIndex: First index to set (inclusive). Must be ≥ 0.
    ///   - toIndex: Last index to set (exclusive). Must be ≥ `fromIndex`.
    /// - Since: JavaApi (Java 1.4)
    public func set(_ fromIndex: Int, _ toIndex: Int) {
      precondition(fromIndex >= 0 && fromIndex <= toIndex,
                   "fromIndex: \(fromIndex), toIndex: \(toIndex)")
      if fromIndex == toIndex { return }
      ensureCapacity(for: toIndex - 1)
      _applyRangeMask(from: fromIndex, to: toIndex) { words[$0] |= $1 }
    }

    /// Sets each bit in the range `[fromIndex, toIndex)` to `value`.
    ///
    /// - Parameters:
    ///   - fromIndex: First index (inclusive). Must be ≥ 0.
    ///   - toIndex: Last index (exclusive). Must be ≥ `fromIndex`.
    ///   - value: `true` to set; `false` to clear.
    /// - Since: JavaApi (Java 1.4)
    public func set(_ fromIndex: Int, _ toIndex: Int, _ value: Bool) {
      if value { set(fromIndex, toIndex) } else { clear(fromIndex, toIndex) }
    }

    /// Clears each bit in the range `[fromIndex, toIndex)`.
    ///
    /// - Parameters:
    ///   - fromIndex: First index to clear (inclusive). Must be ≥ 0.
    ///   - toIndex: Last index to clear (exclusive). Must be ≥ `fromIndex`.
    /// - Since: JavaApi (Java 1.4)
    public func clear(_ fromIndex: Int, _ toIndex: Int) {
      precondition(fromIndex >= 0 && fromIndex <= toIndex,
                   "fromIndex: \(fromIndex), toIndex: \(toIndex)")
      if fromIndex == toIndex { return }
      _applyRangeMask(from: fromIndex, to: toIndex) { words[$0] &= ~$1 }
    }

    /// Returns a new `BitSet` composed of bits `[fromIndex, toIndex)` from this set.
    ///
    /// The bit at `fromIndex` becomes bit 0 in the result.
    ///
    /// - Parameters:
    ///   - fromIndex: First index (inclusive). Must be ≥ 0.
    ///   - toIndex: Last index (exclusive). Must be ≥ `fromIndex`.
    /// - Returns: A new `BitSet` with the selected bits.
    /// - Since: JavaApi (Java 1.4)
    public func get(_ fromIndex: Int, _ toIndex: Int) -> BitSet {
      precondition(fromIndex >= 0 && fromIndex <= toIndex,
                   "fromIndex: \(fromIndex), toIndex: \(toIndex)")
      let result = BitSet(toIndex - fromIndex)
      for i in fromIndex..<toIndex {
        if get(i) { result.set(i - fromIndex) }
      }
      return result
    }

    /// Returns the index of the first set bit at or after `fromIndex`, or `-1`.
    ///
    /// - Parameter fromIndex: The start index. Must be ≥ 0.
    /// - Returns: Index of the next set bit, or `-1` if none exists.
    /// - Since: JavaApi (Java 1.4)
    public func nextSetBit(_ fromIndex: Int) -> Int {
      precondition(fromIndex >= 0, "fromIndex < 0: \(fromIndex)")
      var wi = BitSet.wordIndex(fromIndex)
      guard wi < words.count else { return -1 }
      var word = words[wi] & (~UInt64(0) << (fromIndex & 63))
      while true {
        if word != 0 { return wi * 64 + word.trailingZeroBitCount }
        wi += 1
        guard wi < words.count else { return -1 }
        word = words[wi]
      }
    }

    /// Returns the index of the first clear bit at or after `fromIndex`.
    ///
    /// Always returns a valid index (the logical extent of the set is infinite
    /// clear bits beyond the stored range).
    ///
    /// - Parameter fromIndex: The start index. Must be ≥ 0.
    /// - Returns: Index of the next clear bit.
    /// - Since: JavaApi (Java 1.4)
    public func nextClearBit(_ fromIndex: Int) -> Int {
      precondition(fromIndex >= 0, "fromIndex < 0: \(fromIndex)")
      var wi = BitSet.wordIndex(fromIndex)
      if wi >= words.count { return fromIndex }
      var word = ~words[wi] & (~UInt64(0) << (fromIndex & 63))
      while true {
        if word != 0 { return wi * 64 + word.trailingZeroBitCount }
        wi += 1
        if wi >= words.count { return wi * 64 }
        word = ~words[wi]
      }
    }

    // MARK: - Java 7 additions

    /// Returns the index of the nearest set bit at or before `fromIndex`, or `-1`.
    ///
    /// - Parameter fromIndex: The start index. Pass `Int.max` to start from the end.
    ///   A value of `-1` always returns `-1`.
    /// - Returns: Index of the previous set bit, or `-1` if none.
    /// - Since: JavaApi (Java 7)
    public func previousSetBit(_ fromIndex: Int) -> Int {
      if fromIndex < 0 { return -1 }
      var wi = Swift.min(BitSet.wordIndex(fromIndex), words.count - 1)
      // Mask: only bits up to (fromIndex & 63) within the first word
      let bitPos = fromIndex < (words.count * 64) ? (fromIndex & 63) : 63
      var word = words[wi] & (~UInt64(0) >> (63 - bitPos))
      while true {
        if word != 0 { return wi * 64 + (63 - word.leadingZeroBitCount) }
        if wi == 0 { return -1 }
        wi -= 1
        word = words[wi]
      }
    }

    /// Returns the index of the nearest clear bit at or before `fromIndex`, or `-1`.
    ///
    /// - Parameter fromIndex: The start index. A value of `-1` always returns `-1`.
    /// - Returns: Index of the previous clear bit, or `-1` if none.
    /// - Since: JavaApi (Java 7)
    public func previousClearBit(_ fromIndex: Int) -> Int {
      if fromIndex < 0 { return -1 }
      // Bits beyond the stored range are all clear
      if BitSet.wordIndex(fromIndex) >= words.count { return fromIndex }
      var wi = BitSet.wordIndex(fromIndex)
      let bitPos = fromIndex & 63
      var word = ~words[wi] & (~UInt64(0) >> (63 - bitPos))
      while true {
        if word != 0 { return wi * 64 + (63 - word.leadingZeroBitCount) }
        if wi == 0 { return -1 }
        wi -= 1
        word = ~words[wi]
      }
    }

    /// Returns a `[Int64]` containing all bits in this set (little-endian word order).
    ///
    /// Trailing zero words are omitted. If no bits are set, returns `[]`.
    ///
    /// - Since: JavaApi (Java 7)
    public func toLongArray() -> [Int64] {
      var last = words.count - 1
      while last >= 0 && words[last] == 0 { last -= 1 }
      guard last >= 0 else { return [] }
      return Array(words[0...last]).map { Int64(bitPattern: $0) }
    }

    /// Returns a `[UInt8]` containing all bits in this set (little-endian byte order).
    ///
    /// Trailing zero bytes are omitted. If no bits are set, returns `[]`.
    ///
    /// - Since: JavaApi (Java 7)
    public func toByteArray() -> [UInt8] {
      let longs = toLongArray()
      guard !longs.isEmpty else { return [] }
      var bytes: [UInt8] = []
      bytes.reserveCapacity(longs.count * 8)
      for long in longs {
        let u = UInt64(bitPattern: long)
        bytes.append(UInt8( u        & 0xFF))
        bytes.append(UInt8((u >>  8) & 0xFF))
        bytes.append(UInt8((u >> 16) & 0xFF))
        bytes.append(UInt8((u >> 24) & 0xFF))
        bytes.append(UInt8((u >> 32) & 0xFF))
        bytes.append(UInt8((u >> 40) & 0xFF))
        bytes.append(UInt8((u >> 48) & 0xFF))
        bytes.append(UInt8((u >> 56) & 0xFF))
      }
      while bytes.last == 0 { bytes.removeLast() }
      return bytes
    }

    /// Creates a `BitSet` from a byte array in little-endian order.
    ///
    /// - Parameter bytes: The source bytes (little-endian).
    /// - Returns: A new `BitSet` with bits set according to `bytes`.
    /// - Since: JavaApi (Java 7)
    public static func valueOf(_ bytes: [UInt8]) -> BitSet {
      let bs = BitSet()
      for (i, byte) in bytes.enumerated() {
        let wi = i / 8
        let shift = (i % 8) * 8
        if wi >= bs.words.count {
          bs.words.append(contentsOf: [UInt64](repeating: 0, count: wi - bs.words.count + 1))
        }
        bs.words[wi] |= UInt64(byte) << shift
      }
      return bs
    }

    /// Creates a `BitSet` from an array of `Int64` values in little-endian word order.
    ///
    /// - Parameter longs: The source words.
    /// - Returns: A new `BitSet` with bits set according to `longs`.
    /// - Since: JavaApi (Java 7)
    public static func valueOf(_ longs: [Int64]) -> BitSet {
      let bs = BitSet()
      bs.words = longs.isEmpty ? [0] : longs.map { UInt64(bitPattern: $0) }
      return bs
    }

    // MARK: - Private range helper

    /// Applies `operation(wordIndex, mask)` to every word covered by
    /// `[fromIndex, toIndex)`. The caller is responsible for calling
    /// `ensureCapacity` beforehand when needed.
    private func _applyRangeMask(
      from fromIndex: Int,
      to toIndex: Int,
      _ operation: (Int, UInt64) -> Void
    ) {
      let firstWI = BitSet.wordIndex(fromIndex)
      let lastWI  = BitSet.wordIndex(toIndex - 1)

      if firstWI == lastWI {
        let lo = fromIndex & 63
        let hi = (toIndex - 1) & 63
        let mask = (~UInt64(0) << lo) & (~UInt64(0) >> (63 - hi))
        operation(firstWI, mask)
      } else {
        // First partial word
        operation(firstWI, ~UInt64(0) << (fromIndex & 63))
        // Full middle words
        for wi in (firstWI + 1)..<lastWI {
          operation(wi, ~UInt64(0))
        }
        // Last partial word
        operation(lastWI, ~UInt64(0) >> (63 - ((toIndex - 1) & 63)))
      }
    }

    // MARK: - Object methods

    /// Returns a copy of this `BitSet`.
    /// - Since: JavaApi (Java 1.0)
    public func clone() -> BitSet {
      let copy = BitSet()
      copy.words = self.words
      return copy
    }

    /// Returns `true` if `other` is a `BitSet` with exactly the same bits set.
    /// - Since: JavaApi (Java 1.0)
    public func equals(_ other: BitSet) -> Bool {
      // Compare only up to the length of the longer set; extra words must be 0
      let maxLen = Swift.max(words.count, other.words.count)
      for i in 0..<maxLen {
        let a: UInt64 = i < words.count       ? words[i]       : 0
        let b: UInt64 = i < other.words.count ? other.words[i] : 0
        if a != b { return false }
      }
      return true
    }

    /// Returns a hash code for this bit set.
    /// - Since: JavaApi (Java 1.0)
    public func hashCode() -> Int {
      var hasher = Hasher()
      hasher.combine(words)
      return hasher.finalize()
    }

    /// Returns a string representation, e.g. `{0, 3, 7}`.
    /// - Since: JavaApi (Java 1.0)
    public func toString() -> String {
      return self.description
    }
  }
}
