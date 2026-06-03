/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol DocumentType : Node {
    func getName() -> IDL_DOMString
    func getEntities() -> NamedNodeMap
    func getNotations() -> NamedNodeMap
    func getPublicId() -> IDL_DOMString
    func getSystemId() -> IDL_DOMString
    func getInternalSubset() -> IDL_DOMString?
  }
}
