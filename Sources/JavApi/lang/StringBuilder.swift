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
  
  public func toString () -> String {
    return self.content
  }
}
