/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

extension java.util {
  typealias UUID = Foundation.UUID
}


extension Foundation.UUID {
  
  /// Create a UUID from standard description
  /// - Parameters:
  /// - Parameter UUID as String in external representation XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  public static func fromString (_ uuid: String) throws -> UUID {
    if let uuid = UUID(uuidString: uuid) {
      return uuid
    }
    throw Throwable.IllegalArgumentException("In result of invalid UUID string \(uuid)")
  }
  
  public static func randomUUID () -> UUID {
    return UUID()
  }
  
  public static func nameUUIDFromBytes (_ bytes : [UInt8]) throws -> UUID {
    let md5 = Insecure.MD5.hash(data: Data(bytes))
    var md5Bytes =  md5.map{$0}
    
    // Page 24 of RFC-4122
    md5Bytes[6]  &= 0x0f;  /* version clearing        */
    md5Bytes[6]  |= 0x30;  /* version set to 3     */
    md5Bytes[8]  &= 0x3f;  /* variant clearing       */
    md5Bytes[8]  |= 0x80;  /* set to IETF variant  */

    let c_struct = (
      md5Bytes[0],
      md5Bytes[1],
      md5Bytes[2],
      md5Bytes[3],
      md5Bytes[4],
      md5Bytes[5],
      md5Bytes[6],
      md5Bytes[7],
      md5Bytes[8],
      md5Bytes[9],
      md5Bytes[10],
      md5Bytes[11],
      md5Bytes[12],
      md5Bytes[15],
      md5Bytes[14],
      md5Bytes[15]
    )
    let result = UUID(uuid: c_struct)
    
    return result
  }

  public func toString () -> String {
    return self.description.lowercased() // Swift print it UPPERcase, Java instead lowerCASE
  }
}
