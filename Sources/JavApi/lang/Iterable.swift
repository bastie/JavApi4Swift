/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


public protocol Iterable {
  associatedtype E
  associatedtype IteratorType: IteratorProtocol where IteratorType.Element == E
  func iterator() -> any java.util.Iterator<E>
}
