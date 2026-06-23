/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Swift Set → Java bridge

extension Swift.Set {

  /// Returns a `java.util.ArrayList` containing all elements of this set
  /// in an unspecified order.
  ///
  /// ```swift
  /// let list = Swift.Set(["a", "b", "c"]).toJavaArrayList()
  /// ```
  public func toJavaArrayList() -> java.util.ArrayList<Element> where Element: Equatable {
    java.util.ArrayList(from: Array(self))
  }
}

// MARK: - java.util.Collection → Swift bridges
//
// These are free functions rather than protocol extensions because
// java.util.Collection uses an associated type (E) and existential
// types (`any java.util.Collection`) cannot currently carry per-element
// constraints in Swift 6. Use the concrete-type extensions on ArrayList
// and HashMap+Swiftify for the common case.

/// Copies all elements of any `java.util.Collection` into a new Swift `Array`,
/// dropping `nil` slots.
///
/// ```swift
/// let arr: [Int] = toSwiftArray(javaList)
/// ```
public func toSwiftArray<C: java.util.Collection>(_ collection: C) -> [C.E] {
  var result: [C.E] = []
  let it = collection.iterator()
  while it.hasNext() {
    if let v = try? it.next() {
      result.append(v)
    }
  }
  return result
}

/// Copies all elements of any `java.util.Collection` into a new Swift `Set`.
/// Requires `E: Hashable`.
///
/// ```swift
/// let set: Swift.Set<String> = toSwiftSet(javaHashSet)
/// ```
public func toSwiftSet<C: java.util.Collection>(_ collection: C) -> Swift.Set<C.E>
  where C.E: Hashable
{
  var result = Swift.Set<C.E>()
  let it = collection.iterator()
  while it.hasNext() {
    if let v = try? it.next() {
      result.insert(v)
    }
  }
  return result
}
