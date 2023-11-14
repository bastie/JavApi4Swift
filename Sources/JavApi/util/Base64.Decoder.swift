/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Base64 {
  
  open class Decoder {
    
    private let ALPHABET : java.util.Alphabet;
    private let REVERSED : [UInt8:UInt8]
    
    /// Create a Encoder with given alphabet
    /// - parameter newAlphabet: The Base64 alphabet to encode with.
    public init (_ newAlphabet : java.util.Alphabet) {
      self.ALPHABET = newAlphabet
      
      let table = java.util.Base64.tableForAlphabet(self.ALPHABET)
      var reversedAlphabet = [UInt8:UInt8]()
      for (index, value) in table.enumerated() {
        reversedAlphabet[value] = UInt8(index)
      }
      self.REVERSED = reversedAlphabet
    }
    /// Create a Encoder with standard alphabet
    public convenience init () {
      self.init(.Standard)
    }
 
    public func decode (_ src : [UInt8]) throws -> [UInt8] {
      // TODO: faster impl wanted
      var dest = [UInt8]()
      
      guard src.count % 4 == 0 else {
        throw Throwable.IllegalArgumentException("Input is not a BASE64 content.")
      }
      guard src.count > 3 else  {
        throw Throwable.IllegalArgumentException("Input is not a padded BASE64 content.")
      }
      
      // to support without last 4 bytes
      for i in stride (from: 0, to: src.count, by: 4) {
        let zero = Int(self.REVERSED [ src[i] ]!)
        let one = Int(self.REVERSED [ src [i+1] ]!)
        let two = Int(self.REVERSED [ src [i+2] ]!)
        let three = Int(self.REVERSED [ src [i+3] ]!)
        
        
        var sum : Int = zero << 6
        sum = (sum + one) << 6
        sum = (sum + two) << 6
        sum = (sum + three)
        
        let third : UInt8 = UInt8(truncatingIfNeeded: sum)
        sum = sum >> 8
        let second : UInt8 = UInt8(truncatingIfNeeded: sum)
        sum = sum >> 8
        let first : UInt8 = UInt8(truncatingIfNeeded: sum)
        
        dest.append(first)
        dest.append(second)
        dest.append(third)
      }
      
      let lastIsEqualSign = src[src.length-1] == Character("=").asDigit()
      let preLastIsEqualSign = lastIsEqualSign && (src[src.length-2]  == Character("=").asDigit())
      
      if lastIsEqualSign {
        dest.removeLast()
      }
      if preLastIsEqualSign {
        dest.removeLast()
      }

      return dest
    }
  }
}
