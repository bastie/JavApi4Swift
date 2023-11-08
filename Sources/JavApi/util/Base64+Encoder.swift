/*
 * SPDX-FileCopyrightText: 2015 - Doug Richardson
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Unlicense
 */

//
//  Important Parts form Base64.swift in project SwiftyBase64 created by Doug Richardson on 8/7/15.
//

extension java.util.Base64 {
  
  open class Encoder {
    
    private let ALPHABET : java.util.Alphabet;
    
    /// Create a Encoder with given alphabet
    /// - parameter newAlphabet: The Base64 alphabet to encode with.
    public init (_ newAlphabet : java.util.Alphabet) {
      self.ALPHABET = newAlphabet
    }
    /// Create a Encoder with standard alphabet
    public convenience init () {
      self.init(.Standard)
    }
    
    
    ///
    /// Use the Base64 algorithm as decribed by RFC 4648 section 4 to
    ///  encode the input bytes. The alphabet specifies the translation
    /// table to use. RFC 4648 defines two such alphabets:
    ///
    /// - Standard (section 4)
    /// - URL and Filename Safe (section 5)
    ///
    /// - parameter bytes: Bytes to encode.
    /// - returns: Base64 encoded ASCII bytes.
    ///
    public func encode(_ bytes : [UInt8]) -> [UInt8] {
      
      var encoded : [UInt8] = []
      
      let table = tableForAlphabet(self.ALPHABET)
      let padding = table[64]
      
      var i = 0
      let count = bytes.count
      
      while i+3 <= count {
        let one = bytes[i] >> 2
        let two = ((bytes[i] & 0b11) << 4) | ((bytes[i+1] & 0b11110000) >> 4)
        let three = ((bytes[i+1] & 0b00001111) << 2) | ((bytes[i+2] & 0b11000000) >> 6)
        let four = bytes[i+2] & 0b00111111
        
        encoded.append(table[Int(one)])
        encoded.append(table[Int(two)])
        encoded.append(table[Int(three)])
        encoded.append(table[Int(four)])
        
        i += 3
      }
      
      if i+2 == count {
        // (3) The final quantum of encoding input is exactly 16 bits; here, the
        // final unit of encoded output will be three characters followed by
        // one "=" padding character.
        let one = bytes[i] >> 2
        let two = ((bytes[i] & 0b11) << 4) | ((bytes[i+1] & 0b11110000) >> 4)
        let three = ((bytes[i+1] & 0b00001111) << 2)
        encoded.append(table[Int(one)])
        encoded.append(table[Int(two)])
        encoded.append(table[Int(three)])
        encoded.append(padding)
      } else if i+1 == count {
        // (2) The final quantum of encoding input is exactly 8 bits; here, the
        // final unit of encoded output will be two characters followed by
        // two "=" padding characters.
        let one = bytes[i] >> 2
        let two = ((bytes[i] & 0b11) << 4)
        encoded.append(table[Int(one)])
        encoded.append(table[Int(two)])
        encoded.append(padding)
        encoded.append(padding)
      } else {
        // (1) The final quantum of encoding input is an integral multiple of 24
        // bits; here, the final unit of encoded output will be an integral
        // multiple of 4 characters with no "=" padding.
        assert(i == count)
      }
      
      return encoded
    }
    
    ///
    /// Encode a [UInt8] byte array as a Base64 String.
    ///
    /// - parameter bytes: Bytes to encode.
    /// - returns: A String of the encoded bytes.
    ///
    public func encodeToString(_ bytes : [UInt8]) -> String {
      let encoded = encode(bytes)
      var result = String()
      for b in encoded {
        result.append(String(UnicodeScalar(b)))
      }
      return result
    }
  }
  
}
