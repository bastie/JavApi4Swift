/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.util {
  
  /// Base implementation of Stack
  public struct Stack<Element> {
    var items: [Element] = []
    mutating func push(_ item: Element) {
      items.append(item)
    }
    mutating func pop() -> Element {
      return items.removeLast()
    }
  }
}
