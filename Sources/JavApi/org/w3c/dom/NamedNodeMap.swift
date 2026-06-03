/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol NamedNodeMap {
    func getNamedItem(_ name : IDL_DOMString) -> Node
    func setNamedItem(_ newNode : Node) throws (DOMException) -> Node?
    func removeNamedItem(_ name : IDL_DOMString) throws (DOMException) -> Node
    func item(_ index : Node) -> Node?
    func getLength() -> Int
    func getNamedItemNS (_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> Node?
    func setNamedItemNS(_ newNode : Node) throws (DOMException) -> Node?
    func removeNamedItemNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> Node?
  }
}
