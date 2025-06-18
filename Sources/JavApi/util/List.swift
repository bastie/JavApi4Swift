/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  public protocol List<E> : Collection where E : Equatable {
    associatedtype E
    
    func add(_ location : Int, _ element : E?)
    func addAll(_ location : Int, collection : any Collection<E?>) -> Bool
    func get(_ location : Int) -> E?
    func hashCode() -> Int
    func indexOf(element : Any?) -> Int
    func lastIndexOf(_ element : Any?) -> Int
    func listIterator() -> any java.util.ListIterator<E?>
    func listIterator(_ location : Int) -> any java.util.ListIterator<E?>
    func remove(_ location : Int) -> E?
    func set(_ location : Int, _ element : E?) -> E?
    func subList(_ start : Int, _ end : Int) -> any java.util.List
  }
}
