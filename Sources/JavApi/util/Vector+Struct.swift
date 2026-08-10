/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Vector where E : Equatable { // ==
  
  /// Returns the index of the last occurrence of `elem`, or `-1`.
  public func lastIndexOf(_ elem: E) -> Int {
    withLock {
      for i in stride(from: elementCount - 1, through: 0, by: -1) {
        if elementData[i] == elem { return i }
      }
      return -1
    }
  }
  
  /// Returns the index of the last occurrence of `elem` searching backwards
  /// from `index`, or `-1` if not found.
  ///
  /// - Throws: `java.lang.IndexOutOfBoundsException` when `index >= size()`.
  public func lastIndexOf(_ elem: E, _ index: Int) throws -> Int {
    // Read size under lock, then throw outside — avoids `throw` inside `withLock`
    // closure which conflicts with Swift 6.3 typed-throws inference.
    let sz = withLock { elementCount }
    guard index < sz else {
      throw java.lang.IndexOutOfBoundsException("index \(index) >= size \(sz)")
    }
    return withLock {
      for i in stride(from: Swift.min(index, elementCount - 1), through: 0, by: -1) {
        if elementData[i] == elem { return i }
      }
      return -1
    }
  }
  
  /// Removes the first occurrence of `obj` from this vector (identity `===`).
  ///
  /// - Returns: `true` if the vector contained `obj`.
  @discardableResult
  public func removeElement(_ obj: E) -> Bool {
    withLock {
      guard let idx = _indexOfFirst(obj, from: 0) else { return false }
      _ = try? _removeAt(idx)
      return true
    }
  }
  
  
  /// Removes the first occurrence of `obj` (Collection-interface alias).
  @discardableResult
  public func remove(_ obj: E) -> Bool {
    removeElement(obj)
  }
  
  /// Returns the index of the first occurrence of `elem` at or after `index`,
  /// or `-1` if not found.
  public func indexOf(_ elem: E, _ index: Int) -> Int {
    withLock { _indexOfFirst(elem, from: index) ?? -1 }
  }

  /// Returns the index of the first occurrence of `elem`, or `-1`.
  public func indexOf(_ elem: E) -> Int {
    indexOf(elem, 0)
  }
  
  /// Returns `true` if this vector contains `elem` (identity `===`).
  public func contains(_ elem: E) -> Bool {
    indexOf(elem) >= 0
  }
  
  
  // MARK: Private search helper (caller must hold `lock`)
  
  @inline(__always)
  private func _indexOfFirst(_ elem: E, from start: Int) -> Int? {
    guard start >= 0, start < elementCount else { return nil }
    for i in start..<elementCount {
      if elementData[i] == elem { return i }
    }
    return nil
  }
  
  
}

