/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio {
  public final class ByteOrder : Equatable {
    
    private let asString : String
    public static let BIG_ENDIAN : ByteOrder = ByteOrder("BIG_ENDIAN")
    public static let LITTLE_ENDIAN : ByteOrder = ByteOrder("LITTLE_ENDIAN")
    
    private init (_ requestedByteOrder : String?) {
      if let requestedByteOrder {
        asString = requestedByteOrder
      }
      else {
        /*
         enum __CFByteOrder {
         CFByteOrderUnknown,
         CFByteOrderLittleEndian,
         CFByteOrderBigEndian
         };
         typedef CFIndex CFByteOrder;
         */
        switch (CFByteOrderGetCurrent()) {
        case 1 : // LittleEndian
          asString = "LITTLE_ENDIAN"
          break
        case 2 : // BigEndian
          asString = "BIG_ENDIAN"
          break
        default : // Other => Unknown
          asString = "UNKNOWN"
        }
      }
    }
    
    public static func nativeOrder () -> ByteOrder {
      return ByteOrder(nil)
    }
    
    public func toString () -> String {
      return asString
    }
    
    public static func == (lhs: ByteOrder, rhs: ByteOrder) -> Bool {
      return lhs.asString == rhs.asString
    }
  }
  
}


extension java.nio.ByteOrder : Sendable {}
