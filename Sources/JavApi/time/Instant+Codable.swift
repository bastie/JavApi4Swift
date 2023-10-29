/*
 * SPDX-License-Identifier: MIT
 */

extension java.time.Instant: Codable {
  
  /// A type that can be used as a key for encoding and decoding.
  ///
  /// - second: The second.
  /// - nano: The nano-of-second.
  private enum CodingKeys: Int, CodingKey {
    case second
    case nano
  }
  
  /// Creates a new instance by decoding from the given decoder.
  ///
  /// This initializer throws an error if reading from the decoder fails, or
  /// if the data read is corrupted or otherwise invalid.
  ///
  /// - Parameter decoder: The decoder to read data from.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.internalSecond = try container.decode(Int64.self, forKey: .second)
    self.internalNano = try container.decode(Int.self, forKey: .nano)
  }
  
  /// Encodes this value into the given encoder.
  ///
  /// If the value fails to encode anything, `encoder` will encode an empty
  /// keyed container in its place.
  ///
  /// This function throws an error if any values are invalid for the given
  /// encoder's format.
  ///
  /// - Parameter encoder: The encoder to write data to.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.internalSecond, forKey: .second)
    try container.encode(self.internalNano, forKey: .nano)
  }
}
