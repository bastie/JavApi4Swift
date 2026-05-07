/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Enumeration {
  
  // IteratorProtocol.next()  ←  Java hasMoreElements() + nextElement()
  mutating func next() -> Element? {
    guard hasMoreElements() else { return nil }
    return nextElement()
  }
  
  // Sequence.makeIterator()  →  self ist gleichzeitig der Iterator
  func makeIterator() -> Self { self }
}
