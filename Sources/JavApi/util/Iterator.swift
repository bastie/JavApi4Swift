/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol Iterator<Element> : Sequence, IteratorProtocol {

    func hasNext() -> Bool
    
    func next() throws (java.util.NoSuchElementException) -> Element
    
    func remove() throws (java.lang.IllegalStateException)
  }
}
