/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Double {
  public static let MAX_VALUE = Double.greatestFiniteMagnitude
  public static let MIN_VALUE = -MAX_VALUE
  
  public static func parseDouble (_ s : String?) throws -> Double {
    if let s {
      return try parseDouble(s)
    }
    throw Throwable.NullPointerException("In result of String is nil cannot parse as Double.")
  }
  public static func parseDouble (_ s : String) throws -> Double {
    let trimmed = s.trim()
    guard trimmed.components(separatedBy: ".").count == 2 else {
      throw Throwable.NumberFormatException("In result of String contains multiple points cannot parse as Double.")
    }
    let result = Double(trimmed)
    if let result {
      return result
    }
    throw Throwable.NumberFormatException ("NumberFormatException for input String \(s)")
  }
}
