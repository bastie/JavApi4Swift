/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.util {
  
  /// Base implementation of Stack
  open class Stack<Element> {
    var items: [Element] = []
    public func push(_ item: Element) {
      items.append(item)
    }
    public func pop() -> Element {
      return items.removeLast()
    }
  }
}
