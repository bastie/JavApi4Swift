/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.net {

  /// Utility class for encoding strings into `application/x-www-form-urlencoded` format.
  ///
  /// Java 1.0 `java.net.URLEncoder`. This class cannot be instantiated.
  ///
  /// Encoding rules (matching Java's behaviour):
  /// - Letters (`A–Z`, `a–z`), digits (`0–9`), and `_`, `-`, `.`, `*` are left unchanged.
  /// - Space (` `) is converted to `+`.
  /// - All other characters are percent-encoded as `%XX` (UTF-8 bytes).
  ///
  /// > **Note:** This produces `application/x-www-form-urlencoded` encoding, **not**
  /// > RFC 3986 percent-encoding. The key difference is that spaces become `+`, not `%20`.
  /// > Use `Foundation.URL` percent-encoding APIs when you need RFC 3986 compliance.
  ///
  /// - Since: Java 1.0
  public struct URLEncoder {

    /// `URLEncoder` cannot be instantiated.
    private init() {}

    // Characters that are never encoded (Java spec: letters, digits, _, -, ., *)
    // Only ASCII letters, digits and the four Java-spec unreserved chars.
    // Must NOT use CharacterSet.alphanumerics — that includes all Unicode letters
    // (e.g. "ä"), which Java's URLEncoder does encode.
    private static let unreserved: CharacterSet = CharacterSet(
      charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.*"
    )

    /// Encodes a string using the default UTF-8 charset.
    ///
    /// This is equivalent to Java 1.4's `URLEncoder.encode(String, "UTF-8")`.
    ///
    /// - Parameter s: The string to encode.
    /// - Returns: The encoded string.
    /// - Since: Java 1.0
    @available(*, deprecated, renamed: "URLEncoder.encode(_:_:)", message: "use encode (string, \"UTF-8\") instead")
    public static func encode(_ s: String) -> String {
      return try! encode(s, "UTF-8") /// UTF-8 exists, so we use `try!`
    }
    
    /// - Since: Java 10
    /// - Note: Java throws `NullPointerException` but we can use non-optional parameters
    public static func encode (_ s: String, _ charset: java.nio.charset.Charset) -> String {
      do {
        return try URLEncoder.encode(s, charset.name())
      }
      catch {
        return try! URLEncoder.encode(s, "UTF-8")
      }
    }

    /// Encodes a string using the specified charset name.
    ///
    /// Only `"UTF-8"` and `"US-ASCII"` are fully supported; other values
    /// fall back to UTF-8 with a note in the documentation.
    ///
    /// - Parameters:
    ///   - s: The string to encode.
    ///   - enc: The charset name (e.g. `"UTF-8"`).
    /// - Returns: The encoded string.
    /// - Since: Java 1.4
    public static func encode(_ s: String, _ enc: String) throws -> String {
      // Replace spaces with '+' first (application/x-www-form-urlencoded)
      // then percent-encode everything else that isn't unreserved.
      var result = ""
      result.reserveCapacity(s.count)

      // TODO: accept all implemented encodings
      guard enc.uppercased() == "UTF-8" || enc.uppercased() == "US-ASCII" else {
        throw java.io.UnsupportedEncodingException("\(enc) is not supported")
      }
      let encoding: String.Encoding = enc.uppercased() == "US-ASCII" ? .ascii : .utf8

      for char in s.unicodeScalars {
        if char == " " {
          result.append("+")
        } else if unreserved.contains(char) {
          result.append(Character(char))
        } else {
          // Percent-encode using the requested encoding
          let str = String(char)
          if let data = str.data(using: encoding) {
            for byte in data {
              result.append(String(format: "%%%02X", byte))
            }
          } else {
            // Fallback: UTF-8
            for byte in str.utf8 {
              result.append(String(format: "%%%02X", byte))
            }
          }
        }
      }
      return result
    }
  }
}
