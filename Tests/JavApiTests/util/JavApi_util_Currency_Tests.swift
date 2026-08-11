/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Currency_Tests {

  // MARK: - getInstance

  @Test("getInstance returns instance for valid code EUR")
  func testGetInstance_EUR() throws {
    let c = try java.util.Currency.getInstance("EUR")
    #expect(c.getCurrencyCode() == "EUR")
  }

  @Test("getInstance returns instance for valid code USD")
  func testGetInstance_USD() throws {
    let c = try java.util.Currency.getInstance("USD")
    #expect(c.getCurrencyCode() == "USD")
  }

  @Test("getInstance is case-insensitive")
  func testGetInstance_lowercase() throws {
    let c = try java.util.Currency.getInstance("eur")
    #expect(c.getCurrencyCode() == "EUR")
  }

  @Test("getInstance caches: same code returns same instance")
  func testGetInstance_cached() throws {
    let a = try java.util.Currency.getInstance("USD")
    let b = try java.util.Currency.getInstance("USD")
    #expect(a === b)
  }

  @Test("getInstance throws for unknown code")
  func testGetInstance_unknownThrows() {
    #expect(throws: (any Error).self) {
      _ = try java.util.Currency.getInstance("XYZ_INVALID")
    }
  }

  // MARK: - getDefaultFractionDigits

  @Test("getDefaultFractionDigits returns 2 for EUR")
  func testFractionDigits_EUR() throws {
    let c = try java.util.Currency.getInstance("EUR")
    #expect(c.getDefaultFractionDigits() == 2)
  }

  @Test("getDefaultFractionDigits returns 0 for JPY")
  func testFractionDigits_JPY() throws {
    let c = try java.util.Currency.getInstance("JPY")
    #expect(c.getDefaultFractionDigits() == 0)
  }

  @Test("getDefaultFractionDigits returns 3 for BHD")
  func testFractionDigits_BHD() throws {
    let c = try java.util.Currency.getInstance("BHD")
    #expect(c.getDefaultFractionDigits() == 3)
  }

  @Test("getDefaultFractionDigits returns -1 for XAU (gold)")
  func testFractionDigits_XAU() throws {
    let c = try java.util.Currency.getInstance("XAU")
    #expect(c.getDefaultFractionDigits() == -1)
  }

  // MARK: - getNumericCode

  @Test("getNumericCode returns 978 for EUR")
  func testNumericCode_EUR() throws {
    let c = try java.util.Currency.getInstance("EUR")
    #expect(c.getNumericCode() == 978)
  }

  @Test("getNumericCode returns 840 for USD")
  func testNumericCode_USD() throws {
    let c = try java.util.Currency.getInstance("USD")
    #expect(c.getNumericCode() == 840)
  }

  @Test("getNumericCode returns 392 for JPY")
  func testNumericCode_JPY() throws {
    let c = try java.util.Currency.getInstance("JPY")
    #expect(c.getNumericCode() == 392)
  }

  // MARK: - getSymbol / getDisplayName

  @Test("getSymbol returns non-empty string")
  func testGetSymbol_nonEmpty() throws {
    let c = try java.util.Currency.getInstance("USD")
    #expect(!c.getSymbol().isEmpty)
  }

  @Test("getDisplayName returns non-empty string")
  func testGetDisplayName_nonEmpty() throws {
    let c = try java.util.Currency.getInstance("EUR")
    #expect(!c.getDisplayName().isEmpty)
  }

  // MARK: - Equatable / Hashable

  @Test("equal currencies compare equal")
  func testEquatable_equal() throws {
    let a = try java.util.Currency.getInstance("GBP")
    let b = try java.util.Currency.getInstance("GBP")
    #expect(a == b)
  }

  @Test("different currencies compare not equal")
  func testEquatable_notEqual() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    let gbp = try java.util.Currency.getInstance("GBP")
    #expect(eur != gbp)
  }

  // MARK: - getAvailableCurrencies

  @Test("getAvailableCurrencies returns non-empty set")
  func testGetAvailableCurrencies_nonEmpty() {
    let all = java.util.Currency.getAvailableCurrencies()
    #expect(!all.isEmpty)
  }

  @Test("getAvailableCurrencies contains EUR")
  func testGetAvailableCurrencies_containsEUR() throws {
    let eur = try java.util.Currency.getInstance("EUR")
    let all = java.util.Currency.getAvailableCurrencies()
    #expect(all.contains(eur))
  }
}
