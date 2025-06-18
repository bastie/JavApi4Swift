/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Locale {
    public var delegate : Foundation.Locale!
    
    public static func getDefault() -> Locale {
      return Locale()
    }
    
    public init() {
      delegate = Foundation.Locale.current
    }
    
    public init (_ languageCode: String) {
      delegate = Foundation.Locale(identifier: languageCode)
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
