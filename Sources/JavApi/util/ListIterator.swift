/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  public protocol ListIterator<Element> : Iterator {
    
    func add(_ element : Element?)
    func hasPrevious() -> Bool
    func nextIndex() -> Int
    func previous() throws -> Element?
    func previousIndex() -> Int
    func set(_ element : Element?);
  }
}
