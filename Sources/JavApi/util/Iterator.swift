/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol Iterator<E> : IteratorProtocol {
    associatedtype E

    func hasNext() -> Bool
    
    func next() throws -> E?
    
    func remove()
  }
}
