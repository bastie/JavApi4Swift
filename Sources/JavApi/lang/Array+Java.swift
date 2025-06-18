/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Array {
  
  /// This is a mapping of property `count` to property Java named length.
  ///
  /// The property of element size is often used in Java also in Swing. To translate Java code you need not replace the name length.
  @inlinable
  public var length : Int {
    get {
      return self.count
    }
  }
  
  // TODO: make Element == Int more generic
  public init (original : [Element], count newCount: Int) where Element == Int {
    self.init(original)
    switch (newCount - original.count == 0 ? 0 : newCount - original.count > 0 ? 1 : -1) {
    case 0 : return
    case -1 :
      let removeLastTimes = original.count - newCount
      for _ in 0..<removeLastTimes {
        self.removeLast()
      }
    default :
      let addDefaultValueTimes = newCount - original.count
      for _ in 0..<addDefaultValueTimes {
        self.append(0)
      }
    }
  }
  
} 

extension Array where Element: Equatable {
  func indexOf(_ element: Element?, default: Int = -1) -> Int {
    guard let element = element else {
      return -1
    }
    return firstIndex(of: element) ?? `default`
  }
  
  func lastIndexOf(_ element: Element?, default: Int = -1) -> Int {
    guard let element = element else {
      return `default`
    }
    return lastIndex(of: element) ?? `default`
  }
}
