/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A utility class of static methods for operating on objects.
  ///
  /// All methods are null-safe (nil-safe in Swift): they either accept nil
  /// arguments gracefully or throw a descriptive exception.
  ///
  /// This type is deliberately uninstantiable — it mirrors the design of
  /// Java's `final class Objects` which has only a private constructor.
  ///
  /// - Since: Java 7
  public enum Objects {

    // MARK: - Java 7

    /// Returns `true` if `a` and `b` are both `nil`, or `a == b`.
    ///
    /// Equivalent to Java's `Objects.equals(Object a, Object b)`.
    ///
    /// - Since: Java 7
    public static func equals<T: Equatable>(_ a: T?, _ b: T?) -> Bool {
      a == b
    }

    /// Returns `true` if the two arguments are deeply equal.
    ///
    /// `nil` arguments are considered equal to each other but not to any
    /// non-nil value.  For arrays, element-wise deep comparison is performed.
    /// For all other types, `equals(_:_:)` is used.
    ///
    /// - Since: Java 7
    public static func deepEquals(_ a: Any?, _ b: Any?) -> Bool {
      switch (a, b) {
      case (nil, nil):
        return true
      case (nil, _), (_, nil):
        return false
      default:
        break
      }
      // Array deep comparison via AnyHashable bridging
      if let aArr = a as? [AnyHashable], let bArr = b as? [AnyHashable] {
        guard aArr.count == bArr.count else { return false }
        return Swift.zip(aArr, bArr).allSatisfy { deepEquals($0, $1) }
      }
      if let aHash = a as? AnyHashable, let bHash = b as? AnyHashable {
        return aHash == bHash
      }
      return false
    }

    /// Returns the hash code of `o`, or `0` if `o` is `nil`.
    ///
    /// Equivalent to Java's `Objects.hashCode(Object o)`.
    ///
    /// - Since: Java 7
    public static func hashCode<T: Hashable>(_ o: T?) -> Int {
      o?.hashValue ?? 0
    }

    /// Returns a hash code for a sequence of values.
    ///
    /// The values are fed into a `Hasher` in order; `nil` entries contribute
    /// `0`.  This is designed for use in `hashCode()` implementations:
    ///
    /// ```swift
    /// func myHash() -> Int {
    ///   java.util.Objects.hash(field1, field2, field3)
    /// }
    /// ```
    ///
    /// Equivalent to Java's `Objects.hash(Object... values)`.
    ///
    /// - Since: Java 7
    public static func hash(_ values: (any Hashable)?...) -> Int {
      var hasher = Hasher()
      for value in values {
        if let value {
          value.hash(into: &hasher)
        } else {
          hasher.combine(0)
        }
      }
      return hasher.finalize()
    }

    /// Returns the string representation of `o`.
    ///
    /// Returns `"null"` if `o` is `nil`; otherwise `String(describing: o)`.
    ///
    /// Equivalent to Java's `Objects.toString(Object o)`.
    ///
    /// - Since: Java 7
    public static func toString(_ o: Any?) -> String {
      guard let o else { return "null" }
      return String(describing: o)
    }

    /// Returns the string representation of `o`, or `nullDefault` if `nil`.
    ///
    /// Equivalent to Java's `Objects.toString(Object o, String nullDefault)`.
    ///
    /// - Since: Java 7
    public static func toString(_ o: Any?, _ nullDefault: String) -> String {
      guard let o else { return nullDefault }
      return String(describing: o)
    }

    /// Compares two objects using the given comparator.
    ///
    /// If both arguments are the same reference (or both nil), returns `0`.
    /// Otherwise delegates to `comparator.compare(a, b)`.
    ///
    /// Equivalent to Java's `Objects.compare(T a, T b, Comparator<? super T> c)`.
    ///
    /// - Since: Java 7
    public static func compare<T>(_ a: T, _ b: T, _ comparator: any java.util.Comparator<T>) -> Int {
      comparator.compare(a, b)
    }

    /// Returns `obj` if it is not `nil`.
    ///
    /// - Throws: `NullPointerException` if `obj` is `nil`.
    /// - Returns: `obj` (non-optional) when non-nil.
    ///
    /// Equivalent to Java's `Objects.requireNonNull(T obj)`.
    ///
    /// - Since: Java 7
    @discardableResult
    public static func requireNonNull<T>(_ obj: T?) throws -> T {
      guard let obj else { throw NullPointerException() }
      return obj
    }

    /// Returns `obj` if it is not `nil`.
    ///
    /// - Parameter message: The message for the `NullPointerException`.
    /// - Throws: `NullPointerException` with `message` if `obj` is `nil`.
    ///
    /// Equivalent to Java's `Objects.requireNonNull(T obj, String message)`.
    ///
    /// - Since: Java 7
    @discardableResult
    public static func requireNonNull<T>(_ obj: T?, _ message: String) throws -> T {
      guard let obj else { throw NullPointerException(message) }
      return obj
    }

    // MARK: - Java 8

    /// Returns `true` if `obj` is `nil`.
    ///
    /// Primarily useful as a method reference in filter operations.
    ///
    /// Equivalent to Java's `Objects.isNull(Object obj)`.
    ///
    /// - Since: Java 8
    public static func isNull(_ obj: Any?) -> Bool {
      obj == nil
    }

    /// Returns `true` if `obj` is not `nil`.
    ///
    /// Primarily useful as a method reference in filter operations.
    ///
    /// Equivalent to Java's `Objects.nonNull(Object obj)`.
    ///
    /// - Since: Java 8
    public static func nonNull(_ obj: Any?) -> Bool {
      obj != nil
    }

    // MARK: - Java 9

    /// Returns `obj` if non-nil; otherwise returns `defaultObj`.
    ///
    /// - Throws: `NullPointerException` if both `obj` and `defaultObj` are `nil`.
    ///
    /// Equivalent to Java's `Objects.requireNonNullElse(T obj, T defaultObj)`.
    ///
    /// - Since: Java 9
    public static func requireNonNullElse<T>(_ obj: T?, _ defaultObj: T) -> T {
      obj ?? defaultObj
    }

    /// Returns `obj` if non-nil; otherwise invokes `supplier` and returns its result.
    ///
    /// - Throws: `NullPointerException` if both `obj` and the supplier result are `nil`.
    ///
    /// Equivalent to Java's `Objects.requireNonNullElseGet(T obj, Supplier<? extends T> supplier)`.
    ///
    /// - Since: Java 9
    public static func requireNonNullElseGet<T>(_ obj: T?, _ supplier: () -> T) -> T {
      obj ?? supplier()
    }

    /// Returns `obj` if non-nil; the exception message is supplied lazily.
    ///
    /// - Parameter messageSupplier: Called only when `obj` is `nil` to produce
    ///   the `NullPointerException` message.
    /// - Throws: `NullPointerException` with the supplied message if `obj` is `nil`.
    ///
    /// Equivalent to Java's `Objects.requireNonNull(T obj, Supplier<String> messageSupplier)`.
    ///
    /// - Since: Java 9
    @discardableResult
    public static func requireNonNull<T>(_ obj: T?, _ messageSupplier: () -> String) throws -> T {
      guard let obj else { throw NullPointerException(messageSupplier()) }
      return obj
    }

    /// Checks that `index` is a valid index for a range of length `length`.
    ///
    /// A valid index satisfies `0 <= index < length`.
    ///
    /// - Returns: `index` if valid.
    /// - Throws: `IndexOutOfBoundsException` if `index < 0 || index >= length`.
    ///
    /// Equivalent to Java's `Objects.checkIndex(int index, int length)`.
    ///
    /// - Since: Java 9
    @discardableResult
    public static func checkIndex(_ index: Int, _ length: Int) throws -> Int {
      guard index >= 0, length >= 0, index < length else {
        throw IndexOutOfBoundsException(
          "Range [\(index), \(index) + 1) out of bounds for length \(length)")
      }
      return index
    }

    /// Checks that `[fromIndex, toIndex)` is a valid sub-range of `[0, length)`.
    ///
    /// - Returns: `fromIndex` if valid.
    /// - Throws: `IndexOutOfBoundsException` if the sub-range is invalid.
    ///
    /// Equivalent to Java's `Objects.checkFromToIndex(int fromIndex, int toIndex, int length)`.
    ///
    /// - Since: Java 9
    @discardableResult
    public static func checkFromToIndex(_ fromIndex: Int, _ toIndex: Int, _ length: Int) throws -> Int {
      guard fromIndex >= 0, toIndex >= fromIndex, toIndex <= length else {
        throw IndexOutOfBoundsException(
          "Range [\(fromIndex), \(toIndex)) out of bounds for length \(length)")
      }
      return fromIndex
    }

    /// Checks that `[fromIndex, fromIndex + size)` is a valid sub-range of `[0, length)`.
    ///
    /// - Returns: `fromIndex` if valid.
    /// - Throws: `IndexOutOfBoundsException` if the sub-range is invalid.
    ///
    /// Equivalent to Java's `Objects.checkFromIndexSize(int fromIndex, int size, int length)`.
    ///
    /// - Since: Java 9
    @discardableResult
    public static func checkFromIndexSize(_ fromIndex: Int, _ size: Int, _ length: Int) throws -> Int {
      guard fromIndex >= 0, size >= 0, length >= 0, size <= length - fromIndex else {
        throw IndexOutOfBoundsException(
          "Range [\(fromIndex), \(fromIndex) + \(size)) out of bounds for length \(length)")
      }
      return fromIndex
    }

    // MARK: - Java 16 (long overloads)

    /// `checkIndex` for 64-bit indices.
    ///
    /// Equivalent to Java's `Objects.checkIndex(long index, long length)`.
    ///
    /// - Since: Java 16
    @discardableResult
    public static func checkIndex(_ index: Int64, _ length: Int64) throws -> Int64 {
      guard index >= 0, length >= 0, index < length else {
        throw IndexOutOfBoundsException(
          "Range [\(index), \(index) + 1) out of bounds for length \(length)")
      }
      return index
    }

    /// `checkFromToIndex` for 64-bit indices.
    ///
    /// Equivalent to Java's `Objects.checkFromToIndex(long fromIndex, long toIndex, long length)`.
    ///
    /// - Since: Java 16
    @discardableResult
    public static func checkFromToIndex(_ fromIndex: Int64, _ toIndex: Int64, _ length: Int64) throws -> Int64 {
      guard fromIndex >= 0, toIndex >= fromIndex, toIndex <= length else {
        throw IndexOutOfBoundsException(
          "Range [\(fromIndex), \(toIndex)) out of bounds for length \(length)")
      }
      return fromIndex
    }

    /// `checkFromIndexSize` for 64-bit indices.
    ///
    /// Equivalent to Java's `Objects.checkFromIndexSize(long fromIndex, long size, long length)`.
    ///
    /// - Since: Java 16
    @discardableResult
    public static func checkFromIndexSize(_ fromIndex: Int64, _ size: Int64, _ length: Int64) throws -> Int64 {
      guard fromIndex >= 0, size >= 0, length >= 0, size <= length - fromIndex else {
        throw IndexOutOfBoundsException(
          "Range [\(fromIndex), \(fromIndex) + \(size)) out of bounds for length \(length)")
      }
      return fromIndex
    }
  }
}
