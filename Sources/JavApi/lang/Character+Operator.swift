/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Character {

  /// Return the codepoint value of character
  ///
  /// In result of Unicode Scalar representation it returns a value in Int32 range.
  ///
  /// - Returns Int value
  public func asDigit () -> Int {
    let asString : String = String(self)
    for char in asString.unicodeScalars {
      return Int(char.value)
    }
    fatalError("Never ever come to this point.")
  }
  

  /// Test the codepoint of Character against the Int value
  ///
  /// - Parameters
  /// - Parameter lhs Character to test
  /// - Parameter rhs codepint
  ///
  /// - Returns true if same
  public static func ==(lhs: Character, rhs: Int) -> Bool {
    let intValue = lhs.asDigit()
    return intValue == rhs
  }
  
  /// Test the codepoint of Character against the Int value
  ///
  /// - Parameters
  /// - Parameter rhs Character to test
  /// - Parameter lhs codepint
  ///
  /// - Returns true if same
  public static func ==(lhs: Int, rhs: Character) -> Bool {
    let intValue = rhs.asDigit()
    return intValue == lhs
  }
}
