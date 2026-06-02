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

    // MARK: - Size / cardinality

    /// Returns the number of bits in this `BitSet` (always a multiple of 64).
    ///
    /// - Returns: The number of bits of space currently in use.
    /// - Since: JavaApi (Java 1.0)
    public func size() -> Int {
      return words.count * 64
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
