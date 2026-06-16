/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Locale {

    // MARK: - Language constants (Java 1.1)
    nonisolated(unsafe) public static let ENGLISH  = Locale("en")
    nonisolated(unsafe) public static let FRENCH   = Locale("fr")
    nonisolated(unsafe) public static let GERMAN   = Locale("de")
    nonisolated(unsafe) public static let ITALIAN  = Locale("it")
    nonisolated(unsafe) public static let JAPANESE = Locale("ja")
    nonisolated(unsafe) public static let KOREAN   = Locale("ko")
    nonisolated(unsafe) public static let CHINESE  = Locale("zh")

    // MARK: - Country/region constants (Java 1.1)
    nonisolated(unsafe) public static let US      = Locale("en_US")
    nonisolated(unsafe) public static let UK      = Locale("en_GB")
    nonisolated(unsafe) public static let CANADA  = Locale("en_CA")
    nonisolated(unsafe) public static let FRANCE  = Locale("fr_FR")
    nonisolated(unsafe) public static let GERMANY = Locale("de_DE")
    nonisolated(unsafe) public static let ITALY   = Locale("it_IT")
    nonisolated(unsafe) public static let JAPAN   = Locale("ja_JP")
    nonisolated(unsafe) public static let KOREA   = Locale("ko_KR")
    nonisolated(unsafe) public static let CHINA   = Locale("zh_CN")

    public var delegate : Foundation.Locale!
    
    // MARK: - Default locale (global, thread-unsafe — matches Java behaviour)

    nonisolated(unsafe) private static var _default: Locale? = nil

    public static func getDefault() -> Locale {
      return _default ?? Locale()
    }

    /// Sets the default locale for this JVM instance.
    ///
    /// Equivalent to Java's `Locale.setDefault(Locale)`.
    /// Affects all locale-sensitive operations that use `Locale.getDefault()`,
    /// including `Java2SwiftFormatter` grouping/decimal output.
    public static func setDefault(_ locale: Locale) {
      _default = locale
    }
    
    public init() {
      delegate = Foundation.Locale.current
    }
    
    public init (_ languageCode: String) {
      delegate = Foundation.Locale(identifier: languageCode)
    }

    /// Creates a Locale from a language code and a country/region code.
    /// - Parameters:
    ///   - language: ISO 639 language code, e.g. `"de"`
    ///   - country: ISO 3166-1 alpha-2 country code, e.g. `"DE"`
    public init (_ language: String, _ country: String) {
      delegate = Foundation.Locale(identifier: country.isEmpty ? language : "\(language)_\(country)")
    }
    
    /// The country (region) code of this Locale, uppercase.
    /// - Returns The ISO 3166-2 country code, or the empty string if none is defined.
    public func getCountry() -> String {
      delegate.region?.identifier ?? ""
    }

    /// Returns a POSIX locale string suitable for `setlocale(3)`, e.g. `"de_DE.UTF-8"`.
    /// Always appends `.UTF-8` so X11 font sets and multibyte rendering work correctly.
    /// - Note: Not part of the Java API — JavApi4Swift internal helper for platform bridges.
    func toPosixLocale() -> String {
      let lang    = getLanguage()
      let country = getCountry()
      guard !lang.isEmpty else { return "en_US.UTF-8" }
      if country.isEmpty { return "\(lang).UTF-8" }
      return "\(lang)_\(country).UTF-8"
    }

    /// The language code of Locale
    /// - Returns The language code, or the empty string if none is defined.
    ///
    /// - Important: Java Locale's constructor has always converted three language codes to their earlier, obsoleted forms: he maps to iw, yi maps to ji, and id maps to in. Since Java SE 17, this is no longer the case. Each language maps to its new form; iw maps to he, ji maps to yi, and in maps to id. (see Legacy Language Codes https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/Locale.html#legacy_language_codes)
    /// - Note: Implementation use system property `java.expected.version` to control the return
    public func getLanguage() -> String {
      let langCode = self.delegate.language.languageCode?.identifier ?? ""
      
      if "true" == System.getProperty("java.locale.useOldISOCodes", "false") {
        switch langCode {
        case "he" : return "iw"
        case "ye" : return "ji"
        case "id" : return "in"
        default:
          return langCode
        }
      }
      return langCode
    }
  }
  
}
