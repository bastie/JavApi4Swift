
import CryptoKit

public enum SwiftMessageDigestProvidedAlgorithm : String, CustomStringConvertible, CustomDebugStringConvertible, CaseIterable {
  
  public var debugDescription: String {
    switch self {
    case .MD5:     return "CryptoKit:Insecure.MD5"
    case .SHA_1:   return "CryptoKit:Insecure.SHA-1"
    case .SHA_256: return "CryptoKit:SHA-256"
    case .SHA_384: return "CryptoKit:SHA-384"
    case .SHA_512: return "CryptoKit:SHA-512"
    }
  }
  
  public var description: String {
    self.rawValue
  }
  
  public typealias RawValue = String
  
  /// MD5 until Java 9 required
  case MD5     = "MD5"
  case SHA_1   = "SHA-1"
  case SHA_256 = "SHA-256"
  /// SHA 384 since Java 25 required
  case SHA_384 = "SHA-384"
  /// With Swift also supported SHA 512
  case SHA_512 = "SHA-512"
  
  /// Java idomatic return of value to create a new instance with `java.security.MessageDigest (String)`.
  /// - Returns Algorithm name
  public func toString () -> String {
    self.description
  }
  
  public static func provides (algorithm : String) -> Bool {
    return SwiftMessageDigestProvidedAlgorithm.allCases.contains { $0.rawValue == algorithm }
  }
  
  internal static func getInstance (algorithm : String) -> java.security.MessageDigest? {
    switch algorithm {
    case "MD5":     return SwiftMD5Digest ()
    case "SHA-1":   return SwiftSHA1Digest()
    case "SHA-256": return SwiftSHA256Digest()
    case "SHA-384": return SwiftSHA384Digest()
    case "SHA-512": return SwiftSHA512Digest()
    default : return nil
    }
  }
}
