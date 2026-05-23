/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
#if canImport(CryptoKit)
#else

import Foundation

extension Insecure {
  
  /// MD5 Hash-Implementierung für Plattformen ohne CryptoKit (z. B. FreeBSD).
  /// Bietet eine inkrementelle API ähnlich wie `CryptoKit.Insecure.MD5`.
  public struct MD5 {
    // MARK: - Konstanten (Tabelle s und k)
    private static let s: [UInt32] = [
      7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
      5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
      4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
      6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
    ]
    
    private static let k: [UInt32] = [
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
    
    // MARK: - Zustand für inkrementelles Hashing
    private var a: UInt32
    private var b: UInt32
    private var c: UInt32
    private var d: UInt32
    private var buffer: Data          // angefangene, noch nicht verarbeitete Bytes
    private var totalBytes: UInt64    // Anzahl der bisher insgesamt verarbeiteten Bytes (für Längenfeld)
    
    // MARK: - Initialisierung
    public init() {
      a = 0x67452301
      b = 0xEFCDAB89
      c = 0x98BADCFE
      d = 0x10325476
      buffer = Data()
      totalBytes = 0
    }
    
    // MARK: - Öffentliche API
    /// Fügt weitere Daten zum Hash hinzu.
    public mutating func update(data: Data) {
      totalBytes += UInt64(data.count)
      buffer.append(data)
      
      // Solange mindestens ein voller 64-Byte-Block im Puffer ist, verarbeiten.
      while buffer.count >= 64 {
        let chunk = buffer.prefix(64)
        process(Array(chunk))
        buffer.removeFirst(64)
      }
    }
    
    /// Schließt die Hash-Berechnung ab und gibt das 16-Byte-Ergebnis zurück.
    public mutating func finalize() -> [UInt8] {
      // Padding und Längenanhängung durchführen
      let originalBitCount = totalBytes << 3   // Bits = Bytes * 8
      
      // 1. 0x80 anhängen
      var padding = Data()
      padding.append(0x80)
      
      // 2. Nullen anhängen, bis (Länge + Padding) ≡ 56 (mod 64)
      let currentLength = buffer.count
      let paddingNeeded = (56 - (currentLength + 1) % 64 + 64) % 64
      padding.append(Data(repeating: 0, count: paddingNeeded))
      
      // 3. Länge (64 Bit, little‑endian) anhängen
      var bitCountLittleEndian = originalBitCount.littleEndian
      withUnsafeBytes(of: &bitCountLittleEndian) {
        padding.append(contentsOf: $0)
      }
      
      // 4. Verarbeite die Padding-Daten (können einen oder zwei Blöcke auslösen)
      update(data: padding)
      
      // Nach der Verarbeitung aller Blöcke ist der Puffer leer,
      // und a,b,c,d enthalten den finalen Hash.
      let result = [a, b, c, d].flatMap { value -> [UInt8] in
        var little = value.littleEndian
        return withUnsafeBytes(of: &little) { Array($0) }
      }
      
      // Zustand zurücksetzen (für mögliche Wiederverwendung, optional)
      reset()
      
      return result
    }
    
    /// Setzt den Hasher auf den Anfangszustand zurück.
    public mutating func reset() {
      a = 0x67452301
      b = 0xEFCDAB89
      c = 0x98BADCFE
      d = 0x10325476
      buffer.removeAll()
      totalBytes = 0
    }
    
    // MARK: - Statische Ein-Schritt-Methode (bequem)
    public static func hash(data: Data) -> [UInt8] {
      var hasher = MD5()
      hasher.update(data: data)
      return hasher.finalize()
    }
    
    public static func hash(_ bytes: [UInt8]) -> [UInt8] {
      return hash(data: Data(bytes))
    }
    
    // MARK: - Private Blockverarbeitung (Kern des MD5)
    private mutating func process(_ chunk: [UInt8]) {
      precondition(chunk.count == 64, "MD5 Block muss genau 64 Bytes haben")
      
      // 16 UInt32 aus dem Block (little‑endian) extrahieren
      var M = [UInt32](repeating: 0, count: 16)
      for i in 0..<16 {
        let start = i * 4
        M[i] = UInt32(chunk[start])
        | (UInt32(chunk[start+1]) << 8)
        | (UInt32(chunk[start+2]) << 16)
        | (UInt32(chunk[start+3]) << 24)
      }
      
      var A = a
      var B = b
      var C = c
      var D = d
      
      for i in 0..<64 {
        var F: UInt32
        var g: Int
        
        switch i {
        case 0..<16:
          F = (B & C) | ((~B) & D)
          g = i
        case 16..<32:
          F = (D & B) | ((~D) & C)
          g = (5 * i + 1) % 16
        case 32..<48:
          F = B ^ C ^ D
          g = (3 * i + 5) % 16
        default: // 48..<64
          F = C ^ (B | (~D))
          g = (7 * i) % 16
        }
        
        F = F &+ A &+ Self.k[i] &+ M[g]
        A = D
        D = C
        C = B
        B = B &+ (F << Self.s[i] | F >> (32 - Self.s[i]))
      }
      
      a = a &+ A
      b = b &+ B
      c = c &+ C
      d = d &+ D
    }
  }
}
#endif // canImport(CryptoKit)
