/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  /// Base implementation of Stack
  open class Stack<Element> where Element : Equatable {
    public init(){}
    var items: [Element] = []

    /// Add element at end
    ///
    /// - Parameters:
    /// - Parameter e Element to add
    ///
    /// - Returns true if collection is changed
    public func add (_ e : Element) -> Bool {
      let countBefore = items.count
      items.append(e)
      return items.count != countBefore
    }
    /// Add element at end
    ///
    /// - Parameters:
    /// - Parameter e Element to add
    public func addElement (_ e : Element) {
      let _ = self.add(e)
    }
    
    /// Tests if contains no elements
    ///
    /// - Returns true if empty
    public func empty () -> Bool {
      return 0 == self.items.count
    }
    
    /// Tests if contains no elements
    ///
    /// - Returns true if empty
    public func isEmpty () -> Bool {
      return 0 == self.items.count
    }
    
    /// Get last element
    ///
    /// - Returns element
    ///
    /// - Throws if no element is existing an EmptyStackException
    public func peek () throws -> Element {
      guard !self.items.isEmpty else {
        throw Throwable.EmptyStackException()
      }
      return self.items[self.items.count - 1]
    }
    
    /// Get last element and remove it
    ///
    /// - Returns last element
    ///
    /// - Throws if no element is existing an EmptyStackException
    public func pop() throws -> Element {
      guard !self.items.isEmpty else {
        throw Throwable.EmptyStackException ()
      }
      return items.removeLast()
    }

    /// Add element at end
    ///
    /// - Parameters:
    /// - Parameter item Element to add
    ///
    /// - Returns element
    public func push(_ item: Element) -> Element {
      items.append(item)
      return item
    }
    
    
    public func search (_ item: Element) -> Int {
      var result = 0
      for i in 0..<self.items.count {
        result += 1
        if self.items[self.items.count - 1 - i] == item {
          return result
        }
      }
      return -1
    }
  }
}
