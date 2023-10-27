/*
 * SPDX-FileCopyrightText: 2011 - ymnk, JCraft,Inc.
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: BSD-3-Clause
 */
/*
 Copyright (c) 2011 ymnk, JCraft,Inc. All rights reserved.
 Copyright (c) 2023 Sebastian Ritter
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in
 the documentation and/or other materials provided with the distribution.
 
 3. The names of the authors may not be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JCRAFT,
 INC. OR ANY CONTRIBUTORS TO THIS SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * This program is based on zlib-1.1.3, so all credit should go authors
 * Jean-loup Gailly(jloup@gzip.org) and Mark Adler(madler@alumni.caltech.edu)
 * and contributors of zlib.
 */

extension java.util.zip {
  /// Adler-32 checksum algorithm
  final public class Adler32 : Checksum {
    public typealias Checksum = Adler32
    
    public init() {}
    
    // largest prime smaller than 65536
    static private let BASE : Int = 65521;
    // NMAX is the largest n such that 255n(n+1)/2 + (n+1)(BASE-1) <= 2^32-1
    static let NMAX : Int = 5552;
    
    private var s1 : Int64 = 1;
    private var s2 : Int64 = 0;
    
    /// Reset the checksum with given value to initialize
    /// - Parameters init value
    public func reset(_ initialize : Int64) {
      s1 = initialize & 0xffff;
      s2 = (initialize >> 16) & 0xffff;
    }
    
    public func reset() {
      s1 = 1;
      s2 = 0;
    }
    
    public func getValue() -> Int64{
      return ((s2 << 16) | s1);
    }
    
    public func update(_ buf : [UInt8], _ _index : Int, _ _len : Int) {
      var index = _index
      var len = _len
      if (len == 1) {
        s1 += Int64(buf[index] & 0xff);
        index += 1
        s2 += s1;
        s1 %= Int64(java.util.zip.Adler32.BASE);
        s2 %= Int64(java.util.zip.Adler32.BASE);
        return;
      }
      
      var len1 : Int = len / java.util.zip.Adler32.NMAX;
      let len2 : Int = len % java.util.zip.Adler32.NMAX;
      while (len1-1 > 0) {
        len1 -= 1
        var k : Int = java.util.zip.Adler32.NMAX;
        len -= k;
        while (k > 0) {
          k -= 1
          s1 += Int64(buf[index] & 0xff);
          index += 1
          s2 += s1;
        }
        s1 %= Int64(java.util.zip.Adler32.BASE);
        s2 %= Int64(java.util.zip.Adler32.BASE);
      }
      
      var k : Int = len2;
      len -= k;
      while (k > 0) {
        k -= 1
        s1 += Int64(buf[index] & 0xff);
        index += 1
        s2 += s1;
      }
      s1 %= Int64(java.util.zip.Adler32.BASE);
      s2 %= Int64(java.util.zip.Adler32.BASE);
    }
    
    /// create a copy of Adler-32 instance
    /// - Returns new Instance with self Adler internal var values
    public func copy() -> Adler32 {
      let foo = Adler32();
      foo.s1 = self.s1;
      foo.s2 = self.s2;
      return foo;
    }
    
    // The following logic has come from zlib.1.2.
    static func combine(_ adler1 : Int64, _ adler2 : Int64, _ len2 : Int64) -> Int64 {
      let BASEL : Int64 = Int64 (BASE);
      var sum1 : Int64;
      var sum2 : Int64;
      let rem : Int64;  // unsigned int
      
      rem = len2 % BASEL;
      sum1 = adler1 & Int64(0xffff);
      sum2 = rem * sum1;
      sum2 %= BASEL; // MOD(sum2);
      sum1 += (adler2 & Int64(0xffff)) + BASEL - 1;
      sum2 += ((adler1 >> 16) & Int64(0xffff)) + ((adler2 >> 16) & Int64(0xffff)) + BASEL - rem;
      if (sum1 >= BASEL) {
        sum1 -= BASEL;
      }
      if (sum1 >= BASEL) {
        sum1 -= BASEL;
      }
      if (sum2 >= (BASEL << 1)) {
        sum2 -= (BASEL << 1);
      }
      if (sum2 >= BASEL) {
        sum2 -= BASEL;
      }
      return sum1 | (sum2 << 16);
    }
  }
}
