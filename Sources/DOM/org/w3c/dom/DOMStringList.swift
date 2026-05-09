/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol DOMStringList {
    func item(_ index : IDL_unsigned_long) -> IDL_DOMString?
    // Spec describe attribute, Java needs method but Swift can both
    var length : IDL_unsigned_long { get }
    func getLength() -> Int
    func contains(_ str : IDL_DOMString) -> IDL_boolean
  }
}

extension org.w3c.dom.DOMStringList {
  public var length: IDL_unsigned_long {
    get {
      return IDL_unsigned_long(getLength())
    }
  }
}

// Swiftify
extension org.w3c.dom.DOMStringList {
  public var count : Int {
    get {
      return getLength()
    }
  }
}
