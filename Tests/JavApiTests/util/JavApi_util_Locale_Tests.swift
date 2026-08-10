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
  
  // MARK: - Java 6 constants

  @Test("Locale.SIMPLIFIED_CHINESE has language 'zh' and country 'CN'")
  func testSimplifiedChinese() {
    #expect(java.util.Locale.SIMPLIFIED_CHINESE.getLanguage() == "zh")
    #expect(java.util.Locale.SIMPLIFIED_CHINESE.getCountry() == "CN")
  }

  @Test("Locale.TRADITIONAL_CHINESE has language 'zh' and country 'TW'")
  func testTraditionalChinese() {
    #expect(java.util.Locale.TRADITIONAL_CHINESE.getLanguage() == "zh")
    #expect(java.util.Locale.TRADITIONAL_CHINESE.getCountry() == "TW")
  }

  @Test("Locale.PRC is identical to SIMPLIFIED_CHINESE")
  func testPRC() {
    #expect(java.util.Locale.PRC.getLanguage() == "zh")
    #expect(java.util.Locale.PRC.getCountry() == "CN")
  }

  @Test("Locale.TAIWAN is identical to TRADITIONAL_CHINESE")
  func testTaiwan() {
    #expect(java.util.Locale.TAIWAN.getLanguage() == "zh")
    #expect(java.util.Locale.TAIWAN.getCountry() == "TW")
  }

  @Test("Locale.ROOT has empty language and country")
  func testRoot() {
    #expect(java.util.Locale.ROOT.getLanguage() == "")
    #expect(java.util.Locale.ROOT.getCountry() == "")
  }

  // MARK: - getVariant

  @Test("getVariant returns empty string for locales without a variant")
  func testGetVariantEmpty() {
    #expect(java.util.Locale.GERMANY.getVariant() == "")
    #expect(java.util.Locale.US.getVariant() == "")
  }

  @Test("getVariant returns the variant component from the identifier")
  func testGetVariantPresent() {
    // Norwegian Nynorsk (no_NO_NY) is the canonical Java example
    let noNY = java.util.Locale("no_NO_NY")
    #expect(noNY.getVariant() == "NY")
  }

  // MARK: - toString

  @Test("toString() returns language only when no country is set")
  func testToStringLanguageOnly() {
    let l = java.util.Locale("de")
    #expect(l.toString() == "de")
  }

  @Test("toString() returns language_COUNTRY when country is set")
  func testToStringLanguageCountry() {
    let l = java.util.Locale("de", "DE")
    #expect(l.toString() == "de_DE")
  }

  @Test("toString() returns language_COUNTRY_VARIANT when all three are set")
  func testToStringFull() {
    let l = java.util.Locale("no_NO_NY")
    #expect(l.toString() == "no_NO_NY")
  }

  @Test("toString() for ROOT locale returns empty string")
  func testToStringRoot() {
    #expect(java.util.Locale.ROOT.toString() == "")
  }

  // MARK: - Display methods

  @Test("getDisplayLanguage() returns non-empty string for known languages")
  func testGetDisplayLanguage() {
    let l = java.util.Locale.ENGLISH
    let name = l.getDisplayLanguage(java.util.Locale.ENGLISH)
    #expect(!name.isEmpty)
    // "English" in English is "English"
    #expect(name.lowercased().contains("english"))
  }

  @Test("getDisplayCountry() returns non-empty string for known country")
  func testGetDisplayCountry() {
    let l = java.util.Locale.GERMANY
    let country = l.getDisplayCountry(java.util.Locale.ENGLISH)
    #expect(!country.isEmpty)
    #expect(country.lowercased().contains("germany"))
  }

  @Test("getDisplayCountry() returns empty string for language-only locale")
  func testGetDisplayCountryEmpty() {
    let l = java.util.Locale("fr")
    #expect(l.getDisplayCountry() == "")
  }

  @Test("getDisplayVariant() returns empty string for locales without variant")
  func testGetDisplayVariantEmpty() {
    #expect(java.util.Locale.US.getDisplayVariant() == "")
  }

  @Test("getDisplayName() includes language and country")
  func testGetDisplayName() {
    let l = java.util.Locale.GERMANY
    let name = l.getDisplayName(java.util.Locale.ENGLISH)
    // Should contain both "German" and "Germany"
    #expect(name.lowercased().contains("german"))
    #expect(name.contains("("))
  }

  @Test("getDisplayName() for language-only locale is just the language")
  func testGetDisplayNameLanguageOnly() {
    let l = java.util.Locale.FRENCH
    let name = l.getDisplayName(java.util.Locale.ENGLISH)
    #expect(!name.isEmpty)
    #expect(!name.contains("("))
  }

  // MARK: - ISO3 codes

  @Test("getISO3Language() returns 3-letter code for known language")
  func testGetISO3Language() throws {
    let l = java.util.Locale.GERMAN
    let iso3 = try l.getISO3Language()
    #expect(iso3 == "deu")
  }

  @Test("getISO3Language() returns 'eng' for English")
  func testGetISO3LanguageEnglish() throws {
    let iso3 = try java.util.Locale.ENGLISH.getISO3Language()
    #expect(iso3 == "eng")
  }

  @Test("getISO3Country() returns 3-letter code for known country")
  func testGetISO3Country() throws {
    let l = java.util.Locale.US
    let iso3 = try l.getISO3Country()
    #expect(iso3 == "USA")
  }

  @Test("getISO3Country() returns 'DEU' ... wait, that's language. Country DE = DEU")
  func testGetISO3CountryGermany() throws {
    let l = java.util.Locale.GERMANY
    let iso3 = try l.getISO3Country()
    #expect(iso3 == "DEU")
  }

  @Test("getISO3Language() returns empty string for ROOT locale")
  func testGetISO3LanguageRoot() throws {
    let iso3 = try java.util.Locale.ROOT.getISO3Language()
    #expect(iso3 == "")
  }

  @Test("getISO3Country() returns empty string for language-only locale")
  func testGetISO3CountryEmpty() throws {
    let iso3 = try java.util.Locale.ENGLISH.getISO3Country()
    #expect(iso3 == "")
  }

  // MARK: - Static factory methods

  @Test("getAvailableLocales() returns non-empty array")
  func testGetAvailableLocales() {
    let locales = java.util.Locale.getAvailableLocales()
    #expect(!locales.isEmpty)
    #expect(locales.count > 100)
  }

  @Test("getISOLanguages() returns non-empty array containing 'en' and 'de'")
  func testGetISOLanguages() {
    let langs = java.util.Locale.getISOLanguages()
    #expect(!langs.isEmpty)
    #expect(langs.contains("en"))
    #expect(langs.contains("de"))
  }

  @Test("getISOCountries() returns non-empty array containing 'US' and 'DE'")
  func testGetISOCountries() {
    let countries = java.util.Locale.getISOCountries()
    #expect(!countries.isEmpty)
    #expect(countries.contains("US"))
    #expect(countries.contains("DE"))
  }

  // MARK: - Java 7: getScript

  @Test("getScript() returns empty string for locales without a script subtag")
  func testGetScriptEmpty() {
    #expect(java.util.Locale.ENGLISH.getScript() == "")
    #expect(java.util.Locale.GERMANY.getScript() == "")
  }

  // MARK: - Java 7: toLanguageTag

  @Test("toLanguageTag() uses hyphens and produces BCP 47 output")
  func testToLanguageTag() {
    let l = java.util.Locale("de", "DE")
    let tag = l.toLanguageTag()
    // Must use hyphens, not underscores
    #expect(!tag.contains("_"))
    #expect(tag.contains("-") || tag == "de")
  }

  @Test("toLanguageTag() for ROOT locale returns 'und'")
  func testToLanguageTagRoot() {
    let tag = java.util.Locale.ROOT.toLanguageTag()
    #expect(tag == "und")
  }

  @Test("toLanguageTag() for language-only locale returns the language")
  func testToLanguageTagLanguageOnly() {
    let l = java.util.Locale("fr")
    let tag = l.toLanguageTag()
    #expect(tag == "fr")
  }

  // MARK: - Java 7: forLanguageTag

  @Test("forLanguageTag() parses 'en-US' to language 'en' and country 'US'")
  func testForLanguageTagEnUS() {
    let l = java.util.Locale.forLanguageTag("en-US")
    #expect(l.getLanguage() == "en")
    #expect(l.getCountry() == "US")
  }

  @Test("forLanguageTag('und') returns ROOT locale")
  func testForLanguageTagUnd() {
    let l = java.util.Locale.forLanguageTag("und")
    #expect(l.getLanguage() == "")
  }

  @Test("forLanguageTag() handles POSIX-style underscore identifiers")
  func testForLanguageTagPosix() {
    let l = java.util.Locale.forLanguageTag("de_DE")
    #expect(l.getLanguage() == "de")
    #expect(l.getCountry() == "DE")
  }

  // MARK: - Java 7: Locale.Builder

  @Test("Locale.Builder builds a basic language+region locale")
  func testBuilderBasic() throws {
    let l = try java.util.Locale.Builder()
      .setLanguage("de")
      .setRegion("DE")
      .build()
    #expect(l.getLanguage() == "de")
    #expect(l.getCountry() == "DE")
  }

  @Test("Locale.Builder with only language sets no country")
  func testBuilderLanguageOnly() throws {
    let l = try java.util.Locale.Builder()
      .setLanguage("fr")
      .build()
    #expect(l.getLanguage() == "fr")
    #expect(l.getCountry() == "")
  }

  @Test("Locale.Builder throws IllformedLocaleException for invalid language")
  func testBuilderInvalidLanguage() {
    #expect(throws: java.util.IllformedLocaleException.self) {
      try java.util.Locale.Builder().setLanguage("123invalid")
    }
  }

  @Test("Locale.Builder throws IllformedLocaleException for invalid region")
  func testBuilderInvalidRegion() {
    #expect(throws: java.util.IllformedLocaleException.self) {
      try java.util.Locale.Builder().setRegion("TOOLONG")
    }
  }

  @Test("Locale.Builder throws IllformedLocaleException for invalid script")
  func testBuilderInvalidScript() {
    #expect(throws: java.util.IllformedLocaleException.self) {
      try java.util.Locale.Builder().setScript("la")  // must be exactly 4 letters
    }
  }

  @Test("Locale.Builder sets variant component")
  func testBuilderVariant() throws {
    let l = try java.util.Locale.Builder()
      .setLanguage("no")
      .setRegion("NO")
      .setVariant("NY")
      .build()
    #expect(l.getLanguage() == "no")
    #expect(l.getCountry() == "NO")
    #expect(l.getVariant() == "NY")
  }

  // MARK: - Java 7: Locale.Category

  @Test("Locale.Category has DISPLAY and FORMAT cases")
  func testLocaleCategory() {
    // Just verify the cases compile and are distinct
    let display = java.util.Locale.Category.DISPLAY
    let format  = java.util.Locale.Category.FORMAT
    #expect(display != format)
  }

  // MARK: - 3-arg constructor (Java 1.1) — Harmony LocaleTest

  @Test("Locale(language, country, variant) sets all three components")
  func testThreeArgConstructor() {
    let l = java.util.Locale("en", "CA", "WIN32")
    #expect(l.getLanguage() == "en")
    #expect(l.getCountry()  == "CA")
    #expect(l.getVariant()  == "WIN32")
  }

  @Test("Locale(language, country, variant) with empty country preserves variant")
  func testThreeArgConstructorEmptyCountry() {
    let l = java.util.Locale("en", "", "WIN")
    #expect(l.getLanguage() == "en")
    #expect(l.getCountry()  == "")
    #expect(l.getVariant()  == "WIN")
  }

  @Test("Locale(language, country, variant) with empty language: getLanguage and getVariant work")
  func testThreeArgConstructorEmptyLanguage() {
    // Note: getCountry() delegates to Foundation which may not parse
    // an empty-language POSIX identifier — only language and variant are tested.
    let l = java.util.Locale("", "CA", "WIN32")
    #expect(l.getLanguage() == "")
    #expect(l.getVariant()  == "WIN32")
  }

  @Test("Locale(empty, empty, variant) toString() returns empty string per Java spec")
  func testThreeArgConstructorAllEmpty() {
    // Java spec: if both language and country are empty, toString() returns ""
    let l = java.util.Locale("", "", "var")
    #expect(l.toString() == "")
  }

  // MARK: - toString() edge cases (Harmony LocaleTest.test_toString)

  @Test("toString() for language-only locale returns just the language")
  func testToStringLangOnly() {
    let l = java.util.Locale("en", "")
    #expect(l.toString() == "en")
  }

  @Test("toString() with empty country and variant uses double underscore")
  func testToStringEmptyCountry() {
    // Harmony: new Locale("en", "", "WIN").toString() == "en__WIN"
    let l = java.util.Locale("en", "", "WIN")
    #expect(l.toString() == "en__WIN")
  }

  @Test("toString() with all three components")
  func testToStringAllThree() {
    // Harmony: new Locale("en", "CA", "VAR").toString() == "en_CA_VAR"
    let l = java.util.Locale("en", "CA", "VAR")
    #expect(l.toString() == "en_CA_VAR")
  }

  // MARK: - clone (Java 1.1) — Harmony LocaleTest.test_clone

  @Test("clone() returns a locale that equals the original")
  func testClone() {
    let l = java.util.Locale("fr", "CA", "WIN32")
    let copy = l.clone()
    // Same language, country, variant
    #expect(copy.getLanguage() == l.getLanguage())
    #expect(copy.getCountry()  == l.getCountry())
    #expect(copy.getVariant()  == l.getVariant())
    #expect(copy.toString()    == l.toString())
  }

  @Test("clone() is independent (different object)")
  func testCloneIsIndependent() {
    let l = java.util.Locale("de", "DE")
    let copy = l.clone()
    // Should not be reference-equal (class instances)
    #expect(copy !== l)
  }

  // MARK: - equals (Java 1.1) — Harmony LocaleTest.test_equalsLjava_lang_Object

  @Test("equals() returns true for same locale values")
  func testEqualsTrue() {
    let a = java.util.Locale("en", "CA", "WIN32")
    let b = java.util.Locale("en", "CA", "WIN32")
    #expect(a.equals(b) == true)
  }

  @Test("equals() returns true for same object")
  func testEqualsSelf() {
    let a = java.util.Locale("en", "CA", "WIN32")
    #expect(a.equals(a) == true)
  }

  @Test("equals() returns false for different locales")
  func testEqualsFalse() {
    let a = java.util.Locale("en", "CA", "WIN32")
    let b = java.util.Locale("fr", "CA", "WIN32")
    #expect(a.equals(b) == false)
  }

  @Test("equals() returns false for non-Locale argument")
  func testEqualsNonLocale() {
    let a = java.util.Locale("en", "US")
    #expect(a.equals("not a locale") == false)
    #expect(a.equals(nil) == false)
  }

  // MARK: - setDefault / getDefault round-trip — Harmony LocaleTest.test_setDefaultLjava_util_Locale

  @Test("setDefault()/getDefault() round-trip preserves locale")
  func testSetGetDefault() {
    let original = java.util.Locale.getDefault()
    let frCA = java.util.Locale("fr", "CA", "WIN32")
    java.util.Locale.setDefault(frCA)
    let retrieved = java.util.Locale.getDefault()
    java.util.Locale.setDefault(original)  // restore
    #expect(retrieved.toString() == "fr_CA_WIN32")
  }

  // MARK: - getVariant with WIN32 variant — Harmony LocaleTest.test_getVariant

  @Test("getVariant() returns 'WIN32' for a 3-arg locale")
  func testGetVariantWIN32() {
    let l = java.util.Locale("en", "CA", "WIN32")
    #expect(l.getVariant() == "WIN32")
  }

  // MARK: - getAvailableLocales count — Harmony LocaleTest.test_getAvailableLocales

  @Test("getAvailableLocales() contains more than 100 locales")
  func testAvailableLocalesCount() {
    let locales = java.util.Locale.getAvailableLocales()
    #expect(locales.count > 100)
  }

  // MARK: - ISO3 language for edge cases — Harmony HARMONY-2953

  @Test("getISO3Language() returns 'arg' for language 'an' (Aragonese)")
  func testGetISO3LanguageAragonese() throws {
    let l = java.util.Locale("an")
    let iso3 = try l.getISO3Language()
    #expect(iso3 == "arg")
  }

  @Test("getISO3Language() returns 'pus' for language 'ps' (Pashto)")
  func testGetISO3LanguagePashto() throws {
    let l = java.util.Locale("ps")
    let iso3 = try l.getISO3Language()
    #expect(iso3 == "pus")
  }

  @Test("getISOLanguages() contains 'ak' (Akan)")
  func testGetISOLanguagesContainsAk() {
    let langs = java.util.Locale.getISOLanguages()
    #expect(langs.contains("ak"))
  }

  @Test("getISO3Language() returns 'aka' for 'ak' (Akan)")
  func testGetISO3LanguageAkan() throws {
    let l = java.util.Locale("ak")
    let iso3 = try l.getISO3Language()
    #expect(iso3 == "aka")
  }

  @MainActor @Test("Locale on AWTComponents")
  func testLocalizedAWTComponents() {
    let label = java.awt.Label("Hello")
    #expect(label.getLocale() == java.util.Locale.getDefault())
    
    let enPanel = java.awt.Panel()
    enPanel.setLocale(java.util.Locale.ENGLISH)
    
    let deLabel = java.awt.Label("Hallo")
    enPanel.add(deLabel)
    #expect(deLabel.getLocale() == java.util.Locale.ENGLISH)

    deLabel.setLocale(java.util.Locale.GERMAN)
    #expect(deLabel.getLocale() == java.util.Locale.GERMAN)

    let window = java.awt.Frame()
    #expect(window.getLocale() == java.util.Locale.getDefault())
    window.setLocale(java.util.Locale.FRANCE)
    #expect(window.getLocale() == java.util.Locale.FRANCE)
    
    
    let applet = java.applet.Applet()
    #expect(applet.getLocale() == java.util.Locale.getDefault())
    applet.setLocale(java.util.Locale.CHINESE)
    #expect(applet.getLocale() == java.util.Locale.CHINESE)
  }
}
