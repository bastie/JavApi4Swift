/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Swift-friendly extensions for java.util.Arrays.
// These are NOT part of the Java API — they exist to make Arrays ergonomic
// in Swift code that does not want to implement a full Comparator object.
// Java-compatible ports must use Arrays.sort(_:_:) with a Comparator object
// from Arrays.swift.

extension java.util.Arrays {

  /// Sorts the entire array using a Swift closure that returns an `Int`
  /// (`< 0` = ascending, `0` = equal, `> 0` = descending).
  ///
  /// - Note: **Not part of the Java API.** Use `Arrays.sort(_:_:)` with a
  ///   `Comparator` object for Java-compatible code.
  public static func sort<T>(_ a: inout [T], by comparator: (T, T) -> Int) {
    a.sort { comparator($0, $1) < 0 }
  }

  /// Sorts the subrange `[fromIndex, toIndex)` using a Swift closure.
  ///
  /// - Note: **Not part of the Java API.**
  public static func sort<T>(
    _ a: inout [T], _ fromIndex: Int, _ toIndex: Int, by comparator: (T, T) -> Int
  ) {
    let sub = a[fromIndex..<toIndex].sorted { comparator($0, $1) < 0 }
    for (i, v) in sub.enumerated() { a[fromIndex + i] = v }
  }
}
