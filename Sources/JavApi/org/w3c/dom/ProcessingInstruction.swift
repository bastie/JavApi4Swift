/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol ProcessingInstruction : Node {
    
    var target: IDL_DOMString { get }
    func getTarget() -> IDL_DOMString
    
    var data: IDL_DOMString { get set }
    func getData() -> IDL_DOMString
    func setData(_ data : IDL_DOMString) throws (DOMException)
    
  }
}

extension org.w3c.dom.ProcessingInstruction {
  
  public func getTarget() -> IDL_DOMString {
    return target
  }
  
  public func getData() -> IDL_DOMString {
    return data
  }
  
  public mutating func setData(_ data: IDL_DOMString) throws (DOMException) {
    self.data = data
  }
}
