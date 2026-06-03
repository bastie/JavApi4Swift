/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol Attr : Node {
    func getName() -> IDL_DOMString?
    func getSpecified() -> IDL_boolean
    func getValue() -> IDL_DOMString
    func setValue(_ value  : IDL_DOMString) throws (DOMException)
    func getOwnerElement() -> Element?
    func getSchemaTypeInfo() -> TypeInfo
    func isId() -> IDL_boolean
    
  }
}

/*
 interface Attr : Node {
 readonly attribute DOMString       name;
 readonly attribute boolean         specified;
 attribute DOMString       value;
 // raises(DOMException) on setting
 
 // Introduced in DOM Level 2:
 readonly attribute Element         ownerElement;
 // Introduced in DOM Level 3:
 readonly attribute TypeInfo        schemaTypeInfo;
 // Introduced in DOM Level 3:
 readonly attribute boolean         isId;
 };
 */
