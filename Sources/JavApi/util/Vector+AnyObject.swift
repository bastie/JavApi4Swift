/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Vector where E : AnyObject { // ===
  
  
  /// Returns the index of the last occurrence of `elem`, or `-1`.
  public func lastIndexOf(_ elem: E) -> Int {
    withLock {
      for i in stride(from: elementCount - 1, through: 0, by: -1) {
        if elementData[i] === elem { return i }
      }
      return -1
    }
  }
  
  /// Returns the index of the last occurrence of `elem` searching backwards
  /// from `index`, or `-1` if not found.
  ///
  /// - Throws: `Java.lang.IndexOutOfBoundsException` when `index >= size()`.
  public func lastIndexOf(_ elem: E, index: Int) throws -> Int {
    try withLock {
      guard index < elementCount else {
        throw java.lang.IndexOutOfBoundsException("index \(index) >= size \(elementCount)")
      }
      for i in stride(from: index, through: 0, by: -1) {
        if elementData[i] === elem { return i }
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
  public func indexOf(_ elem: E, index: Int) -> Int {
    withLock { _indexOfFirst(elem, from: index) ?? -1 }
  }
  
  /// Returns the index of the first occurrence of `elem`, or `-1`.
  public func indexOf(_ elem: E) -> Int {
    indexOf(elem, index: 0)
  }
  
  // MARK: Private search helper (caller must hold `lock`)
  
  @inline(__always)
  private func _indexOfFirst(_ elem: E, from start: Int) -> Int? {
    for i in start..<elementCount {
      if elementData[i] === elem { return i }
    }
    return nil
  }
  
  /// Returns `true` if this vector contains `elem` (identity `===`).
  public func contains(_ elem: E) -> Bool {
    indexOf(elem) >= 0
  }
  
}
