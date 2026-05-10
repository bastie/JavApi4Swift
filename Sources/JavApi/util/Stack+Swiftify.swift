/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Stack {
  /// Get last element
  ///
  /// - Returns element
  ///
  /// - Throws if no element is existing an EmptyStackException
  public func peek ()-> E? {
    guard !self.empty() else {
      return nil
    }
    
    return elementData[elementCount - 1]!
  }
  
  /// Get last element and remove it
  ///
  /// - Returns last element
  ///
  /// - Throws if no element is existing an EmptyStackException
  public func pop() -> E? {
    guard !self.empty() else {
      return nil
    }
    return try! _removeAt(elementCount - 1)
  }
}
