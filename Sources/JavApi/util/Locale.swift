/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  open class Locale : Equatable {
    
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

    // MARK: - Additional constants (Java 6)
    /// Simplified Chinese locale (PRC).
    nonisolated(unsafe) public static let SIMPLIFIED_CHINESE  = Locale("zh_CN")
    /// Traditional Chinese locale (Taiwan).
    nonisolated(unsafe) public static let TRADITIONAL_CHINESE = Locale("zh_TW")
    /// Alias for `SIMPLIFIED_CHINESE` — the locale for the People's Republic of China.
    nonisolated(unsafe) public static let PRC                 = Locale("zh_CN")
    /// Alias for `TRADITIONAL_CHINESE` — the locale for Taiwan.
    nonisolated(unsafe) public static let TAIWAN              = Locale("zh_TW")
    /// The root locale. Its language, country, and variant are empty strings.
    nonisolated(unsafe) public static let ROOT                = Locale("")
    
    public var delegate : Foundation.Locale!

    /// The locale identifier exactly as passed by the caller — NOT Foundation-normalised.
    ///
    /// Foundation normalises some codes (e.g. "no" → "nb") which would cause
    /// `getLanguage()`, `getVariant()`, and `toString()` to return wrong values.
    /// This field stores the raw string so those methods can parse it directly.
    private let _originalIdentifier: String

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
      let foundationLocale = Foundation.Locale.current
      _originalIdentifier = foundationLocale.identifier
      delegate = foundationLocale
    }

    public init (_ languageCode: String) {
      _originalIdentifier = languageCode
      delegate = Foundation.Locale(identifier: languageCode)
    }

    /// Creates a Locale from a language code and a country/region code.
    /// - Parameters:
    ///   - language: ISO 639 language code, e.g. `"de"`
    ///   - country: ISO 3166-1 alpha-2 country code, e.g. `"DE"`
    public init (_ language: String, _ country: String) {
      let id = country.isEmpty ? language : "\(language)_\(country)"
      _originalIdentifier = id
      delegate = Foundation.Locale(identifier: id)
    }

    /// Creates a Locale from a language code, country/region code, and variant.
    ///
    /// - Parameters:
    ///   - language: ISO 639 language code, e.g. `"en"`
    ///   - country: ISO 3166-1 alpha-2 country code, e.g. `"CA"` (may be empty)
    ///   - variant: Variant code, e.g. `"WIN32"` (may be empty)
    /// - Since: Java 1.1
    public init (_ language: String, _ country: String, _ variant: String) {
      // Build a POSIX-style identifier: language[_COUNTRY[_VARIANT]]
      // Empty components are preserved in _originalIdentifier so that
      // getLanguage/getCountry/getVariant/toString can parse them correctly.
      var id = language
      if !country.isEmpty || !variant.isEmpty {
        id += "_\(country)"
      }
      if !variant.isEmpty {
        id += "_\(variant)"
      }
      _originalIdentifier = id
      delegate = Foundation.Locale(identifier: id)
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
      // Parse directly from the original identifier to avoid Foundation normalisation
      // (e.g. Foundation maps "no" → "nb" for Norwegian Bokmål).
      let parts = _originalIdentifier.split(separator: "_", maxSplits: 1,
                                            omittingEmptySubsequences: false)
      let langCode = parts.isEmpty ? "" : String(parts[0])

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
    
    // MARK: - Variant (Java 1.1)

    /// Returns the variant component of this locale.
    ///
    /// Foundation does not expose the variant directly; it is parsed from the
    /// locale identifier string which has the form `language_COUNTRY_VARIANT`.
    ///
    /// - Returns: The variant code, or the empty string if none.
    /// - Since: Java 1.1
    public func getVariant() -> String {
      // Parse from the original identifier so Foundation normalisation (e.g. "no"→"nb")
      // does not affect the variant returned by this method.
      //
      // The identifier shape is language[_SCRIPT][_COUNTRY][_VARIANT], where
      // SCRIPT (if present) is exactly 4 letters and COUNTRY (if present) is
      // 2 letters or 3 digits — both optional, so the variant's position is
      // not fixed and must be found by skipping over whichever of the two
      // are actually present, rather than always assuming index 2.
      let parts = _originalIdentifier.split(separator: "_",
                                            omittingEmptySubsequences: false)
                                     .map(String.init)
      guard parts.count >= 2 else { return "" }
      var index = 1
      if parts[index].count == 4, parts[index].allSatisfy({ $0.isLetter }) {
        index += 1  // skip script
      }
      if index < parts.count {
        let candidate = parts[index]
        if candidate.isEmpty
            || (candidate.count == 2 && candidate.allSatisfy({ $0.isLetter }))
            || (candidate.count == 3 && candidate.allSatisfy({ $0.isNumber })) {
          index += 1  // skip country (an empty candidate is the blank country
                       // placeholder the legacy 3-arg constructor inserts when
                       // called with an empty country but a non-empty variant)
        }
      }
      guard index < parts.count else { return "" }
      return parts[index...].joined(separator: "_")
    }

    // MARK: - toString (Java 1.1)

    /// Returns a string representation of this locale.
    ///
    /// Format: `language_COUNTRY_VARIANT`, with trailing components omitted when
    /// empty. For example: `"en"`, `"en_US"`, `"no_NO_NY"`.
    ///
    /// Per Java spec: if both language and country are empty, returns `""` even
    /// when a variant is present. A country-only locale uses `"_COUNTRY"` format.
    ///
    /// - Since: Java 1.1
    open func toString() -> String {
      let lang    = getLanguage()
      let country = getCountry()
      let variant = getVariant()
      // Java spec: empty language AND empty country → always ""
      if lang.isEmpty && country.isEmpty { return "" }
      if !variant.isEmpty { return "\(lang)_\(country)_\(variant)" }
      if !country.isEmpty { return "\(lang)_\(country)" }
      return lang
    }

    // MARK: - clone (Java 1.1)

    /// Returns a copy of this Locale.
    ///
    /// - Since: Java 1.1
    open func clone() -> java.util.Locale {
      // _originalIdentifier carries all components; delegate is Foundation-backed
      return java.util.Locale(_originalIdentifier)
    }

    // MARK: - Display methods (Java 1.1)

    /// Returns the locale's language name in the default locale.
    /// - Since: Java 1.1
    public func getDisplayLanguage() -> String {
      getDisplayLanguage(java.util.Locale.getDefault())
    }

    /// Returns the locale's language name in the given locale.
    /// - Since: Java 1.1
    public func getDisplayLanguage(_ inLocale: java.util.Locale) -> String {
      let langCode = getLanguage()
      guard !langCode.isEmpty else { return "" }
      return inLocale.delegate.localizedString(forLanguageCode: langCode) ?? langCode
    }

    /// Returns the locale's country/region name in the default locale.
    /// - Since: Java 1.1
    public func getDisplayCountry() -> String {
      getDisplayCountry(java.util.Locale.getDefault())
    }

    /// Returns the locale's country/region name in the given locale.
    /// - Since: Java 1.1
    public func getDisplayCountry(_ inLocale: java.util.Locale) -> String {
      let countryCode = getCountry()
      guard !countryCode.isEmpty else { return "" }
      return inLocale.delegate.localizedString(forRegionCode: countryCode) ?? countryCode
    }

    /// Returns the locale's variant name in the default locale.
    ///
    /// Foundation does not provide localised variant names; the raw variant code
    /// is returned unchanged.
    /// - Since: Java 1.1
    public func getDisplayVariant() -> String {
      getVariant()
    }

    /// Returns the locale's variant name in the given locale.
    ///
    /// Foundation does not provide localised variant names; the raw variant code
    /// is returned unchanged regardless of `inLocale`.
    /// - Since: Java 1.1
    public func getDisplayVariant(_ inLocale: java.util.Locale) -> String {
      getVariant()
    }

    /// Returns the name of this locale in the default locale.
    ///
    /// Format: `"language (country)"` if a country is present, otherwise just
    /// the language name.
    /// - Since: Java 1.1
    public func getDisplayName() -> String {
      getDisplayName(java.util.Locale.getDefault())
    }

    /// Returns the name of this locale in the given locale.
    /// - Since: Java 1.1
    public func getDisplayName(_ inLocale: java.util.Locale) -> String {
      let lang    = getDisplayLanguage(inLocale)
      let country = getDisplayCountry(inLocale)
      if country.isEmpty { return lang }
      return "\(lang) (\(country))"
    }

    // MARK: - ISO3 codes (Java 1.1)

    /// Returns the ISO 639-2/T three-letter code for this locale's language.
    ///
    /// Throws `MissingResourceException` if no three-letter code is defined.
    /// - Since: Java 1.1
    public func getISO3Language() throws -> String {
      let code = getLanguage()
      guard !code.isEmpty else { return "" }
      if let iso3 = java.util.Locale._iso639_1to3[code] { return iso3 }
      throw java.util.MissingResourceException(
        "Can't find three-letter language code for \(code)",
        "java.util.Locale", code)
    }

    /// Returns the ISO 3166-1 alpha-3 three-letter code for this locale's country.
    ///
    /// Throws `MissingResourceException` if no three-letter code is defined.
    /// - Since: Java 1.1
    public func getISO3Country() throws -> String {
      let code = getCountry()
      guard !code.isEmpty else { return "" }
      if let iso3 = java.util.Locale._iso3166alpha2to3[code] { return iso3 }
      throw java.util.MissingResourceException(
        "Can't find three-letter country code for \(code)",
        "java.util.Locale", code)
    }

    // MARK: - Static factory methods (Java 1.1)

    /// Returns an array of all installed locales.
    /// - Since: Java 1.1
    public static func getAvailableLocales() -> [java.util.Locale] {
      return Foundation.Locale.availableIdentifiers.map { java.util.Locale($0) }
    }

    /// Returns an array of all ISO 639-1 two-letter language codes.
    /// - Since: Java 1.1
    public static func getISOLanguages() -> [String] {
      return Foundation.Locale.LanguageCode.isoLanguageCodes.map { $0.identifier }
    }

    /// Returns an array of all ISO 3166-1 alpha-2 two-letter country codes.
    /// - Since: Java 1.1
    public static func getISOCountries() -> [String] {
      return Foundation.Locale.Region.isoRegions.map { $0.identifier }
    }

    // MARK: - ISO lookup tables (private)

    /// ISO 639-1 (2-letter) → ISO 639-2/T (3-letter) for common languages.
    internal static let _iso639_1to3: [String: String] = [
      "ab": "abk", "aa": "aar", "af": "afr", "ak": "aka", "sq": "sqi",
      "am": "amh", "ar": "ara", "an": "arg", "hy": "hye", "as": "asm",
      "av": "ava", "ae": "ave", "ay": "aym", "az": "aze", "bm": "bam",
      "ba": "bak", "eu": "eus", "be": "bel", "bn": "ben", "bh": "bih",
      "bi": "bis", "bs": "bos", "br": "bre", "bg": "bul", "my": "mya",
      "ca": "cat", "ch": "cha", "ce": "che", "ny": "nya", "zh": "zho",
      "cv": "chv", "kw": "cor", "co": "cos", "cr": "cre", "hr": "hrv",
      "cs": "ces", "da": "dan", "dv": "div", "nl": "nld", "dz": "dzo",
      "en": "eng", "eo": "epo", "et": "est", "ee": "ewe", "fo": "fao",
      "fj": "fij", "fi": "fin", "fr": "fra", "ff": "ful", "gl": "glg",
      "ka": "kat", "de": "deu", "el": "ell", "gn": "grn", "gu": "guj",
      "ht": "hat", "ha": "hau", "he": "heb", "hz": "her", "hi": "hin",
      "ho": "hmo", "hu": "hun", "ia": "ina", "id": "ind", "ie": "ile",
      "ga": "gle", "ig": "ibo", "ik": "ipk", "io": "ido", "is": "isl",
      "it": "ita", "iu": "iku", "ja": "jpn", "jv": "jav", "kl": "kal",
      "kn": "kan", "kr": "kau", "ks": "kas", "kk": "kaz", "km": "khm",
      "ki": "kik", "rw": "kin", "ky": "kir", "kv": "kom", "kg": "kon",
      "ko": "kor", "ku": "kur", "kj": "kua", "la": "lat", "lb": "ltz",
      "lg": "lug", "li": "lim", "ln": "lin", "lo": "lao", "lt": "lit",
      "lu": "lub", "lv": "lav", "gv": "glv", "mk": "mkd", "mg": "mlg",
      "ms": "msa", "ml": "mal", "mt": "mlt", "mi": "mri", "mr": "mar",
      "mh": "mah", "mn": "mon", "na": "nau", "nv": "nav", "nb": "nob",
      "nd": "nde", "ne": "nep", "ng": "ndo", "nn": "nno", "no": "nor",
      "ii": "iii", "nr": "nbl", "oc": "oci", "oj": "oji", "cu": "chu",
      "om": "orm", "or": "ori", "os": "oss", "pa": "pan", "pi": "pli",
      "fa": "fas", "pl": "pol", "ps": "pus", "pt": "por", "qu": "que",
      "rm": "roh", "rn": "run", "ro": "ron", "ru": "rus", "sa": "san",
      "sc": "srd", "sd": "snd", "se": "sme", "sm": "smo", "sg": "sag",
      "sr": "srp", "gd": "gla", "sn": "sna", "si": "sin", "sk": "slk",
      "sl": "slv", "so": "som", "st": "sot", "es": "spa", "su": "sun",
      "sw": "swa", "ss": "ssw", "sv": "swe", "ta": "tam", "te": "tel",
      "tg": "tgk", "th": "tha", "ti": "tir", "bo": "bod", "tk": "tuk",
      "tl": "tgl", "tn": "tsn", "to": "ton", "tr": "tur", "ts": "tso",
      "tt": "tat", "tw": "twi", "ty": "tah", "ug": "uig", "uk": "ukr",
      "ur": "urd", "uz": "uzb", "ve": "ven", "vi": "vie", "vo": "vol",
      "wa": "wln", "cy": "wel", "wo": "wol", "fy": "fry", "xh": "xho",
      "yi": "yid", "yo": "yor", "za": "zha", "zu": "zul",
      // Legacy codes (pre-Java 17)
      "iw": "heb", "ji": "yid", "in": "ind"
    ]

    /// ISO 3166-1 alpha-2 (2-letter) → alpha-3 (3-letter) for common countries.
    internal static let _iso3166alpha2to3: [String: String] = [
      "AF": "AFG", "AX": "ALA", "AL": "ALB", "DZ": "DZA", "AS": "ASM",
      "AD": "AND", "AO": "AGO", "AI": "AIA", "AQ": "ATA", "AG": "ATG",
      "AR": "ARG", "AM": "ARM", "AW": "ABW", "AU": "AUS", "AT": "AUT",
      "AZ": "AZE", "BS": "BHS", "BH": "BHR", "BD": "BGD", "BB": "BRB",
      "BY": "BLR", "BE": "BEL", "BZ": "BLZ", "BJ": "BEN", "BM": "BMU",
      "BT": "BTN", "BO": "BOL", "BA": "BIH", "BW": "BWA", "BR": "BRA",
      "BN": "BRN", "BG": "BGR", "BF": "BFA", "BI": "BDI", "KH": "KHM",
      "CM": "CMR", "CA": "CAN", "CV": "CPV", "KY": "CYM", "CF": "CAF",
      "TD": "TCD", "CL": "CHL", "CN": "CHN", "CO": "COL", "KM": "COM",
      "CG": "COG", "CD": "COD", "CR": "CRI", "CI": "CIV", "HR": "HRV",
      "CU": "CUB", "CY": "CYP", "CZ": "CZE", "DK": "DNK", "DJ": "DJI",
      "DM": "DMA", "DO": "DOM", "EC": "ECU", "EG": "EGY", "SV": "SLV",
      "GQ": "GNQ", "ER": "ERI", "EE": "EST", "ET": "ETH", "FJ": "FJI",
      "FI": "FIN", "FR": "FRA", "GA": "GAB", "GM": "GMB", "GE": "GEO",
      "DE": "DEU", "GH": "GHA", "GR": "GRC", "GD": "GRD", "GT": "GTM",
      "GN": "GIN", "GW": "GNB", "GY": "GUY", "HT": "HTI", "HN": "HND",
      "HK": "HKG", "HU": "HUN", "IS": "ISL", "IN": "IND", "ID": "IDN",
      "IR": "IRN", "IQ": "IRQ", "IE": "IRL", "IL": "ISR", "IT": "ITA",
      "JM": "JAM", "JP": "JPN", "JO": "JOR", "KZ": "KAZ", "KE": "KEN",
      "KI": "KIR", "KP": "PRK", "KR": "KOR", "KW": "KWT", "KG": "KGZ",
      "LA": "LAO", "LV": "LVA", "LB": "LBN", "LS": "LSO", "LR": "LBR",
      "LY": "LBY", "LI": "LIE", "LT": "LTU", "LU": "LUX", "MO": "MAC",
      "MK": "MKD", "MG": "MDG", "MW": "MWI", "MY": "MYS", "MV": "MDV",
      "ML": "MLI", "MT": "MLT", "MH": "MHL", "MR": "MRT", "MU": "MUS",
      "MX": "MEX", "FM": "FSM", "MD": "MDA", "MC": "MCO", "MN": "MNG",
      "ME": "MNE", "MA": "MAR", "MZ": "MOZ", "MM": "MMR", "NA": "NAM",
      "NR": "NRU", "NP": "NPL", "NL": "NLD", "NZ": "NZL", "NI": "NIC",
      "NE": "NER", "NG": "NGA", "NO": "NOR", "OM": "OMN", "PK": "PAK",
      "PW": "PLW", "PA": "PAN", "PG": "PNG", "PY": "PRY", "PE": "PER",
      "PH": "PHL", "PL": "POL", "PT": "PRT", "QA": "QAT", "RO": "ROU",
      "RU": "RUS", "RW": "RWA", "KN": "KNA", "LC": "LCA", "VC": "VCT",
      "WS": "WSM", "SM": "SMR", "ST": "STP", "SA": "SAU", "SN": "SEN",
      "RS": "SRB", "SC": "SYC", "SL": "SLE", "SG": "SGP", "SK": "SVK",
      "SI": "SVN", "SB": "SLB", "SO": "SOM", "ZA": "ZAF", "SS": "SSD",
      "ES": "ESP", "LK": "LKA", "SD": "SDN", "SR": "SUR", "SZ": "SWZ",
      "SE": "SWE", "CH": "CHE", "SY": "SYR", "TW": "TWN", "TJ": "TJK",
      "TZ": "TZA", "TH": "THA", "TL": "TLS", "TG": "TGO", "TO": "TON",
      "TT": "TTO", "TN": "TUN", "TR": "TUR", "TM": "TKM", "TV": "TUV",
      "UG": "UGA", "UA": "UKR", "AE": "ARE", "GB": "GBR", "US": "USA",
      "UY": "URY", "UZ": "UZB", "VU": "VUT", "VE": "VEN", "VN": "VNM",
      "YE": "YEM", "ZM": "ZMB", "ZW": "ZWE"
    ]

    open func equals (_ o: Any?) -> Bool {
      if let o = o as? Locale {
        return self.delegate == o.delegate
      }
      return false
    }
    
    open func hashCode () -> Int {
      return self.delegate.hashValue
    }
    
    public static func == (lhs: java.util.Locale, rhs: java.util.Locale) -> Bool {
      return lhs.delegate == rhs.delegate
    }

    // MARK: - Java 7 methods

    /// Returns the script subtag of this locale's BCP 47 tag, e.g. `"Latn"`, `"Hans"`.
    ///
    /// Foundation exposes the script through `Locale.language.script?.identifier`.
    /// Returns the empty string if no script is defined.
    ///
    /// - Since: Java 7
    public func getScript() -> String {
      // Foundation infers script subtags even when they are not explicitly in the
      // identifier (e.g. "en" → "Latn"). We only return a script when one is
      // explicitly present in the original identifier as a 4-letter component
      // in position 1 (after the language tag), e.g. "zh_Hant_TW" → "Hant".
      let parts = _originalIdentifier.split(separator: "_",
                                            omittingEmptySubsequences: false)
                                     .map(String.init)
      if parts.count >= 2 {
        let candidate = parts[1]
        if candidate.count == 4 && candidate.allSatisfy({ $0.isLetter }) {
          // Capitalise first letter, lowercase the rest — canonical BCP 47 script form.
          return candidate.prefix(1).uppercased() + candidate.dropFirst().lowercased()
        }
      }
      return ""
    }

    /// Returns a BCP 47 language tag representing this locale.
    ///
    /// Delegates to Foundation's `Locale.identifier(fromComponents:)` via
    /// `Locale.canonicalLanguageIdentifierFromString` semantics.  The result
    /// always uses hyphens as separators (BCP 47), not underscores (POSIX).
    ///
    /// - Since: Java 7
    public func toLanguageTag() -> String {
      // Use _originalIdentifier (not delegate.identifier) so Foundation normalisation
      // (e.g. "no" → "nb") does not affect the result.  POSIX identifiers use
      // underscores; BCP 47 uses hyphens — a straight replacement suffices.
      if _originalIdentifier.isEmpty { return "und" }  // BCP 47 undetermined language
      return _originalIdentifier.replacingOccurrences(of: "_", with: "-")
    }

    /// Converts a BCP 47 language tag to a `Locale`.
    ///
    /// Accepts both hyphen-separated BCP 47 tags (e.g. `"zh-Hans-CN"`) and
    /// underscore-separated POSIX identifiers (e.g. `"zh_CN"`).
    ///
    /// - Parameter languageTag: A BCP 47 language tag.
    /// - Returns: A `Locale` for the tag, or `Locale.ROOT` for `"und"`.
    /// - Since: Java 7
    public static func forLanguageTag(_ languageTag: String) -> java.util.Locale {
      if languageTag == "und" { return ROOT }
      // Convert hyphen-separated BCP 47 to Foundation identifier
      let identifier = languageTag.replacingOccurrences(of: "-", with: "_")
      return java.util.Locale(identifier)
    }

    // MARK: - Locale.Category (Java 7)

    /// Locale categories used by `setDefault(_:_:)` and `getDefault(_:)`.
    ///
    /// - Since: Java 7
    public enum Category {
      /// The display category — affects number, date, and string formatting
      /// shown to users.
      case DISPLAY
      /// The format category — affects parsing and formatting operations.
      case FORMAT
    }

  }
}

// MARK: - Locale.Builder (Java 7)

extension java.util.Locale {

  /// Builder for constructing well-formed `Locale` objects.
  ///
  /// All setter methods return `self` to enable chaining.  `build()` returns
  /// the constructed locale.
  ///
  /// - Since: Java 7
  public final class Builder {

    private var _language: String = ""
    private var _region:   String = ""
    private var _script:   String = ""
    private var _variant:  String = ""
    private var _extensions: [Character: String] = [:]
    /// Unicode locale extension ('u') keywords — a separate, dedicated store
    /// (2-character key -> 3-8-alphanum-subtag type), mirroring Java's own
    /// separation between `setExtension('u', ...)` and
    /// `setUnicodeLocaleKeyword(key, type)`. Merged into `_extensions['u']`
    /// (sorted by key, matching the BCP 47 canonical form) whenever read.
    private var _unicodeLocaleKeywords: [String: String] = [:]

    public init() {}

    /// Sets the language subtag.
    ///
    /// - Parameter language: A BCP 47 language subtag (e.g. `"en"`, `"zh"`).
    /// - Throws: `IllformedLocaleException` if the tag is syntactically invalid.
    @discardableResult
    public func setLanguage(_ language: String) throws -> Builder {
      guard language.isEmpty || language.allSatisfy({ $0.isLetter }) else {
        throw java.util.IllformedLocaleException(
          "Invalid language: \(language)", 0)
      }
      _language = language.lowercased()
      return self
    }

    /// Sets the region (country) subtag.
    ///
    /// - Parameter region: A BCP 47 region subtag (ISO 3166 alpha-2 or UN M.49).
    /// - Throws: `IllformedLocaleException` if the tag is syntactically invalid.
    @discardableResult
    public func setRegion(_ region: String) throws -> Builder {
      guard region.isEmpty ||
            (region.count == 2 && region.allSatisfy({ $0.isLetter })) ||
            (region.count == 3 && region.allSatisfy({ $0.isNumber })) else {
        throw java.util.IllformedLocaleException(
          "Invalid region: \(region)", 0)
      }
      _region = region.uppercased()
      return self
    }

    /// Sets the script subtag (e.g. `"Latn"`, `"Hans"`).
    /// - Throws: `IllformedLocaleException` if the tag is syntactically invalid.
    @discardableResult
    public func setScript(_ script: String) throws -> Builder {
      guard script.isEmpty || (script.count == 4 && script.allSatisfy({ $0.isLetter })) else {
        throw java.util.IllformedLocaleException(
          "Invalid script: \(script)", 0)
      }
      _script = script.capitalized
      return self
    }

    /// Sets the variant subtag.
    @discardableResult
    public func setVariant(_ variant: String) -> Builder {
      _variant = variant
      return self
    }

    /// Sets an extension using a single-character key and a value.
    ///
    /// - Throws: `IllformedLocaleException` for invalid keys or values.
    @discardableResult
    public func setExtension(_ key: Character, _ value: String) throws -> Builder {
      let valid = "abcdefghijklmnopqrstuvwxyz0123456789"
      guard valid.contains(key) else {
        throw java.util.IllformedLocaleException(
          "Invalid extension key: \(key)", 0)
      }
      if value.isEmpty {
        _extensions.removeValue(forKey: key)
      } else {
        _extensions[key] = value
      }
      return self
    }

    /// Resets all subtags from `locale`'s language, script, region, and variant.
    ///
    /// - Note: `java.util.Locale.Builder.setLocale(Locale)` also copies the
    ///   given locale's extensions. This port's `Locale` does not itself
    ///   store extensions (they exist only on `Builder`, and `build()` does
    ///   not yet encode them back into the constructed `Locale`'s
    ///   identifier — a pre-existing gap in this port, tracked separately
    ///   in `Util-Implementierung.md`), so there is nothing to copy here;
    ///   language/script/region/variant are copied in full.
    @discardableResult
    public func setLocale(_ locale: java.util.Locale) throws -> Builder {
      try setLanguage(locale.getLanguage())
      try setScript(locale.getScript())
      try setRegion(locale.getCountry())
      _ = setVariant(locale.getVariant())
      return self
    }

    /// Resets the `Builder` and configures it to match `languageTag`.
    ///
    /// Unlike `Locale.forLanguageTag(_:)` (which never throws and accepts
    /// any string), this validates each subtag's well-formedness against
    /// BCP 47 and throws `IllformedLocaleException` on the first invalid
    /// one — matching `java.util.Locale.Builder.setLanguageTag(String)`.
    @discardableResult
    public func setLanguageTag(_ languageTag: String) throws -> Builder {
      clear()
      let subtags = languageTag.split(separator: "-", omittingEmptySubsequences: false).map(String.init)
      guard let first = subtags.first, !first.isEmpty else {
        throw java.util.IllformedLocaleException("Empty language tag", 0)
      }

      // Private-use-only tag, e.g. "x-foo-bar".
      if first.lowercased() == "x" {
        _extensions["x"] = subtags.dropFirst().joined(separator: "-")
        return self
      }

      var index = 0

      // language: 2-8 letters ("und" means "no language", per BCP 47).
      let languageSubtag = subtags[index]
      guard languageSubtag.count >= 2 && languageSubtag.count <= 8
              && languageSubtag.allSatisfy({ $0.isLetter }) else {
        throw java.util.IllformedLocaleException("Invalid language: \(languageSubtag)", 0)
      }
      _language = languageSubtag.lowercased() == "und" ? "" : languageSubtag.lowercased()
      index += 1

      // script: exactly 4 letters.
      if index < subtags.count, subtags[index].count == 4, subtags[index].allSatisfy({ $0.isLetter }) {
        let s = subtags[index]
        _script = s.prefix(1).uppercased() + s.dropFirst().lowercased()
        index += 1
      }

      // region: 2 letters or 3 digits.
      if index < subtags.count {
        let s = subtags[index]
        if (s.count == 2 && s.allSatisfy({ $0.isLetter })) || (s.count == 3 && s.allSatisfy({ $0.isNumber })) {
          _region = s.uppercased()
          index += 1
        }
      }

      // variant(s): 5-8 alphanumeric, or exactly 4 starting with a digit.
      var variants: [String] = []
      while index < subtags.count {
        let s = subtags[index]
        let looksLikeVariant =
          (s.count >= 5 && s.count <= 8 && s.allSatisfy { $0.isLetter || $0.isNumber })
          || (s.count == 4 && (s.first?.isNumber ?? false) && s.allSatisfy { $0.isLetter || $0.isNumber })
        guard looksLikeVariant else { break }
        variants.append(s)
        index += 1
      }
      if !variants.isEmpty { _variant = variants.joined(separator: "_") }

      // extensions: a 1-character singleton followed by 1+ subtags of 2-8 alphanumerics.
      while index < subtags.count {
        let singleton = subtags[index]
        guard singleton.count == 1, let key = singleton.lowercased().first else {
          throw java.util.IllformedLocaleException("Invalid extension singleton: \(singleton)", index)
        }
        index += 1
        var values: [String] = []
        while index < subtags.count, (2...8).contains(subtags[index].count),
              subtags[index].allSatisfy({ $0.isLetter || $0.isNumber }) {
          values.append(subtags[index])
          index += 1
        }
        guard !values.isEmpty else {
          throw java.util.IllformedLocaleException("Extension '\(key)' has no subtags", index)
        }
        _extensions[key] = values.joined(separator: "-")
      }

      guard index == subtags.count else {
        throw java.util.IllformedLocaleException("Malformed language tag: \(languageTag)", index)
      }
      return self
    }

    /// Sets a keyword in the Unicode locale extension ('u'), e.g.
    /// `setUnicodeLocaleKeyword("ca", "buddhist")` for a calendar preference.
    ///
    /// - Parameters:
    ///   - key: A 2-character alphanumeric key (e.g. `"ca"`, `"nu"`, `"co"`).
    ///   - type: A `-`-joined sequence of 3-8-character alphanumeric subtags,
    ///     or the empty string to remove the keyword.
    /// - Throws: `IllformedLocaleException` if `key` or `type` is malformed.
    @discardableResult
    public func setUnicodeLocaleKeyword(_ key: String, _ type: String) throws -> Builder {
      guard key.count == 2, key.allSatisfy({ $0.isLetter || $0.isNumber }) else {
        throw java.util.IllformedLocaleException("Invalid Unicode locale keyword key: \(key)", 0)
      }
      let normalizedKey = key.lowercased()
      if type.isEmpty {
        _unicodeLocaleKeywords.removeValue(forKey: normalizedKey)
      } else {
        let typeSubtags = type.split(separator: "-").map(String.init)
        guard !typeSubtags.isEmpty,
              typeSubtags.allSatisfy({ (3...8).contains($0.count) && $0.allSatisfy({ c in c.isLetter || c.isNumber }) }) else {
          throw java.util.IllformedLocaleException("Invalid Unicode locale keyword type: \(type)", 0)
        }
        _unicodeLocaleKeywords[normalizedKey] = typeSubtags.joined(separator: "-").lowercased()
      }
      return self
    }

    /// Resets the `Builder` to its initial, empty state (language, script,
    /// region, variant, and all extensions — matches
    /// `java.util.Locale.Builder.clear()`).
    @discardableResult
    public func clear() -> Builder {
      _language = ""
      _region = ""
      _script = ""
      _variant = ""
      clearExtensions()
      return self
    }

    /// Removes all extensions (both `setExtension`-style and Unicode locale
    /// keywords), leaving language/script/region/variant untouched — matches
    /// `java.util.Locale.Builder.clearExtensions()`.
    @discardableResult
    public func clearExtensions() -> Builder {
      _extensions.removeAll()
      _unicodeLocaleKeywords.removeAll()
      return self
    }

    /// Constructs a `Locale` from the accumulated settings.
    public func build() -> java.util.Locale {
      // Build a POSIX-style identifier: language[_SCRIPT][_REGION][_VARIANT].
      // Every component is "_"-joined (not "-") so getLanguage()/getScript()/
      // getVariant() — which all parse the resulting Locale's identifier by
      // splitting on "_" — can find the script/region/variant components.
      var id = _language
      if !_script.isEmpty { id += "_\(_script)" }
      if !_region.isEmpty { id += "_\(_region)" }
      if !_variant.isEmpty { id += "_\(_variant)" }
      return java.util.Locale(id)
    }
  }
}
