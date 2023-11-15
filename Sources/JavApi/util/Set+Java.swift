/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension Set {
  
  public mutating func add (_ newElement : Element) -> Bool{
    let result = self.insert(newElement)
    return result.inserted
  }
}
