#if canImport(CryptoKit)
#else

/// In result of CryptoKit is not available on FreeBSD `Insecure` `MD5` is self provided.
public enum Insecure {
  
  // Vollständige KI-MD5 Implementierung in Swift
  // TODO: Test unter FreeBSD (und anderen noch offen)
  public struct MD5 {
    private static let s: [UInt32] = [
      7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
      5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
      4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
      6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
    ]
    
    public static let k: [UInt32] = [
      0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
      0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
      0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
      0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
      0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
      0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
      0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
      0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
      0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
      0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
      0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
      0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
      0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
      0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
      0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
      0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    ]
    
    public static func hash(_ bytes: [UInt8]) -> [UInt8] {
      var message = bytes
      let messageLenBits = UInt64(message.count) * 8
      
      // Padding
      message.append(0x80)
      while (message.count % 64) != 56 {
        message.append(0x00)
      }
      
      // Länge anhängen (little-endian)
      withUnsafeBytes(of: messageLenBits.littleEndian) {
        message.append(contentsOf: $0)
      }
      
      var a: UInt32 = 0x67452301
      var b: UInt32 = 0xEFCDAB89
      var c: UInt32 = 0x98BADCFE
      var d: UInt32 = 0x10325476
      
      // Prozessieren in 512-bit Blöcken
      for chunkStart in stride(from: 0, to: message.count, by: 64) {
        let chunk = Array(message[chunkStart..<chunkStart+64])
        var M = [UInt32](repeating: 0, count: 16)
        
        // chunk in 16 UInt32 Werte umwandeln (little-endian)
        for i in 0..<16 {
          let start = i * 4
          M[i] = UInt32(chunk[start]) |
          (UInt32(chunk[start+1]) << 8) |
          (UInt32(chunk[start+2]) << 16) |
          (UInt32(chunk[start+3]) << 24)
        }
        
        var A = a, B = b, C = c, D = d
        
        for i in 0..<64 {
          var F: UInt32 = 0
          var g = 0
          
          if i < 16 {
            F = (B & C) | ((~B) & D)
            g = i
          } else if i < 32 {
            F = (D & B) | ((~D) & C)
            g = (5 * i + 1) % 16
          } else if i < 48 {
            F = B ^ C ^ D
            g = (3 * i + 5) % 16
          } else {
            F = C ^ (B | (~D))
            g = (7 * i) % 16
          }
          
          F = F &+ A &+ k[i] &+ M[g]
          A = D
          D = C
          C = B
          B = B &+ (F << s[i] | F >> (32 - s[i]))
        }
        
        a = a &+ A
        b = b &+ B
        c = c &+ C
        d = d &+ D
      }
      
      // Ergebnis als [UInt8] zurückgeben (little-endian)
      var result = [UInt8]()
      [a, b, c, d].forEach { value in
        withUnsafeBytes(of: value.littleEndian) {
          result.append(contentsOf: $0)
        }
      }
      
      return result
    }
  }
}
#endif // canImport(CryptoKit)
