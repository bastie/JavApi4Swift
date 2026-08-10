/*
 * SPDX-FileCopyrightText: 2023,2024,2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - JavaArrayElement

/// Internal protocol that provides the zero/default value used by `Arrays.copyOf`
/// when padding a new array that is longer than the original.
///
/// In Java, `Arrays.copyOf(int[], int)` pads with `0`, `double[]` with `0.0`,
/// `boolean[]` with `false`, and reference arrays with `null`. Swift has no
/// primitives — every numeric type is already a value type — so we achieve the
/// same behaviour via this protocol instead of maintaining one overload per type.
///
/// Conformances are provided for every Swift numeric type that maps to a Java
/// primitive, plus `Bool` (→ `boolean`) and `Character` (→ `char`).
/// Reference-type arrays store optionals (`[T?]`) whose default is `nil`.
public protocol _JavaArrayElement {
  static var _javaDefault: Self { get }
}

// Signed integers
extension Int:   _JavaArrayElement { public static var _javaDefault: Int   { 0 } }
extension Int8:  _JavaArrayElement { public static var _javaDefault: Int8  { 0 } }
extension Int16: _JavaArrayElement { public static var _javaDefault: Int16 { 0 } }
extension Int32: _JavaArrayElement { public static var _javaDefault: Int32 { 0 } }
extension Int64: _JavaArrayElement { public static var _javaDefault: Int64 { 0 } }
// Unsigned integers (Java has no unsigned primitives, but they appear in Swift ports)
extension UInt:   _JavaArrayElement { public static var _javaDefault: UInt   { 0 } }
extension UInt8:  _JavaArrayElement { public static var _javaDefault: UInt8  { 0 } }
extension UInt16: _JavaArrayElement { public static var _javaDefault: UInt16 { 0 } }
extension UInt32: _JavaArrayElement { public static var _javaDefault: UInt32 { 0 } }
extension UInt64: _JavaArrayElement { public static var _javaDefault: UInt64 { 0 } }
// Floating-point (Java: float / double)
extension Float:  _JavaArrayElement { public static var _javaDefault: Float  { 0.0 } }
extension Double: _JavaArrayElement { public static var _javaDefault: Double { 0.0 } }
// Other primitives
extension Bool:      _JavaArrayElement { public static var _javaDefault: Bool      { false } }
extension Character: _JavaArrayElement { public static var _javaDefault: Character { "\0" } }

extension java.util {

  /// Utility type to work with Arrays — mirrors `java.util.Arrays`.
  public class Arrays {

    // MARK: - sort

    /// Sorts the entire array into ascending natural order.
    public static func sort<T: Comparable>(_ a: inout [T]) {
      a.sort()
    }

    /// Sorts the subrange `[fromIndex, toIndex)` into ascending natural order.
    /// Indices outside the subrange are unchanged.
    public static func sort<T: Comparable>(_ a: inout [T], _ fromIndex: Int, _ toIndex: Int) {
      let sub = a[fromIndex..<toIndex].sorted()
      for (i, v) in sub.enumerated() {
        a[fromIndex + i] = v
      }
    }

    /// Sorts the entire array using the given `Comparator` object.
    /// Mirrors `Arrays.sort(T[], Comparator<? super T>)`.
    public static func sort<T, C: java.util.Comparator>(_ a: inout [T], _ comparator: C) where C.T == T {
      a.sort { comparator.compare($0, $1) < 0 }
    }

    // MARK: - fill

    /// Fills the entire array with `val`.
    public static func fill<T>(_ a: inout [T], _ val: T) {
      for i in a.indices { a[i] = val }
    }

    /// Fills the subrange `[fromIndex, toIndex)` with `val`.
    public static func fill<T>(_ a: inout [T], _ fromIndex: Int, _ toIndex: Int, _ val: T) {
      for i in fromIndex..<toIndex { a[i] = val }
    }

    // Note: no separate Int overload needed — [Int] satisfies _JavaArrayElement via
    // the generic fill<T>. The old explicit overload is removed to avoid ambiguity.

    // MARK: - copyOf

    /// Returns a new array of length `newLength` copied from `original`.
    /// Truncates if shorter; pads with the type's Java default value if longer.
    ///
    /// Works for every Swift type that conforms to `_JavaArrayElement`:
    /// `Int`, `Int8`, `Int16`, `Int32`, `Int64`, `UInt`, `UInt8` … `UInt64`,
    /// `Float`, `Double`, `Bool`, `Character`.
    /// This single generic replaces Java's separate primitive overloads
    /// (`copyOf(int[],int)`, `copyOf(long[],int)`, `copyOf(double[],int)`, …).
    public static func copyOf<T: _JavaArrayElement>(_ original: [T], _ newLength: Int) -> [T] {
      if newLength <= original.count {
        return Array(original.prefix(newLength))
      }
      return original + [T](repeating: T._javaDefault, count: newLength - original.count)
    }

    // MARK: - copyOfRange

    /// Returns elements `[fromIndex, toIndex)` from `a` as a new array.
    ///
    /// Generic — works for every `_JavaArrayElement` type without separate
    /// overloads for `int[]`, `byte[]`, `double[]`, etc.
    public static func copyOfRange<T: _JavaArrayElement>(
      _ a: [T], _ fromIndex: Int, _ toIndex: Int
    ) -> [T] {
      Array(a[fromIndex..<toIndex])
    }

    // MARK: - equals

    /// Returns `true` when both optional `[UInt8]` arrays are equal (or both nil).
    public static func equals(_ actual: [UInt8]?, _ identical: [UInt8]?) -> Bool {
      switch (actual, identical) {
      case (.none, .none): return true
      case (.some(let a), .some(let b)): return equals(a, b)
      default: return false
      }
    }

    /// Returns `true` when the two `[UInt8]` arrays have identical content.
    public static func equals(_ actual: [UInt8], _ identical: [UInt8]) -> Bool {
      guard actual.count == identical.count else { return false }
      return Swift.zip(actual, identical).allSatisfy { $0 == $1 }
    }

    /// Cross-type equals: [UInt8] vs [Int] — true when every value is equal after widening.
    public static func equals(_ actual: [UInt8]?, _ identical: [Int]?) -> Bool {
      switch (actual, identical) {
      case (.none, .none): return true
      case (.some(let a), .some(let b)): return equals(a, b)
      default: return false
      }
    }

    public static func equals(_ actual: [UInt8], _ identical: [Int]) -> Bool {
      guard actual.count == identical.count else { return false }
      return Swift.zip(actual, identical).allSatisfy { Int($0) == $1 }
    }

    public static func equals(_ actual: [Int]?, _ identical: [UInt8]?) -> Bool {
      return equals(identical, actual)
    }

    public static func equals(_ actual: [Int], _ identical: [UInt8]) -> Bool {
      return equals(identical, actual)
    }

    /// Generic equals for any `Equatable` element type.
    public static func equals<T: Equatable>(_ actual: [T], _ identical: [T]) -> Bool {
      guard actual.count == identical.count else { return false }
      return Swift.zip(actual, identical).allSatisfy { $0 == $1 }
    }

    // MARK: - binarySearch

    /// Standard binary search on a sorted array — Java semantics:
    /// returns the index if found, or `-(insertion point) - 1` if not found.
    public static func binarySearch<T: Comparable>(_ a: [T], _ key: T) -> Int {
      var lo = 0, hi = a.count - 1
      while lo <= hi {
        let mid = lo + (hi - lo) / 2
        if a[mid] == key { return mid }
        if a[mid] < key { lo = mid + 1 } else { hi = mid - 1 }
      }
      return -(lo + 1)
    }

    /// Binary search over subrange `[fromIndex, toIndex)`.
    public static func binarySearch<T: Comparable>(
      _ a: [T], _ fromIndex: Int, _ toIndex: Int, _ key: T
    ) -> Int {
      var lo = fromIndex, hi = toIndex - 1
      while lo <= hi {
        let mid = lo + (hi - lo) / 2
        if a[mid] == key { return mid }
        if a[mid] < key { lo = mid + 1 } else { hi = mid - 1 }
      }
      return -(lo + 1)
    }

    /// Legacy predicate-based search (kept for source compatibility).
    public static func binarySearch(_ a: [Any], _ predicate: (Any) -> Bool) -> Int {
      do {
        return try a.binarySearch(predicate: predicate)
      } catch {
        return -1
      }
    }

    // MARK: - toString

    /// Returns a string representation like `[1, 2, 3]`.
    public static func toString<T>(_ a: [T]) -> String {
      "[" + a.map { "\($0)" }.joined(separator: ", ") + "]"
    }

    /// Returns `"null"` for nil, otherwise `[…]`.
    public static func toString<T>(_ a: [T]?) -> String {
      guard let a else { return "null" }
      return toString(a)
    }

    // MARK: - asList

    /// Returns a fixed-size `ArrayList` backed by the given elements.
    /// Mirrors `Arrays.asList(T... a)` — the primary bridge between arrays and
    /// the Collections framework.
    ///
    /// - Note: In Java the returned list is fixed-size (structural modification
    ///   throws `UnsupportedOperationException`). Here we return a regular
    ///   `ArrayList` for simplicity; size restriction is not enforced.
    public static func asList<T: Equatable>(_ elements: T...) -> java.util.ArrayList<T> {
      let list = java.util.ArrayList<T>()
      for e in elements { _ = try? list.add(e) }
      return list
    }

    // MARK: - deepEquals

    /// Returns `true` when both arrays are deeply equal, recursively comparing
    /// nested arrays. Mirrors `java.util.Arrays.deepEquals(Object[], Object[])` (Java 5).
    public static func deepEquals(_ a1: [Any?]?, _ a2: [Any?]?) -> Bool {
      switch (a1, a2) {
      case (nil, nil): return true
      case (nil, _), (_, nil): return false
      default: break
      }
      let a = a1!, b = a2!
      guard a.count == b.count else { return false }
      for i in 0..<a.count {
        if !_deepElementEquals(a[i], b[i]) { return false }
      }
      return true
    }

    private static func _deepElementEquals(_ a: Any?, _ b: Any?) -> Bool {
      switch (a, b) {
      case (nil, nil): return true
      case (nil, _), (_, nil): return false
      case (let x as [Any?], let y as [Any?]): return deepEquals(x, y)
      case (let x as AnyHashable, let y as AnyHashable): return x == y
      default: return false
      }
    }

    // MARK: - deepHashCode

    /// Returns a hash code based on the deep contents of `a`.
    /// Mirrors `java.util.Arrays.deepHashCode(Object[])` (Java 5).
    public static func deepHashCode(_ a: [Any?]?) -> Int {
      guard let a else { return 0 }
      var result = 1
      for element in a {
        let h = _deepElementHash(element)
        result = 31 &* result &+ h
      }
      return result
    }

    private static func _deepElementHash(_ element: Any?) -> Int {
      guard let element else { return 0 }
      switch element {
      case let sub as [Any?]: return deepHashCode(sub)
      case let h as AnyHashable: return h.hashValue
      default: return 0
      }
    }

    // MARK: - hashCode (generic)

    /// Returns a hash code for the given array of `Hashable` elements.
    /// Uses the same 31-multiplier algorithm as `java.util.Arrays.hashCode`.
    public static func hashCode<T: Hashable>(_ a: [T]) -> Int {
      var result = 1
      for element in a {
        result = 31 &* result &+ element.hashValue
      }
      return result
    }

    // MARK: - setAll / parallelSetAll

    /// Sets each element using the provided generator function.
    ///
    /// Matches `java.util.Arrays.setAll(T[], IntUnaryOperator)` (Java 8).
    public static func setAll<T>(_ array: inout [T], _ generator: (Int) -> T) {
      for i in array.indices { array[i] = generator(i) }
    }

    /// Sets each element using the provided generator — same as `setAll` (no
    /// real parallelism on Swift's single-threaded value-type arrays).
    ///
    /// Matches `java.util.Arrays.parallelSetAll(T[], IntUnaryOperator)` (Java 8).
    public static func parallelSetAll<T>(_ array: inout [T], _ generator: (Int) -> T) {
      setAll(&array, generator)
    }

    // FIXME: - parallelSort is not really parallel but it works today

    /// Sorts the entire array. Delegates to `sort` (no real parallelism needed
    /// for Swift arrays; API parity with `java.util.Arrays.parallelSort`).
    public static func parallelSort<T: Comparable>(_ a: inout [T]) {
      a.sort()
    }

    /// Sorts the subrange `[fromIndex, toIndex)`. Delegates to `sort`.
    public static func parallelSort<T: Comparable>(
      _ a: inout [T], _ fromIndex: Int, _ toIndex: Int
    ) {
      sort(&a, fromIndex, toIndex)
    }

    // MARK: - parallelPrefix

    /// Applies `op` cumulatively so that `a[i] = op(a[i-1], a[i])` for each `i > 0`.
    ///
    /// Matches `java.util.Arrays.parallelPrefix(T[], BinaryOperator<T>)` (Java 8).
    public static func parallelPrefix<T>(_ array: inout [T], _ op: (T, T) -> T) {
      guard array.count > 1 else { return }
      for i in 1..<array.count { array[i] = op(array[i - 1], array[i]) }
    }

    /// Applies `op` cumulatively over `[fromIndex, toIndex)`.
    ///
    /// Matches `java.util.Arrays.parallelPrefix(T[], int, int, BinaryOperator<T>)` (Java 8).
    public static func parallelPrefix<T>(
      _ array: inout [T], _ fromIndex: Int, _ toIndex: Int, _ op: (T, T) -> T
    ) {
      guard fromIndex < toIndex, toIndex <= array.count, fromIndex + 1 < toIndex else { return }
      for i in (fromIndex + 1)..<toIndex { array[i] = op(array[i - 1], array[i]) }
    }

    // MARK: - deepToString

    /// Recursive string representation for nested arrays.
    /// Handles `[[Any]]` one level deep; for deeper nesting call recursively.
    public static func deepToString(_ a: [Any?]) -> String {
      let parts = a.map { element -> String in
        switch element {
        case nil:
          return "null"
        case let sub as [Any?]:
          return deepToString(sub)
        case let v?:
          return "\(v)"
        }
      }
      return "[" + parts.joined(separator: ", ") + "]"
    }
  }
}
