/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol Element : Node {
    func getTagName() -> IDL_DOMString
    func getAttribute(_ name : IDL_DOMString) -> IDL_DOMString
    func setAttribute(_ name : IDL_DOMString, _ value : IDL_DOMString) throws (DOMException)
    func removeAttribute(_ name : IDL_DOMString) throws (DOMException)
    func getAttributeNode(_ name : IDL_DOMString) -> Attr?
    func setAttributeNode(_ newAttr : Attr) throws (DOMException) -> Attr?
    func removeAttributeNode(_ oldAttr : Attr) throws (DOMException) -> Attr
    func getElementsByTagName(_ name : IDL_DOMString) -> NodeList
    func getAttributeNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> IDL_DOMString
    func setAttributeNS(_ namespaceURI : IDL_DOMString, _ qualifiedName : IDL_DOMString, _ value : IDL_DOMString) throws (DOMException)
    func removeAttributeNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException)
    func getAttributeNodeNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> Attr?
    func setAttributeNodeNS(_ newAttr : Attr) throws (DOMException) -> Attr?;
    func getElementsByTagNameNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> NodeList
    func hasAttribute(String name : IDL_DOMString) -> IDL_boolean
    func hasAttributeNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) throws (DOMException) -> IDL_boolean
    func getSchemaTypeInfo() -> TypeInfo
    func setIdAttribute(_ name : IDL_DOMString, _ isId : IDL_boolean) throws (DOMException)
    func setIdAttributeNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString, _ isId : IDL_boolean) throws (DOMException)
    func setIdAttributeNode(_ idAttr : Attr, _ isId : IDL_boolean) throws (DOMException)
  }
}
