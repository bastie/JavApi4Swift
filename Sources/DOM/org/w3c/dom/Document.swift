/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol Document : Node {
    func adoptNode(_ source : Node) throws (DOMException) -> Node?
    func createElement(_ tagName : IDL_DOMString) throws (DOMException) -> Element?
    func createDocumentFragment() -> DocumentFragment
    func createTextNode(data : IDL_DOMString) -> Text
    func createComment(_ data : IDL_DOMString) -> Comment
    func createCDATASection(_ data : IDL_DOMString) throws (DOMException) -> CDATASection
    func createProcessingInstruction(_ target : IDL_DOMString, data : IDL_DOMString) throws (DOMException) -> ProcessingInstruction
    func createAttribute(_ name : IDL_DOMString) throws (DOMException) -> Attr
    func createEntityReference(_ name : IDL_DOMString) throws (DOMException) -> EntityReference
    func createElementNS(_ namespaceURI : IDL_DOMString, qualifiedName : IDL_DOMString) throws (DOMException) -> Element
    func createAttributeNS(_ namespaceURI : IDL_DOMString, qualifiedName : IDL_DOMString) throws (DOMException) -> Attr
    func getDoctype() -> DocumentType?
    func getImplementation() -> DOMImplementation
    func getDocumentElement() -> Element
    func getElementsByTagName(_ tagname : IDL_DOMString) -> NodeList
    func getElementById(_ elementId : IDL_DOMString) -> Element?
    func getInputEncoding() -> IDL_DOMString?
    func getXmlEncoding() -> IDL_DOMString?
    func getXmlStandalone() -> IDL_boolean?
    func getElementsByTagNameNS(_ namespaceURI : IDL_DOMString, _ localName : IDL_DOMString) -> NodeList
    func getXmlVersion() -> IDL_DOMString?
    func getStrictErrorChecking() -> IDL_boolean
    func getDocumentURI() -> IDL_DOMString?
    func getDomConfig() -> DOMConfiguration
    func importNode(_ importedNode : Node, deep : IDL_boolean) throws (DOMException) -> Node
    func normalizeDocument();
    func renameNode(_ n : Node, _ namespaceURI : IDL_DOMString, _ qualifiedName : IDL_DOMString) throws (DOMException) -> Node
    func setXmlStandalone(_ xmlStandalone : IDL_boolean) throws (DOMException)
    func setXmlVersion(_ xmlVersion : IDL_DOMString) throws (DOMException)
    func setStrictErrorChecking(_ strictErrorChecking : IDL_boolean)
    func setDocumentURI(_ documentURI : IDL_DOMString)
  }
}
