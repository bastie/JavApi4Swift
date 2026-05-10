/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension PIC9 : ExpressibleByStringLiteral {
  fileprivate static let TRIM_CHARACTER_SET : CharacterSet = CharacterSet(charactersIn : "\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}\u{0008}\u{0009}\u{000A}\u{000B}\u{000C}\u{000D}\u{000E}\u{000F}\u{0010}\u{0011}\u{0012}\u{0013}\u{0014}\u{0015}\u{0016}\u{0017}\u{0018}\u{0019}\u{001A}\u{001B}\u{001C}\u{001D}\u{001E}\u{001F}\u{0020}") // different to strip can be readed f.e. here: (https://stackoverflow.com/questions/51266582/difference-between-string-trim-and-strip-methods-in-java-11)
  

  public typealias StringLiteralType = String
  
  public init(stringLiteral value: String) {
    let string = value.trimmingCharacters(in: PIC9.TRIM_CHARACTER_SET)
    self.init(count: string.count, value: UInt128(string)!)
  }
}
