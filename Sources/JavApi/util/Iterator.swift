/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol Iterator<Element> : Sequence, IteratorProtocol {

    func hasNext() -> Bool
    
    // - TODO: should be throws only NoSuchElementException, but it is a big change
    func next() throws (java.util.Throwable) -> Element
    
    // - TODO: should be throws only UnsupportedOperationException and IllegalStateException, but it is a big change
    func remove() throws (java.lang.Throwable)
  }
}
