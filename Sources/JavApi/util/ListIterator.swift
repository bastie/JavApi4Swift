/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  public protocol ListIterator<E> : Iterator {
    
    func add(_ element : E?)
    func hasPrevious() -> Bool
    func nextIndex() -> Int
    func previous() throws -> E?
    func previousIndex() -> Int
    func set(_ element : E?);
  }
}
