/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Iterator {
  
  // Brücke: erfüllt IteratorProtocol.next() -> Element?
  // "as Element" disambiguiert explizit zur Java-Variante
  mutating func next() throws (java.util.NoSuchElementException) -> Element? {
    guard hasNext() else {
      throw java.util.NoSuchElementException()
    }
    // hasNext checked so try!
    return (try! next() as Element)
  }
  
  // self ist sein eigener Iterator – wie bei Enumeration
  func makeIterator() -> Self { self }
  
  mutating func remove() throws (java.lang.Throwable){
    fatalError("remove() not supported by this iterator")
  }
}
