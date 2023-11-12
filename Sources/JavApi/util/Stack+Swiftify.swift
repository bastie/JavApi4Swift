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
  public func peek ()-> Element? {
    guard !self.items.isEmpty else {
      return nil
    }
    return self.items[self.items.count - 1]
  }
  
  /// Get last element and remove it
  ///
  /// - Returns last element
  ///
  /// - Throws if no element is existing an EmptyStackException
  public func pop() -> Element? {
    guard !self.items.isEmpty else {
      return nil
    }
    return items.removeLast()
  }
}
