/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  open class AbstractList<E>: AbstractCollection<E>,List<E> where E: Equatable {
    open func add(_ location : Int, _ element : E?) throws { fatalError("Not implemented") }
    open func addAll(_ location : Int, collection : any Collection<E?>) -> Bool { fatalError("Not implemented") }
    open func get(_ location : Int) throws -> E? { fatalError("Not implemented") }
    open func hashCode() -> Int { fatalError("Not implemented") }
    open func indexOf(element : Any?) -> Int { fatalError("Not implemented") }
    open func lastIndexOf(_ element : Any?) -> Int { fatalError("Not implemented") }
    open func listIterator() -> any java.util.ListIterator<E?> { fatalError("Not implemented") }
    open func listIterator(_ location : Int) -> any java.util.ListIterator<E?> { fatalError("Not implemented") }
    open func remove(_ location : Int) throws -> E? { fatalError("Not implemented") }
    open func set(_ location : Int, _ element : E?) throws -> E? { fatalError("Not implemented") }
    open func subList(_ start : Int, _ end : Int) -> any java.util.List { fatalError("Not implemented") }
    
  }
}
