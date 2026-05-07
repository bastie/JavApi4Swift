/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol Enumeration<Element>: Sequence, IteratorProtocol {
    func hasMoreElements() -> Bool
    mutating func nextElement() -> Element
  }
  
}
