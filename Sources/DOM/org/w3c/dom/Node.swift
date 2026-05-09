/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  
  /// - SeeAlso: https://www.w3.org/TR/DOM-Level-3-Core/idl-definitions.html
  public protocol Node {
    
    var nodeName: IDL_DOMString { get }
    func getNodeName() -> IDL_DOMString
    
    var nodeValue: IDL_DOMString? { get set }
    func getNodeValue() throws (DOMException) -> IDL_DOMString?
    func setNodeValue(_ nodeValue: IDL_DOMString) throws (DOMException)
    
    var nodeType: NodeType { get }
    func getNodeType() -> NodeType
    
    var parentNode: Node? { get }
    func getParentNode() -> Node?
    
    var childNodes: NodeList { get }
    func getChildNodes() -> NodeList
    
    var firstChild: Node? { get }
    func getFirstChild() -> Node?
    var lastChild: Node? { get }
    func getLastChild() -> Node?
    
    var previousSibling: Node? { get }
    func getPreviousSibling() -> Node?
    var nextSibling: Node? { get }
    func getNextSibling() -> Node?
    
    var attributes: NamedNodeMap? { get }
    func getAttributes() -> NamedNodeMap?
    
    var ownerDocument: Document? { get }
    func getOwnerDocument() -> Document?
    
    func insertBefore(_ newChild: Node, _ refChild: Node?) throws (DOMException) -> Node?
    func replaceChild(_ newChild: Node, _ oldChild: Node) throws (DOMException) -> Node?
    func removeChild(_ child: Node) throws (DOMException) -> Node?
    func appendChild(_ newChild: Node) throws (DOMException) -> Node?
    func hasChildNodes() -> Bool
    
    func cloneNode(_ deep: Bool) -> Node
    func normalize()
    func isSupported(_ feature: IDL_DOMString, _ version: IDL_DOMString) -> Bool
    
    var namespaceURI: IDL_DOMString? { get }
    func getNamespaceURI() -> IDL_DOMString?
    
    var prefix: IDL_DOMString? { get set }
    func getPrefix() -> IDL_DOMString?
    func setPrefix(_ prefix: IDL_DOMString?) throws (DOMException)
    
    var localName: IDL_DOMString? { get }
    func getLocalName() -> IDL_DOMString?
    
    func hasAttributes() -> Bool
    
    var baseURI: IDL_DOMString? { get }
    func getBaseURI() -> IDL_DOMString?
    func compareDocumentPosition(_ other: Node) throws (DOMException) -> DocumentPosition
    
    var textContent: IDL_DOMString? { get set }
    func getTextContent() throws (DOMException) -> IDL_DOMString?
    func setTextContent(_ text: IDL_DOMString) throws (DOMException)
    
    func isSameNode(_ other: Node) -> Bool
    func lookupPrefix(_ namespaceURI: IDL_DOMString) -> IDL_DOMString
    func isDefaultNamespace(_ namespaceURI: IDL_DOMString) -> Bool
    func lookupNamespaceURI(_ prefix: IDL_DOMString) -> IDL_DOMString
    func isEqualNode(_ other: Node) -> Bool
    func getFeature(_ feature: IDL_DOMString, _ version: IDL_DOMString) -> Any?
    
    func setUserData(_ key: IDL_DOMString, _ data: DOMUserData, _ handler: UserDataHandler?) throws (DOMException)
    func getUserData(_ key: IDL_DOMString) -> DOMUserData
    
  }
}
