/*
 * SPDX-FileCopyrightText: 2023-2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// final class => public
public class StringBuilder {
  
  var content : String = "" // TODO: implements direct a char array
  
  /// Default constructor
  public init (){}
  
  public init (_ newContent : String) {
    self.content = newContent
  }
  
  // TODO: Test it
  public init (_ newContent : any CharSequence) {
    self.content = "\(newContent)"
  }
  
  /// Append a String type
  /// - Parameters String to append
  /// - Returns self (fluent interface pattern)
  public func append (_ s : String) -> StringBuilder{
    self.content.append(s)
    return self
  }
  public func append (_ s: String, _ start: Int, _ end: Int) -> StringBuilder {
    self.content.append(s.substring(start, end))
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
  
  public func charAt (_ offset : Int) throws -> Character {
    guard offset > -1, offset < self.count else {
      throw java.lang.Throwable.IndexOutOfBoundsException(offset, "the index is negative or greater than or equal to count of String")
    }
    return Array (self.content)[offset]
  }
  
  public func deleteCharAt (_ offset : Int) throws -> StringBuilder {
    guard offset > -1, offset < self.count else {
      throw java.lang.Throwable.IndexOutOfBoundsException(offset, "the index is negative or greater than or equal to count of String")
    }
    var asCharArray = Array(self.content)
    asCharArray.removeFirst(offset)
    return StringBuilder(String(asCharArray))
  }
  
  public func length () -> Int {
    return content.lenght()
  }
  
  public func setLength (_ newLength : Int) throws {
    guard newLength >= 0 else {
      throw Throwable.IndexOutOfBoundsException(newLength, "New length need to be equals or greater than zero but is \(newLength)")
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


