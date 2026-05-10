/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Implement Codable protocol
extension PIC9 : Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let intValue = try container.decode(UInt128.self)
    self.init(intValue)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.value)
  }
}
