/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol DOMImplementation {
    func hasFeature(_ feature : IDL_DOMString, _ version : IDL_DOMString) -> IDL_boolean
    func createDocumentType(_ qualifiedName : IDL_DOMString, _ publicId : IDL_DOMString, _ systemId : IDL_DOMString) throws (DOMException) -> DocumentType
    func createDocument(_ namespaceURI : IDL_DOMString, _ qualifiedName : IDL_DOMString, _ doctype : DocumentType) throws (DOMException) -> Document
    func getFeature(_ feature : IDL_DOMString, _ version : IDL_DOMString) -> Any?
  }
}
