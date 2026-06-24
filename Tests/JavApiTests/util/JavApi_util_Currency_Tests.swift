/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Currency_Tests {

  // MARK: - getInstance(String)

  @Test("getInstance returns instance for valid ISO 4217 code")
  func testGetInstanceValid() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    #expect(eur.getCurrencyCode() == "EUR")
  }

  @Test("getInstance is case-insensitive")
  func testGetInstanceCaseInsensitive() throws {
    let a = try java.util.Currency.getInstance("eur")
    let b = try java.util.Currency.getInstance("EUR")
    #expect(a == b)
  }

  @Test("getInstance throws for unknown code")
  func testGetInstanceInvalid() {
    #expect(throws: IllegalArgumentException.self) {
      try java.util.Currency.getInstance("XYZ")
    }
  }

  @Test("getInstance returns same (cached) instance for same code")
  func testGetInstanceCached() throws {
    let a = try java.util.Currency.getInstance("USD")
    let b = try java.util.Currency.getInstance("USD")
    #expect(a === b)
  }

  // MARK: - getInstance(Locale)

  @Test("getInstance(Locale) returns correct currency for locale")
  func testGetInstanceLocale() throws {
    let locale = java.util.Locale("de", "DE")
    let currency = try java.util.Currency.getInstance(locale)
    #expect(currency.getCurrencyCode() == "EUR")
  }

  // MARK: - getCurrencyCode

  @Test("getCurrencyCode returns uppercased ISO code")
  func testGetCurrencyCode() throws {
    #expect(try java.util.Currency.getInstance("USD").getCurrencyCode() == "USD")
    #expect(try java.util.Currency.getInstance("JPY").getCurrencyCode() == "JPY")
    #expect(try java.util.Currency.getInstance("GBP").getCurrencyCode() == "GBP")
  }

  // MARK: - getDefaultFractionDigits

  @Test("getDefaultFractionDigits returns 2 for EUR and USD")
  func testFractionDigitsStandard() throws {
    #expect(try java.util.Currency.getInstance("EUR").getDefaultFractionDigits() == 2)
    #expect(try java.util.Currency.getInstance("USD").getDefaultFractionDigits() == 2)
  }

  @Test("getDefaultFractionDigits returns 0 for JPY")
  func testFractionDigitsJPY() throws {
    #expect(try java.util.Currency.getInstance("JPY").getDefaultFractionDigits() == 0)
  }

  // MARK: - getNumericCode

  @Test("getNumericCode returns correct ISO 4217 numeric codes")
  func testGetNumericCode() throws {
    #expect(try java.util.Currency.getInstance("EUR").getNumericCode() == 978)
    #expect(try java.util.Currency.getInstance("USD").getNumericCode() == 840)
    #expect(try java.util.Currency.getInstance("JPY").getNumericCode() == 392)
    #expect(try java.util.Currency.getInstance("GBP").getNumericCode() == 826)
    #expect(try java.util.Currency.getInstance("CHF").getNumericCode() == 756)
  }

  // MARK: - getSymbol / getDisplayName

  @Test("getSymbol(locale) returns correct symbol for fixed locale")
  func testGetSymbolWithLocale() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    let usd = try java.util.Currency.getInstance("USD")
    let enUS = java.util.Locale("en", "US")
    // EUR symbol is "€" regardless of locale
    #expect(eur.getSymbol(enUS) == "€")
    // USD symbol in en_US is "$"
    #expect(usd.getSymbol(enUS) == "$")
  }

  @Test("getSymbol() without locale returns non-empty string")
  func testGetSymbolDefault() throws {
    let symbol = try java.util.Currency.getInstance("EUR").getSymbol()
    #expect(!symbol.isEmpty)
  }

  @Test("getDisplayName(locale) returns known name for fixed locale")
  func testGetDisplayNameWithLocale() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    let enUS = java.util.Locale("en", "US")
    let name = eur.getDisplayName(enUS)
    // Foundation returns "Euro" for EUR in en_US
    #expect(name == "Euro")
  }

  @Test("getDisplayName() without locale returns non-empty string")
  func testGetDisplayNameDefault() throws {
    let name = try java.util.Currency.getInstance("EUR").getDisplayName()
    #expect(!name.isEmpty)
  }

  // MARK: - getAvailableCurrencies

  @Test("getAvailableCurrencies returns non-empty set")
  func testGetAvailableCurrencies() {
    let currencies = java.util.Currency.getAvailableCurrencies()
    #expect(!currencies.isEmpty)
  }

  @Test("getAvailableCurrencies contains EUR and USD")
  func testGetAvailableCurrenciesContainsCommon() {
    let currencies = java.util.Currency.getAvailableCurrencies()
    let codes = Set(currencies.map { $0.getCurrencyCode() })
    #expect(codes.contains("EUR"))
    #expect(codes.contains("USD"))
  }

  // MARK: - Equatable / Hashable

  @Test("same currency code compares equal")
  func testEquatable() throws {
    let a = try java.util.Currency.getInstance("EUR")
    let b = try java.util.Currency.getInstance("EUR")
    #expect(a == b)
  }

  @Test("different currency codes are not equal")
  func testNotEqual() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    let usd = try java.util.Currency.getInstance("USD")
    #expect(eur != usd)
  }

  @Test("equal currencies have same hash value")
  func testHashable() throws {
    let a = try java.util.Currency.getInstance("USD")
    let b = try java.util.Currency.getInstance("USD")
    #expect(a.hashValue == b.hashValue)
  }

  @Test("Currency can be used as Set element")
  func testUsableInSet() throws {
    var set = Swift.Set<java.util.Currency>()
    set.insert(try java.util.Currency.getInstance("EUR"))
    set.insert(try java.util.Currency.getInstance("EUR")) // duplicate
    set.insert(try java.util.Currency.getInstance("USD"))
    #expect(set.count == 2)
  }

  // MARK: - description

  @Test("description returns currency code")
  func testDescription() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    #expect(eur.description == "EUR")
  }
}
