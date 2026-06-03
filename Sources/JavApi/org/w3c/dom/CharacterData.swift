/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol CharacterData : Node {
    var data: IDL_DOMString { get set }
    func setData(_ data: IDL_DOMString) throws (DOMException)
    func getData() throws (DOMException) -> IDL_DOMString
    
    var length: IDL_unsigned_long { get }
    func getLength() -> IDL_unsigned_long
    
    
    func substringData(_ offset: IDL_unsigned_long, count: IDL_unsigned_long) throws (DOMException) -> IDL_DOMString
    func appendData(_ arg: IDL_DOMString) throws (DOMException)
    func insertData(_ offset: IDL_unsigned_long, _ arg: IDL_DOMString) throws (DOMException)
    func deleteData(_ offset: IDL_unsigned_long, _ count: IDL_unsigned_long) throws (DOMException)
    func replaceData(_ offset: IDL_unsigned_long, _ count: IDL_unsigned_long, _ arg: IDL_DOMString) throws (DOMException)
  }
}

extension org.w3c.dom.CharacterData {
  public func getData() throws (DOMException) -> IDL_DOMString {
    return data
  }
  public mutating func setData(_ data: IDL_DOMString) throws (DOMException) {
    self.data = data
  }

  public func getLength() -> IDL_unsigned_long {
    return length
  }
  
  var length : IDL_unsigned_long { IDL_unsigned_long(self.data.count) }
}

extension org.w3c.dom.CharacterData {
  // swiftify named it count instead of length
  var count : Int {self.data.count}
}
