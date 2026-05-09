/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol Text : CharacterData {
    func splitText(_ offset : IDL_unsigned_long) throws (DOMException) -> Text    
    var isElementContentWhitespace : Bool { get } // name of attribute in spec same as Java Beans convention
    var wholeText: IDL_DOMString { get }
    func getWholeText() -> IDL_DOMString
    func replaceWholeText(_ content : IDL_DOMString) throws (DOMException) -> Text
    
  }
}
