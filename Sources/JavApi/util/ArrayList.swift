/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  typealias ArrayList<Element> = Swift.Array<Element>
}

extension java.util.ArrayList {
  
  public mutating func add (_ newElement : Element) -> Bool {
    self.append(newElement)
    return true
  }
  
}
