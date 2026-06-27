import Foundation

// - MARK: Codable conform BigInteger

extension java.math.BigInteger: Codable {
  
  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let stringValue = try container.decode(String.self)
    
    // Fehler der Java-API abfangen und in einen Swift-DecodingError übersetzen
    do {
      // Ruft den originalen init(_ val: String) auf
      try self.init(stringValue)
    } catch {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Format not allowed for BigInteger: \(stringValue)"
      )
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    // toString() liefert die Basis-10-Repräsentation
    try container.encode(self.toString())
  }
}
