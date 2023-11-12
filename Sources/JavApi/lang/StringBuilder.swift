/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
public class StringBuilder {
  
  var content : String = ""
  
  /// Default constructor
  public init (){}
  
  /// Append a String type
  /// - Parameters String to append
  /// - Returns self (fluent interface pattern)
  public func append (_ s : String) -> StringBuilder{
    self.content.append(s)
    return self
  }
  public func append (_ c : Character) -> StringBuilder{
    self.content.append(c)
    return self
  }
  public func append (_ cs : [Character]) -> StringBuilder{
    for c in cs { // FIXME: better implementation needed
      self.content.append(c)
    }
    return self
  }
  
  public func length () -> Int {
    return content.lenght()
  }
  
  public func setLength (_ newLength : Int) throws {
    guard newLength >= 0 else {
      throw Throwable.IndexOutOufBoundsException(newLength, "New length need to be equals or greater than zero but is \(newLength)")
    }
    
    switch newLength {
    case 0 : self.content = ""
    default :
      while newLength > self.content.count {
        content.append("\u{0000}")
      }
      if newLength < self.content.count {
        
        //let substring = self.content [content.startIndex..<]
      }
    }
  }
  
  public func toString () -> String {
    return self.content
  }
  
  
// FIXME: better implement StringProtocol
  public func substring (_ start : Int, _ end : Int) -> String {
    return self.content.subSequence(start,end)
  }
  
  public func substring (_ start: Int) -> String {
    return self.content.subSequence(start, self.count)
  }
}


