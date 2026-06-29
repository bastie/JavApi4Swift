/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  /// Represents a currency, mirroring `java.util.Currency`.
  ///
  /// Backed by Foundation's `Locale` infrastructure. Currency instances are
  /// canonicalized by ISO 4217 currency code — `getInstance` always returns
  /// the same object for the same code.
  public final class Currency : Equatable, Hashable, CustomStringConvertible, Sendable {

    // MARK: - Cache
    // `nonisolated(unsafe)` allows mutable static access in Swift 6;
    // correctness is guaranteed by `lock` (mirrors Java's synchronized cache).
    nonisolated(unsafe) private static var instances: [String: Currency] = [:]
    private static let lock = NSLock()

    // MARK: - Storage

    private let currencyCode: String

    // MARK: - Factory methods

    /// Returns the `Currency` instance for the given ISO 4217 currency code.
    /// - Throws: `IllegalArgumentException` if the code is not a known ISO 4217 currency.
    public static func getInstance(_ currencyCode: String) throws(IllegalArgumentException) -> Currency {
      let code = currencyCode.uppercased()
      // Validate: Foundation can resolve a symbol for known codes
      let testLocale = Foundation.Locale(identifier: "en_US")
      guard testLocale.localizedString(forCurrencyCode: code) != nil else {
        throw IllegalArgumentException("Unknown currency code: \(currencyCode)")
      }
      lock.lock(); defer { lock.unlock() }
      if let cached = instances[code] { return cached }
      let instance = Currency(code)
      instances[code] = instance
      return instance
    }

    /// Returns the `Currency` instance for the given `java.util.Locale`.
    public static func getInstance(_ locale: java.util.Locale) throws(IllegalArgumentException) -> Currency {
      guard let code = locale.delegate.currency?.identifier else {
        throw IllegalArgumentException("No currency for locale: \(locale.delegate.identifier)")
      }
      return try getInstance(code)
    }

    // MARK: - Private init

    private init(_ code: String) {
      self.currencyCode = code
    }

    // MARK: - Java API

    /// Returns the ISO 4217 currency code.
    public func getCurrencyCode() -> String { currencyCode }

    /// Returns the symbol for the default locale.
    public func getSymbol() -> String {
      getSymbol(java.util.Locale.getDefault())
    }

    /// Returns the symbol for the given locale.
    public func getSymbol(_ locale: java.util.Locale) -> String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.locale = locale.delegate
      formatter.currencyCode = currencyCode
      return formatter.currencySymbol ?? currencyCode
    }

    /// Returns the default number of fraction digits (e.g. 2 for EUR, 0 for JPY).
    /// Returns -1 for pseudo-currencies (e.g. XAU).
    public func getDefaultFractionDigits() -> Int {
      // ISO 4217 fraction digits — explicit table for reliable cross-platform behaviour.
      // swift-corelibs-foundation on Linux does not always return correct values
      // from NumberFormatter for non-standard fraction counts.
      // 0 fraction digits
      let zeroFractionCurrencies: Swift.Set<String> = [
        "BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW",
        "MGA", "PYG", "RWF", "UGX", "UYI", "VND", "VUV", "XAF",
        "XOF", "XPF"
      ]
      // 3 fraction digits
      let threeFractionCurrencies: Swift.Set<String> = [
        "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND"
      ]
      // -1 for pseudo-currencies / no minor unit
      let minusOneCurrencies: Swift.Set<String> = [
        "XAU", "XAG", "XPD", "XPT", "XDR", "XBA", "XBB", "XBC", "XBD", "XTS", "XXX"
      ]
      if zeroFractionCurrencies.contains(currencyCode) { return 0 }
      if threeFractionCurrencies.contains(currencyCode) { return 3 }
      if minusOneCurrencies.contains(currencyCode) { return -1 }
      // Default: 2 (covers EUR, USD, GBP, …)
      return 2
    }

    /// Returns the display name for the default locale.
    public func getDisplayName() -> String {
      getDisplayName(java.util.Locale.getDefault())
    }

    /// Returns the display name for the given locale.
    public func getDisplayName(_ locale: java.util.Locale) -> String {
      locale.delegate.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }

    /// Returns the numeric code of this currency (ISO 4217).
    /// Returns -1 if the code is not found.
    public func getNumericCode() -> Int {
      // ISO 4217 numeric codes — commonly used subset
      let numericCodes: [String: Int] = [
        "AED": 784, "AFN": 971, "ALL": 8, "AMD": 51, "ANG": 532,
        "AOA": 973, "ARS": 32, "AUD": 36, "AWG": 533, "AZN": 944,
        "BAM": 977, "BBD": 52, "BDT": 50, "BGN": 975, "BHD": 48,
        "BMD": 60, "BND": 96, "BOB": 68, "BRL": 986, "BSD": 44,
        "BTN": 64, "BWP": 72, "BYN": 933, "BZD": 84, "CAD": 124,
        "CDF": 976, "CHF": 756, "CLP": 152, "CNY": 156, "COP": 170,
        "CRC": 188, "CUP": 192, "CVE": 132, "CZK": 203, "DJF": 262,
        "DKK": 208, "DOP": 214, "DZD": 12, "EGP": 818, "ERN": 232,
        "ETB": 230, "EUR": 978, "FJD": 242, "GBP": 826, "GEL": 981,
        "GHS": 936, "GNF": 324, "GTQ": 320, "GYD": 328, "HKD": 344,
        "HNL": 340, "HRK": 191, "HTG": 332, "HUF": 348, "IDR": 360,
        "ILS": 376, "INR": 356, "IQD": 368, "IRR": 364, "ISK": 352,
        "JMD": 388, "JOD": 400, "JPY": 392, "KES": 404, "KGS": 417,
        "KHR": 116, "KMF": 174, "KPW": 408, "KRW": 410, "KWD": 414,
        "KYD": 136, "KZT": 398, "LAK": 418, "LBP": 422, "LKR": 144,
        "LRD": 430, "LSL": 426, "LYD": 434, "MAD": 504, "MDL": 498,
        "MKD": 807, "MMK": 104, "MNT": 496, "MOP": 446, "MRU": 929,
        "MUR": 480, "MVR": 462, "MWK": 454, "MXN": 484, "MYR": 458,
        "MZN": 943, "NAD": 516, "NGN": 566, "NIO": 558, "NOK": 578,
        "NPR": 524, "NZD": 554, "OMR": 512, "PAB": 590, "PEN": 604,
        "PGK": 598, "PHP": 608, "PKR": 586, "PLN": 985, "PYG": 600,
        "QAR": 634, "RON": 946, "RSD": 941, "RUB": 643, "RWF": 646,
        "SAR": 682, "SBD": 90, "SCR": 690, "SDG": 938, "SEK": 752,
        "SGD": 702, "SLL": 694, "SOS": 706, "SRD": 968, "STN": 930,
        "SVC": 222, "SYP": 760, "SZL": 748, "THB": 764, "TJS": 972,
        "TMT": 934, "TND": 788, "TOP": 776, "TRY": 949, "TTD": 780,
        "TWD": 901, "TZS": 834, "UAH": 980, "UGX": 800, "USD": 840,
        "UYU": 858, "UZS": 860, "VES": 928, "VND": 704, "VUV": 548,
        "WST": 882, "XAF": 950, "XCD": 951, "XOF": 952, "XPF": 953,
        "YER": 886, "ZAR": 710, "ZMW": 967
      ]
      return numericCodes[currencyCode] ?? -1
    }

    // MARK: - Available currencies

    /// Returns a set of all available currencies.
    public static func getAvailableCurrencies() -> Swift.Set<Currency> {
      var result = Swift.Set<Currency>()
      for code in Foundation.Locale.Currency.isoCurrencies {
        if let c = try? getInstance(code.identifier) { result.insert(c) }
      }
      return result
    }

    // MARK: - Protocol conformances

    public var description: String { currencyCode }

    public static func == (lhs: Currency, rhs: Currency) -> Bool {
      lhs.currencyCode == rhs.currencyCode
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(currencyCode)
    }
  }
}
