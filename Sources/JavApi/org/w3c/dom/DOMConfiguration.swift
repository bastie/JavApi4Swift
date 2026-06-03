/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol DOMConfiguration {
    func setParameter(_ name : IDL_DOMString, _ value : Any?) throws (DOMException)
    func getParameter(_ name : IDL_DOMString) throws (DOMException) -> Any?
    func canSetParameter(_ name : IDL_DOMString,_ value : Any?) -> IDL_boolean
    func getParameterNames() -> DOMStringList
  }
}


extension org.w3c.dom.DOMConfiguration {
  func removeParameter (_ name: String) throws (DOMException){
    try self.setParameter(name, nil)
  }
}

/*
 // Introduced in DOM Level 3:
 interface DOMConfiguration {
 void               setParameter(in DOMString name,
 in DOMUserData value)
 raises(DOMException);
 DOMUserData        getParameter(in DOMString name)
 raises(DOMException);
 boolean            canSetParameter(in DOMString name,
 in DOMUserData value);
 readonly attribute DOMStringList   parameterNames;
 };

 */
