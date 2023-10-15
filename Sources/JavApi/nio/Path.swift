/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  
  public typealias Path = JavApi.Path
  
}

/// Utility type to work with path
public protocol Path {
  /// Create a new Path instance from given parts
  /// - Parameters:
  ///    - first part of path
  ///    - more parts of path
  /// - Returns path instance
  static func of (_ first : String, _ more : String...) -> Path
  /// Get a java.io.File from path instance
  /// - Returns java.io.File
  func toFile () -> java.io.File
  /// Get a string representation of path
  /// - Returns String
  func toString () -> String
}


extension java.nio {
  /// Default implementation of Path type
  public class _Path : Path {
    private var first : String?
    private var more : [String]?
    /// Create a new Path instance from given parts
    /// - Parameters:
    ///    - first part of path
    ///    - more parts of path
    /// - Returns path instance
    public static func of (_ firstValue : String, _ moreValue : [String]) -> Path {
      let result = _Path()
      result.first = firstValue
      result.more = moreValue
      return result
    }
    public static func of (_ firstValue : String, _ moreValue : String...) -> Path {
      let result = _Path()
      result.first = firstValue
      result.more = moreValue
      return result
    }
    
    public func toFile() -> java.io.File {
      return java.io.File(self.toString())
    }
    
    public func toString () -> String {
      var result = ""
      if let first = self.first {
        result.append(first)
        if let more = self.more {
          for next in more {
            result.append("/")
            result.append(next)
          }
        }
      }
      else {
        if let more = self.more {
          for next in more {
            result.append(next)
            result.append("/")
          }
          if !result.isEmpty {
            let _ = result.removeLast()
          }
        }
      }
      return result
    }
  }
}
