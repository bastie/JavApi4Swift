/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  open class AbstractList<E>: AbstractCollection<E>, List<E> where E: Equatable {
    open func add(_ location: Int, _ element: E?) throws { preconditionFailure("\(type(of: self)).add(_:_:) not implemented") }
    open func addAll(_ location: Int, collection: any Collection<E?>) -> Bool { preconditionFailure("\(type(of: self)).addAll(_:collection:) not implemented") }
    open func get(_ location: Int) throws -> E? { preconditionFailure("\(type(of: self)).get(_:) not implemented") }
    open func hashCode() -> Int { preconditionFailure("\(type(of: self)).hashCode() not implemented") }
    open func indexOf(element: Any?) -> Int { preconditionFailure("\(type(of: self)).indexOf(element:) not implemented") }
    open func lastIndexOf(_ element: Any?) -> Int { preconditionFailure("\(type(of: self)).lastIndexOf(_:) not implemented") }
    open func listIterator() -> any java.util.ListIterator<E> { preconditionFailure("\(type(of: self)).listIterator() not implemented") }
    open func listIterator(_ location: Int) -> any java.util.ListIterator<E> { preconditionFailure("\(type(of: self)).listIterator(_:) not implemented") }
    open func remove(_ location: Int) throws -> E? { preconditionFailure("\(type(of: self)).remove(_:) not implemented") }
    open func set(_ location: Int, _ element: E?) throws -> E? { preconditionFailure("\(type(of: self)).set(_:_:) not implemented") }
    open func subList(_ start: Int, _ end: Int) -> any java.util.List { preconditionFailure("\(type(of: self)).subList(_:_:) not implemented") }
  }
}
