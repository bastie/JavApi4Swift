/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Locale_Tests {

  // MARK: - Language constants

  @Test("Locale.ENGLISH has language code 'en'")
  func testEnglish() {
    #expect(java.util.Locale.ENGLISH.getLanguage() == "en")
  }

  @Test("Locale.GERMAN has language code 'de'")
  func testGerman() {
    #expect(java.util.Locale.GERMAN.getLanguage() == "de")
  }

  @Test("Locale.FRENCH has language code 'fr'")
  func testFrench() {
    #expect(java.util.Locale.FRENCH.getLanguage() == "fr")
  }

  @Test("Locale.ITALIAN has language code 'it'")
  func testItalian() {
    #expect(java.util.Locale.ITALIAN.getLanguage() == "it")
  }

  @Test("Locale.JAPANESE has language code 'ja'")
  func testJapanese() {
    #expect(java.util.Locale.JAPANESE.getLanguage() == "ja")
  }

  @Test("Locale.KOREAN has language code 'ko'")
  func testKorean() {
    #expect(java.util.Locale.KOREAN.getLanguage() == "ko")
  }

  @Test("Locale.CHINESE has language code 'zh'")
  func testChinese() {
    #expect(java.util.Locale.CHINESE.getLanguage() == "zh")
  }

  // MARK: - Country/region constants

  @Test("Locale.US has language 'en' and country 'US'")
  func testUS() {
    #expect(java.util.Locale.US.getLanguage() == "en")
    #expect(java.util.Locale.US.getCountry() == "US")
  }

  @Test("Locale.UK has language 'en' and country 'GB'")
  func testUK() {
    #expect(java.util.Locale.UK.getLanguage() == "en")
    #expect(java.util.Locale.UK.getCountry() == "GB")
  }

  @Test("Locale.GERMANY has language 'de' and country 'DE'")
  func testGermany() {
    #expect(java.util.Locale.GERMANY.getLanguage() == "de")
    #expect(java.util.Locale.GERMANY.getCountry() == "DE")
  }

  @Test("Locale.FRANCE has language 'fr' and country 'FR'")
  func testFrance() {
    #expect(java.util.Locale.FRANCE.getLanguage() == "fr")
    #expect(java.util.Locale.FRANCE.getCountry() == "FR")
  }

  @Test("Locale.JAPAN has language 'ja' and country 'JP'")
  func testJapan() {
    #expect(java.util.Locale.JAPAN.getLanguage() == "ja")
    #expect(java.util.Locale.JAPAN.getCountry() == "JP")
  }

  // MARK: - getDefault

  @Test("Locale.getDefault() returns a non-nil locale")
  func testGetDefault() {
    let locale = java.util.Locale.getDefault()
    // just verify it doesn't crash and returns something
    let lang = locale.getLanguage()
    #expect(lang.count >= 0)  // always true — just verifies no crash
  }

  // MARK: - Custom locale

  @Test("Custom Locale(String) sets language correctly")
  func testCustomLocale() {
    let l = java.util.Locale("es")
    #expect(l.getLanguage() == "es")
  }

  // MARK: - Two-arg constructor (Java 1.1)

  @Test("Locale(language, country) sets both codes correctly")
  func testTwoArgConstructor() {
    let l = java.util.Locale("de", "DE")
    #expect(l.getLanguage() == "de")
    #expect(l.getCountry() == "DE")
  }

  @Test("Locale(language, country) with empty country falls back to language only")
  func testTwoArgConstructorEmptyCountry() {
    let l = java.util.Locale("fr", "")
    #expect(l.getLanguage() == "fr")
    #expect(l.getCountry() == "")
  }

  @Test("Locale(language, country) works for various combinations")
  func testTwoArgConstructorVariants() {
    let us = java.util.Locale("en", "US")
    #expect(us.getLanguage() == "en")
    #expect(us.getCountry() == "US")

    let jp = java.util.Locale("ja", "JP")
    #expect(jp.getLanguage() == "ja")
    #expect(jp.getCountry() == "JP")
  }
}
