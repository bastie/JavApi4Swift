/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// Tests für java.util.Date
//
// Wichtige Java/Swift-Unterschiede:
//   - Monat: Java 0-basiert (Jan=0), Foundation 1-basiert (Jan=1)
//   - Jahr:  Java = Realjahr - 1900 (z.B. 2024 → 124)
//   - Wochentag: Java 0=Sonntag…6=Samstag, Foundation 1=Sonntag…7=Samstag
//   - getTimezoneOffset(): Java gibt Minuten (UTC - lokal), also negativ für Ost-Zeitzonen
//   - getTime()/setTime(): UTC-Millisekunden seit 1970-01-01 00:00:00 UTC
//   - deprecated get/set: nutzen lokale Zeitzone (wie Java selbst)
//
// Teststrategie:
//   - getTime/setTime/after/before/equals/UTC/parse: absolut (UTC-Millisekunden)
//   - deprecated get/set: round-trip (setX dann getX), zeitzonenrobust

struct JavApi_util_Date_Tests {

  // MARK: - Konstruktor und getTime

  @Test("Date() erzeugt ein Datum nahe der aktuellen Zeit")
  func testDefaultConstructorIsNearNow() {
    let before = Int64(Foundation.Date.now.timeIntervalSince1970 * 1000) - 1000
    let d = java.util.Date()
    let after = Int64(Foundation.Date.now.timeIntervalSince1970 * 1000) + 1000
    #expect(d.getTime() >= before)
    #expect(d.getTime() <= after)
  }

  @Test("Date(0) entspricht der Unix-Epoche")
  func testEpochConstructor() {
    let d = java.util.Date(Int64(0))
    #expect(d.getTime() == 0)
  }

  @Test("Date(ms) setzt getTime korrekt")
  func testMillisecondConstructor() {
    // 2024-01-01 00:00:00 UTC = 1704067200000 ms
    let ms: Int64 = 1704067200000
    let d = java.util.Date(ms)
    #expect(d.getTime() == ms)
  }

  @Test("Date(negativer Wert) funktioniert für Zeiten vor 1970")
  func testNegativeMilliseconds() {
    // -1000 ms = 1969-12-31 23:59:59 UTC
    let ms: Int64 = -1000
    let d = java.util.Date(ms)
    #expect(d.getTime() == ms)
  }

  // MARK: - setTime

  @Test("setTime aktualisiert getTime korrekt")
  func testSetTime() {
    let d = java.util.Date(Int64(0))
    let newMs: Int64 = 1704067200000
    d.setTime(newMs)
    #expect(d.getTime() == newMs)
  }

  @Test("setTime(0) setzt auf Epoche zurück")
  func testSetTimeToEpoch() {
    let d = java.util.Date(Int64(1704067200000))
    d.setTime(0)
    #expect(d.getTime() == 0)
  }

  // MARK: - after / before / equals

  @Test("after gibt true zurück wenn dieses Datum später ist")
  func testAfterTrue() {
    let earlier = java.util.Date(Int64(1000))
    let later   = java.util.Date(Int64(2000))
    #expect(later.after(earlier))
  }

  @Test("after gibt false zurück wenn dieses Datum früher ist")
  func testAfterFalse() {
    let earlier = java.util.Date(Int64(1000))
    let later   = java.util.Date(Int64(2000))
    #expect(!earlier.after(later))
  }

  @Test("after gibt false zurück für gleiche Zeitpunkte")
  func testAfterSameTime() {
    let d1 = java.util.Date(Int64(1000))
    let d2 = java.util.Date(Int64(1000))
    #expect(!d1.after(d2))
  }

  @Test("before gibt true zurück wenn dieses Datum früher ist")
  func testBeforeTrue() {
    let earlier = java.util.Date(Int64(1000))
    let later   = java.util.Date(Int64(2000))
    #expect(earlier.before(later))
  }

  @Test("before gibt false zurück wenn dieses Datum später ist")
  func testBeforeFalse() {
    let earlier = java.util.Date(Int64(1000))
    let later   = java.util.Date(Int64(2000))
    #expect(!later.before(earlier))
  }

  @Test("before gibt false zurück für gleiche Zeitpunkte")
  func testBeforeSameTime() {
    let d1 = java.util.Date(Int64(1000))
    let d2 = java.util.Date(Int64(1000))
    #expect(!d1.before(d2))
  }

  @Test("equals gibt true zurück für gleiche Zeitpunkte")
  func testEqualsTrue() {
    let ms: Int64 = 946684800000
    let d1 = java.util.Date(ms)
    let d2 = java.util.Date(ms)
    #expect(d1.equals(d2))
  }

  @Test("equals gibt false zurück für verschiedene Zeitpunkte")
  func testEqualsFalse() {
    let d1 = java.util.Date(Int64(1000))
    let d2 = java.util.Date(Int64(2000))
    #expect(!d1.equals(d2))
  }

  @Test("equals gibt false zurück für nil")
  func testEqualsNil() {
    let d = java.util.Date(Int64(1000))
    #expect(!d.equals(nil))
  }

  // MARK: - UTC() statische Methode

  @available(*, deprecated)
  @Test("UTC(70,0,1,0,0,0) ergibt Epoche 0")
  func testUTCEpoch() {
    // Jahr 70 = 1970, Monat 0 = Januar
    let ms = java.util.Date.UTC(70, 0, 1, 0, 0, 0)
    #expect(ms == 0)
  }

  @available(*, deprecated)
  @Test("UTC(124,0,1,0,0,0) ergibt 2024-01-01 00:00:00 UTC")
  func testUTC2024() {
    let ms = java.util.Date.UTC(124, 0, 1, 0, 0, 0)
    #expect(ms == 1704067200000)
  }

  @available(*, deprecated)
  @Test("UTC Monat ist 0-basiert: Monat 1 = Februar")
  func testUTCMonthOffset() {
    // 2000-03-01 00:00:00 UTC
    let ms = java.util.Date.UTC(100, 2, 1, 0, 0, 0)
    // Python: datetime(2000,3,1,tzinfo=utc).timestamp()*1000 = 951868800000
    #expect(ms == 951868800000)
  }

  @available(*, deprecated)
  @Test("UTC Jahr ist (Realjahr - 1900): 100 = Jahr 2000")
  func testUTCYearOffset() {
    // 2000-01-01 00:00:00 UTC
    let ms = java.util.Date.UTC(100, 0, 1, 0, 0, 0)
    // 946684800000
    #expect(ms == 946684800000)
  }

  @available(*, deprecated)
  @Test("UTC Schaltjahr 2000: 29. Februar existiert")
  func testUTCLeapYear2000() {
    let ms = java.util.Date.UTC(100, 1, 29, 0, 0, 0)
    // 2000-02-29 00:00:00 UTC = 951782400000
    #expect(ms == 951782400000)
  }

  // MARK: - deprecated get/set (lokale Zeitzone)
  // Java's deprecated Date-Methoden nutzen die lokale Zeitzone — genau wie Foundation.Calendar.current.
  // Tests als Round-Trips: setX → getX, zeitzonenrobust in allen UTC-Offsets.
  // Getestet werden insbesondere Off-by-One-Fehler bei Monat (Java 0-basiert vs. Foundation 1-basiert)
  // und Jahr (Java = Realjahr - 1900).

  @available(*, deprecated)
  @Test("getYear/setYear: Java-Jahr ist Realjahr minus 1900")
  func testYearRoundTrip() {
    let d = java.util.Date(Int64(0))
    d.setYear(124) // setzt 2024
    #expect(d.getYear() == 124)
  }

  @available(*, deprecated)
  @Test("setYear(0) ergibt getYear() == 0, nicht 1900")
  func testYearZero() {
    let d = java.util.Date(Int64(0))
    d.setYear(0) // Jahr 1900
    #expect(d.getYear() == 0)
  }

  @available(*, deprecated)
  @Test("getMonth/setMonth: Monat ist 0-basiert (Januar=0, Dezember=11)")
  func testMonthRoundTrip() {
    let d = java.util.Date(Int64(0))
    // Januar: Java 0, Foundation 1 — Off-by-One-Grenze
    d.setMonth(0)
    #expect(d.getMonth() == 0)
    // Dezember: Java 11, Foundation 12
    d.setMonth(11)
    #expect(d.getMonth() == 11)
  }

  @available(*, deprecated)
  @Test("setMonth(5) ergibt getMonth() == 5, nicht 6 (kein Foundation-Offset-Leak)")
  func testMonthJune() {
    let d = java.util.Date(Int64(0))
    d.setMonth(5) // Juni in Java
    #expect(d.getMonth() == 5)
  }

  @available(*, deprecated)
  @Test("getDate/setDate Round-Trip")
  func testDateRoundTrip() {
    let d = java.util.Date(Int64(0))
    d.setDate(15)
    #expect(d.getDate() == 15)
  }

  @available(*, deprecated)
  @Test("getHours/setHours Round-Trip")
  func testHoursRoundTrip() {
    let d = java.util.Date(Int64(0))
    d.setHours(14)
    #expect(d.getHours() == 14)
  }

  @available(*, deprecated)
  @Test("getMinutes/setMinutes Round-Trip")
  func testMinutesRoundTrip() {
    let d = java.util.Date(Int64(0))
    d.setMinutes(30)
    #expect(d.getMinutes() == 30)
  }

  @available(*, deprecated)
  @Test("getSeconds/setSeconds Round-Trip")
  func testSecondsRoundTrip() {
    let d = java.util.Date(Int64(0))
    d.setSeconds(45)
    #expect(d.getSeconds() == 45)
  }

  @available(*, deprecated)
  @Test("set/get sind unabhängig: Monat-Set ändert nicht Jahr")
  func testSetMonthDoesNotChangeYear() {
    let d = java.util.Date(Int64(0))
    d.setYear(124)
    d.setMonth(5)
    #expect(d.getYear() == 124)
    #expect(d.getMonth() == 5)
  }

  // MARK: - getDay (Wochentag)

  @available(*, deprecated)
  @Test("getDay: Epoche (1970-01-01) war ein Donnerstag (Java: 4)")
  func testGetDayEpochLocal() {
    // getDay() nutzt lokale Zeitzone — daher prüfen wir den lokalen Wochentag
    let d = java.util.Date(Int64(0))
    // Foundation: weekday 1=So…7=Sa → Java: 0=So…6=Sa (shift -1)
    let expected = Foundation.Calendar.current.component(
      .weekday,
      from: Foundation.Date(timeIntervalSince1970: 0)
    ) - 1
    #expect(d.getDay() == expected)
  }

  @available(*, deprecated)
  @Test("getDay Wertebereich ist 0-6")
  func testGetDayRange() {
    // 7 aufeinanderfolgende Tage abdecken alle Wochentage
    for offset in 0..<7 {
      let ms = Int64(offset) * 86400_000
      let d = java.util.Date(ms)
      #expect(d.getDay() >= 0)
      #expect(d.getDay() <= 6)
    }
  }

  // MARK: - getTimezoneOffset

  @available(*, deprecated)
  @Test("getTimezoneOffset entspricht dem negierten Foundation-Offset in Minuten")
  func testTimezoneOffset() {
    let d = java.util.Date()
    let secondsFromGMT = Foundation.TimeZone.current.secondsFromGMT(
      for: Foundation.Date.now
    )
    let expectedOffset = -(secondsFromGMT / 60)
    #expect(d.getTimezoneOffset() == expectedOffset)
  }

  @available(*, deprecated)
  @Test("getTimezoneOffset ist ein Vielfaches von 1 (Minuten-Granularität)")
  func testTimezoneOffsetIsMinutes() {
    let d = java.util.Date()
    // Alle Zeitzonen sind Vielfache von 15 Minuten, also zumindest ganze Minuten
    let offset = d.getTimezoneOffset()
    // Offset muss im realistischen Bereich liegen: UTC-12 bis UTC+14
    #expect(offset >= -14 * 60)
    #expect(offset <= 12 * 60)
  }

  // MARK: - toGMTString
  // Hinweis: toGMTString() erzeugt "GMT" als Suffix — das ist die Zeitzone GMT
  // (Greenwich Mean Time), nicht der Standard UTC. GMT und UTC haben denselben
  // Offset (+0), aber "GMT" bezeichnet eine Zeitzone. Format: "d MMM yyyy HH:mm:ss GMT"

  @available(*, deprecated)
  @Test("toGMTString endet mit 'GMT' (Zeitzone, nicht UTC-Standard)")
  func testToGMTStringEndsWithGMT() {
    let d = java.util.Date(Int64(0))
    #expect(d.toGMTString().hasSuffix("GMT"))
  }

  @available(*, deprecated)
  @Test("toGMTString gibt GMT-Zeit aus unabhängig von lokaler Zeitzone")
  func testToGMTStringIsGMTBased() {
    // 2024-01-01 00:00:00 GMT = 1704067200000 ms
    // In jeder lokalen Zeitzone muss das Ergebnis GMT-Zeit zeigen
    let d = java.util.Date(Int64(1704067200000))
    let s = d.toGMTString()
    #expect(s.contains("2024"))
    #expect(s.contains("Jan"))
    #expect(s.contains("00:00:00"))
    #expect(s.hasSuffix("GMT"))
  }

  @available(*, deprecated)
  @Test("toGMTString Epoche: 1 Jan 1970 00:00:00 GMT")
  func testToGMTStringEpoch() {
    let d = java.util.Date(Int64(0))
    let s = d.toGMTString()
    #expect(s.contains("Jan"))
    #expect(s.contains("1970"))
    #expect(s.contains("00:00:00"))
    #expect(s.hasSuffix("GMT"))
  }

  // MARK: - parse
  // Hinweis: parse() gibt UTC-Millisekunden zurück.
  // DateFormatter erkennt "GMT" im zzz-Token als UTC+0 — korrekt,
  // da GMT denselben Offset wie UTC hat (0 Sekunden).

  @available(*, deprecated)
  @Test("parse gibt -1 für ungültige Strings zurück")
  func testParseInvalid() {
    let result = java.util.Date.parse("kein datum")
    #expect(result == -1)
  }

  @available(*, deprecated)
  @Test("parse erkennt yyyy-MM-dd Format")
  func testParseISO() {
    let result = java.util.Date.parse("2024-01-01")
    #expect(result != -1)
    // Muss im Bereich von 2024-01-01 liegen (irgendeine Zeitzone)
    // 2023-12-31 00:00:00 UTC = 1703980800000
    // 2024-01-02 23:59:59 UTC = 1704239999000
    #expect(result >= 1703980800000)
    #expect(result <= 1704239999000)
  }

  @available(*, deprecated)
  @Test("parse erkennt GMT-String aus toGMTString() exakt")
  func testParseGMTString() {
    // GMT = UTC+0: parse() muss exakt den ursprünglichen ms-Wert zurückgeben
    let originalMs: Int64 = 1704067200000 // 2024-01-01 00:00:00 GMT
    let d = java.util.Date(originalMs)
    let gmtStr = d.toGMTString()         // "1 Jan 2024 00:00:00 GMT"
    let parsedMs = java.util.Date.parse(gmtStr)
    #expect(parsedMs != -1)
    // GMT hat Offset 0 = UTC: Ergebnis muss exakt stimmen (sekundengenau)
    #expect(parsedMs == originalMs)
  }

  @available(*, deprecated)
  @Test("parse(toGMTString()) Round-Trip: sekundengenau")
  func testParseGMTStringRoundTrip() {
    let originalMs: Int64 = 1718446830000 // 2024-06-15 10:20:30 GMT
    let d = java.util.Date(originalMs)
    let gmtStr = d.toGMTString()
    let parsedMs = java.util.Date.parse(gmtStr)
    #expect(parsedMs != -1)
    // toGMTString hat Sekunden-Genauigkeit → exakter Match ohne Toleranz
    #expect(parsedMs == originalMs)
  }

  // MARK: - toString

  @Test("toString gibt einen nicht-leeren String zurück")
  func testToStringNotEmpty() {
    let d = java.util.Date()
    #expect(!d.toString().isEmpty)
  }

  // MARK: - Präzision

  @Test("getTime-Präzision: Millisekunden bleiben erhalten")
  func testMillisecondPrecision() {
    // 1500 ms nach Epoche
    let ms: Int64 = 1500
    let d = java.util.Date(ms)
    #expect(d.getTime() == 1500)
  }

  @Test("getTime-Präzision: Vielfaches von 1000 bleibt exakt")
  func testSecondPrecision() {
    let ms: Int64 = 1704067200000
    let d = java.util.Date(ms)
    #expect(d.getTime() == ms)
  }
}
