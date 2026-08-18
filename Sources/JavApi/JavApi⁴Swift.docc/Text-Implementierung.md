# Text-Implementierung – Bestandsaufnahme der Java-String-Verarbeitung in JavApi4Swift

*Stand: 2026-08-18*

Dieses Dokument analysiert, welche Teile der Java-Zeichenketten-Verarbeitung
(`java.lang.String`/`StringBuilder`/`StringBuffer`/`CharSequence`/`Character`,
`java.util.regex`, `java.util.StringTokenizer`/`StringJoiner`/`Formatter`/`Scanner`,
`java.text.*`, `java.nio.charset.*`) – von Java 1.0 bis zu den aktuellen Java-Versionen –
im Projekt bereits umgesetzt sind und wo noch Lücken bestehen. Es dient als
Arbeitsgrundlage für die nächste Implementierungsphase (analog zu den bereits
abgeschlossenen Phasen zu `java.util` Collections/HashMap/Arrays und den
Java 8–16 Stream-APIs, siehe Projekt-Memory).

Die Übersetzungskonventionen aus
`Sources/JavApi/JavApi⁴Swift.docc/Java2Swift.md` gelten unverändert (z. B.
abstract class → protocol + default-Implementierung, Exceptions als eigene
Datei pro Klasse mit den vier Standard-Initialisierern, `@unchecked Sendable`
für die `Throwable`-Hierarchie, `final`/`let`, `char` → `Character` bzw.
UTF-16-Codeunit-Semantik).

## Bereits implementiert

### java.lang.String
- `Sources/JavApi/lang/String+Java.swift`: `equals`, `indexOf` (String/Character),
  `lastIndexOf`, `isBlank`, `isEmpty`, `strip`, `trim`, `toCharArray`, `charAt`,
  `length`/`lenght` (deprecated), `replace`/`replaceAll`/`replaceFirst`, `split(String)`,
  `startsWith`/`endsWith`, Byte-Array-Konstruktoren + `getBytes(encoding:)`,
  `toUpperCase`/`toLowerCase`, statisches `valueOf` (Char/Int/Int64/Float/Double/
  Bool/Any/CharArray), statisches `format(_:_:)` (Java2SwiftFormatter-basiert),
  `hashCode()` (Java-kompatibler UTF-16-Hash), `toString()`, `appendJ` (Fluent-Append).
- `Sources/JavApi/lang/String+Swiftify.swift`: `hash(into:)` (Java-Hash gebrückt),
  `getBytes()` (UTF-8), `getChars(start:end:array:dstStart:)`.
- `Sources/JavApi/lang/StringProtocol+Java.swift`: `subSequence(start:end:)`,
  `substring(start:end:)`, `substring(start:)`.
- `Sources/JavApi/lang/String+CharSequence.swift`: `String` konformiert zu `CharSequence`.

### java.lang.StringBuilder / StringBuffer
- `Sources/JavApi/lang/StringBuilder.swift`: `append` (String/Range/Character/
  `[Character]`), `charAt`, `deleteCharAt` (fehlerhaft, s. u.), `length`,
  `setLength`, `toString`, `substring`.
- `Sources/JavApi/lang/StringBuffer.swift`: vollständiger als StringBuilder –
  zusätzlich `insert`, `delete(start:end:)`, `replace(start:end:_:)`, `reverse()`,
  alles über `NSLock` synchronisiert (Java `synchronized`-Semantik), inkl.
  Kapazitäts-Konstruktor.
- `Sources/JavApi/lang/StringBuilder+CharSequence.swift`,
  `StringBuffer+CharSequence.swift`: `CharSequence`-Konformität.
- `Sources/JavApi/lang/StringBuilder+Hashable.swift`,
  `StringBuilder+Equalable.swift`: Wertsemantik-Bridging.

### java.lang.CharSequence
- `Sources/JavApi/lang/CharSequence.swift`: Protokoll mit `subSequence`,
  `toString()`, `description`-Bridge.
- `Sources/JavApi/lang/CharSequence+StringProtocol.swift`,
  `SubString+CharSequence.swift`: Adapter für `String`/`Substring`.

### java.lang.Character
- `Sources/JavApi/lang/Character+Java.swift`: `charValue`, `getNumericValue`,
  `isDigit`/`isLetter`/`isWhitespace`/`isLetterOrDigit`/`isUpperCase`/
  `isLowerCase`/`isTitleCase`/`isSpace`/`isDefined`, `toUpperCase`/`toLowerCase`/
  `toTitleCase`, `digit`/`forDigit`, High/Low-Surrogate-Handling, `toChars`,
  `charCount`, `codePointAt` (Array und String), `toCodePoint`.
- `Character+Operator.swift`, `Character+Swiftify.swift`,
  `Character+Strideable.swift`: Ergänzende Operatoren/Protokolle.

### java.util.StringTokenizer / StringJoiner
- `Sources/JavApi/util/StringTokenizer.swift` (+ `+Swiftify.swift`): vollständige
  Token-Iteration inkl. `returnDelims`, `Enumeration`-kompatibel.
- `Sources/JavApi/util/StringJoiner.swift` (+ `+Swiftify.swift`): Delimiter/
  Prefix/Suffix, `setEmptyValue`, `add`, `merge`, `length`, `toString` (Java 8).

### java.util.Formatter / String.format
- `Sources/JavApi/util/java.util.Formatter.swift`: `format` (varargs + Array),
  `out()`, `toString()`, `clear()`.
- `Sources/JavApi/SwiftExtensions/Java2SwiftFormatter.swift`: übersetzt
  Java-Formatspezifizierer (`%s`, `%n`, `%b`, `%,d`, `%tY`, `%1$s`, …) nach
  Swift `String(format:)`.

### java.util.regex (seit Java 1.4)
- `Sources/JavApi/util/regex/Pattern.swift`: `compile` (mit/ohne Flags,
  wirft `PatternSyntaxException`), `matcher`, `pattern()`, `flags()`,
  `groupCount()`, statisches `matches`, `asPredicate`/`asMatchPredicate`,
  `split(input:)`/`split(input:limit:)`.
- `Sources/JavApi/util/regex/Matcher.swift`: `matches`, `find`/`find(start:)`,
  `lookingAt`, `start`/`end` (mit/ohne Gruppe), `group()`/`group(n)`/`group(name)`,
  `groupCount`, `reset`/`reset(input:)`, `usePattern`, `replaceAll`/`replaceFirst`,
  `appendReplacement`/`appendTail` (StringBuffer-basiert), `region`, `regionStart`/
  `regionEnd`, `toMatchResult()`.
- `Sources/JavApi/util/regex/MatchResult.swift`, `PatternSyntaxException.swift`.

### java.util.Scanner (String-Teile)
- `Sources/JavApi/util/Scanner.swift`: `useDelimiter`, `hasNext`/`next`,
  `hasNextLine`/`nextLine`, `hasNextInt`/`nextInt` (mit Radix), `hasNextLong`/
  `nextLong`, `hasNextDouble`/`nextDouble`, `hasNextBoolean`/`nextBoolean`,
  `tokens()` (Stream), `findAll(...)`.

### java.text.* (sehr weitgehend vorhanden)
- `Format.swift`: Basisklasse (`format`, `parseObject`).
- `MessageFormat.swift`: Pattern-Parsing, `applyPattern`/`toPattern`,
  Format-Verwaltung pro Argument-Index, `format(...)`, `parse(...)`.
- `ChoiceFormat.swift`: Limits/Formats, `applyPattern`/`toPattern`, `parseChoice`.
- `NumberFormat.swift`, `DecimalFormat.swift`, `DecimalFormatSymbols.swift`:
  Instanzen (Integer/Currency/Percent), Gruppierung, Min/Max-Digits,
  `RoundingMode`, `BigDecimal`-Parsing-Flag, volle Symbol-Menge
  (Dezimal-/Gruppentrennzeichen, Vorzeichen, Prozent, Promille, NaN, ∞,
  Währungssymbol, Exponent-Trenner).
- `DateFormat.swift`, `SimpleDateFormat.swift`: Date/Time/DateTime-Instanzen,
  Locale-Parameter, `TimeZone`, `format`/`parse` (mit `ParsePosition`).
- `Collator.swift`, `RuleBasedCollator.swift`, `CollationElementIterator.swift`,
  `CollationKey.swift`: Instanzerzeugung, Stärke/Zerlegung, Regel-basierte
  Kollation, Iterator.
- `BreakIterator.swift`: Character-/Word-/Sentence-/Line-Instanzen (Grundgerüst).
- `AttributedString.swift`, `AttributedCharacterIterator.swift`,
  `CharacterIterator.swift`, `StringCharacterIterator.swift`: Attribut-Text,
  Iterator-Protokoll und String-basierte Implementierung.
- `ParsePosition.swift`, `FieldPosition.swift`, `ParseException.swift`.

### java.nio.charset.*
- `Charset.swift`: `name()`, `encode(_:)` → `ByteBuffer`, `forName(_:)`
  (UTF-8/UTF-16[BE/LE]/US-ASCII/ISO-8859-1/-2), `defaultCharset()`.
- `StandardCharsets.swift`: ISO_8859_1, US_ASCII, UTF_8, UTF_16[BE/LE].
- `UnsupportedCharsetException.swift`.

### Tests
`Tests/JavApiTests/lang/JavApi_lang_String_Tests.swift`,
`JavApi_lang_StringBuilder_Tests.swift`,
`JavApi_lang_Java2SwiftFormatter_Tests.swift`,
`Tests/JavApiTests/util/JavApi_util_StringJoiner_Tests.swift`,
`JavApi_util_StringTokenizer_Tests.swift`,
`Tests/JavApiTests/util/regex/JavApi_util_regex_Tests.swift`,
`Tests/JavApiTests/text/JavApi_text_Tests.swift`,
`JavApi_text_DecimalFormat_Java15_Tests.swift`,
`Tests/JavApiTests/io/JavApi_io_StringReader_StringWriter_Tests.swift` decken
die o. g. Kernfunktionalität ab. Für `StringBuffer`, `Collator`,
`BreakIterator`, `AttributedString`, `Charset`/`StandardCharsets` und
`Character` wurden **keine** dedizierten Testdateien gefunden.

## Offene Punkte

### java.lang.String – Kern-API-Lücken (Kern)
- [ ] `compareTo(String)` / `compareToIgnoreCase(String)` — `Comparable<String>`, seit Java 1.0/1.2. Wichtig für Sortierung; aktuell nur für numerische Wrapper implementiert (`Int+Java.swift` etc.), nicht für `String`.
- [ ] `concat(String)` — seit Java 1.0, triviales `+`-Äquivalent, fehlt als explizite Methode.
- [ ] `contentEquals(CharSequence)` / `contentEquals(StringBuffer)` — seit Java 1.5/5.
- [ ] `matches(String regex)` — seit Java 1.4, delegiert auf `Pattern`/`Matcher`, aber auf `String` fehlt der Convenience-Wrapper.
- [ ] `regionMatches(...)` (mit/ohne `ignoreCase`) — seit Java 1.0.
- [ ] `intern()` — seit Java 1.0 (in Swift ggf. No-Op/Dokumentationshinweis, da Swift-Strings kein String-Pool-Konzept haben).
- [ ] Statisches `String.join(CharSequence, CharSequence...)` / `join(CharSequence, Iterable<? extends CharSequence>)` — seit Java 8. `StringJoiner` existiert, aber die `String.join`-Fassade fehlt.
- [ ] `codePointAt(int)` / `codePointBefore(int)` / `codePointCount(...)` / `offsetByCodePoints(...)` direkt auf `String` — seit Java 1.5 (Vorarbeit über `Character.codePointAt` vorhanden, aber keine `String`-Instanzmethoden).
- [ ] `chars()` / `codePoints()` als `IntStream` — seit Java 9 (hängt vom Stream-Fortschritt aus `java.util.stream` ab).
- [ ] `strip()` ist vorhanden, aber `stripLeading()` / `stripTrailing()` fehlen — seit Java 11.
- [ ] `isBlank()` ist vorhanden ✅; `lines()` (Stream<String>) fehlt — seit Java 11.
- [ ] `repeat(int)` — seit Java 11.
- [ ] `String.format(Locale, String, Object...)` (lokalisierte Variante) fehlt — nur locale-lose Überladung vorhanden.
- [ ] `transform(Function<String,R>)` — seit Java 12.
- [ ] `indent(int)` — seit Java 12.
- [ ] `formatted(Object...)` (Instanzmethode, Pendant zu Text-Block-Nutzung) — seit Java 15.
- [ ] `describeConstable()` / `resolveConstantDesc(...)` — seit Java 12, für Swift ohne `invokedynamic`/Konstantenpool nicht sinnvoll übertragbar; nur als „nicht anwendbar" dokumentieren.
- [ ] Text Blocks (`"""`) — Java-15-Sprachfeature ohne Laufzeit-API-Äquivalent; nicht in Swift nachbildbar (kein API-Gegenstück nötig).
- [ ] String Templates (`STR."..."`) — Java-21/-23-Preview-Feature; kein stabiles API, für JavApi4Swift nicht relevant/nicht übertragbar.
- [ ] `copyValueOf(char[])`/`copyValueOf(char[], int, int)` — seit Java 1.0, Alias zu `valueOf`, fehlt.
- [ ] Fehlerbehandlung: `charAt`/`indexOf`-Familie wirft in Java `StringIndexOutOfBoundsException` bei ungültigem Index; die Swift-`charAt`-Implementierung in `String+Java.swift` crasht stattdessen hart (kein `throws`), abweichend von der Java-Semantik.

### java.lang.StringBuilder — Nachziehen zu StringBuffer (Kern)
- [ ] `insert(int, ...)` — in `StringBuffer` vorhanden, in `StringBuilder` fehlt es komplett.
- [ ] `delete(int, int)` — nur `deleteCharAt` vorhanden, kein Bereichs-`delete`.
- [ ] `replace(int, int, String)` — fehlt.
- [ ] `reverse()` — fehlt.
- [ ] `indexOf(String)` / `lastIndexOf(String)` — fehlen.
- [ ] `charAt`/`deleteCharAt` werfen zwar `IndexOutOfBoundsException`, aber `deleteCharAt` in `StringBuilder.swift` hat einen Implementierungsfehler: es ruft `removeFirst(offset)` statt an Position `offset` ein einzelnes Zeichen zu entfernen (`Array.removeFirst(k)` entfernt die ersten `k` Elemente, nicht das Element bei Index `k`) — funktionale Abweichung von Java, sollte bei der nächsten Überarbeitung korrigiert werden.
- [ ] `capacity()` / `ensureCapacity(int)` / `trimToSize()` — seit Java 1.0/1.5, bislang weder in `StringBuilder` noch `StringBuffer` vorhanden (in Swift ohnehin nur als Hinweis/No-Op sinnvoll, da `String` dynamisch wächst).
- [ ] `compareTo(StringBuilder)` — seit Java 1.5 (`Comparable`), fehlt.
- [ ] `getChars(...)` auf `StringBuilder`/`StringBuffer` — fehlt (nur auf `String` über `+Swiftify.swift`).
- [ ] Empfehlung: `StringBuilder` und `StringBuffer` teilen praktisch die gleiche API — Code-Duplikation ließe sich durch ein gemeinsames internes Protokoll/Value-Storage reduzieren (Nice-to-have, kein funktionales Muss).

### java.lang.CharSequence (Nice-to-have)
- [ ] `chars()` / `codePoints()` auf dem `CharSequence`-Protokoll — seit Java 8/9, hängt an Stream-Verfügbarkeit.
- [ ] `compare(CharSequence, CharSequence)` (statische Utility) — seit Java 11.
- [ ] `isEmpty()` auf `CharSequence` — seit Java 15 (Default-Methode).

### java.lang.Character (Nice-to-have, teils Kern)
- [ ] `isAlphabetic(int)`, `isIdeographic(int)` — seit Java 7.
- [ ] `isJavaIdentifierStart`/`isJavaIdentifierPart`, `isUnicodeIdentifierStart`/`Part` — seit Java 1.1.
- [ ] `getType(int)` (Unicode-Kategorie) — seit Java 1.0/1.5.
- [ ] `UnicodeBlock` / `UnicodeScript` — seit Java 1.2/1.7 (**Plattformabhängig**: erfordert Unicode-Charakterdaten; unter MUSL/WASM ggf. eingeschränkt, siehe Hinweise unten).
- [ ] `compare(char, char)` statisch — seit Java 1.7.
- [ ] Vollständiger Satz an `Character.valueOf`/Boxing-Cache-Semantik — in Swift ohne Objekt-Identität weniger relevant, nur als Hinweis dokumentieren.

### java.util.regex (Kern für Vollständigkeit)
- [ ] `Matcher.quoteReplacement(String)` — seit Java 1.5, fehlt.
- [ ] `Pattern.quote(String)` — seit Java 1.5, fehlt.
- [ ] `Pattern.CASE_INSENSITIVE`/`MULTILINE`/… Flag-Konstanten — prüfen, ob alle Java-Flag-Werte (`UNIX_LINES`, `COMMENTS`, `LITERAL`, `UNICODE_CASE`, `CANON_EQ`, `UNICODE_CHARACTER_CLASS`) tatsächlich abgebildet und wirksam sind (aktuell nur `flags()` als Getter sichtbar, keine Konstanten-Liste geprüft — Review nötig).
- [ ] `Matcher.replaceAll(Function<MatchResult,String>)` / `replaceFirst(Function<MatchResult,String>)` — seit Java 9.
- [ ] `Matcher.results()` → `Stream<MatchResult>` — seit Java 9.
- [ ] `Pattern.splitAsStream(CharSequence)` — seit Java 8.
- [ ] `Matcher.hasAnchoringBounds`/`hasTransparentBounds`/`useAnchoringBounds`/`useTransparentBounds` — Randfälle, Nice-to-have.
- [ ] Named-Capturing-Group-Unterstützung in `Pattern` (`(?<name>...)`) end-to-end verifizieren — `Matcher.group(name:)` existiert, aber ob `Pattern.compile` alle Java-Regex-Syntaxerweiterungen (z. B. Unicode-Property-Escapes `\p{IsAlphabetic}`) unterstützt, hängt von der zugrunde liegenden `NSRegularExpression`/ICU-Regex-Engine ab — **plattformabhängig**, muss pro Zielplattform (Linux ohne Foundation-Vollausbau, WASM) verifiziert werden.

### java.util.Formatter (Nice-to-have)
- [ ] `Formattable`-Protokoll (`formatTo`) — seit Java 5, fehlt komplett; nötig, damit eigene Typen `%s`-kompatibel eigene Formatierung liefern.
- [ ] `FormatterClosedException`, `IllegalFormatException`-Hierarchie (`MissingFormatArgumentException`, `UnknownFormatConversionException`, etc.) — Java wirft spezifische Exceptions bei Formatfehlern; aktuell unklar, ob `Java2SwiftFormatter` entsprechende Fehler differenziert oder nur generisch fehlschlägt (Review nötig).
- [ ] `Formatter(Locale)` / lokalisierte Zahl-/Datumsformatierung über `%d`/`%f`/`%t*` — zu prüfen, ob Locale-Parameter durchgereicht wird.

### java.util.Scanner (Nice-to-have)
- [ ] `next(Pattern)` / `hasNext(Pattern)` — Pattern-basiertes Scannen fehlt.
- [ ] `nextBigInteger()` / `nextBigDecimal()` — abhängig vom `BigInteger`/`BigDecimal`-Stand.
- [ ] `skip(Pattern)`, `match()`, `reset()` — fehlen.
- [ ] `nextFloat()`/`hasNextFloat()`, `nextByte()`/`nextShort()` — nur Int/Long/Double/Boolean vorhanden.

### java.text.* — punktuelle Lücken
- [ ] `Normalizer` (java.text seit Java 1.6, kanonisch `java.text.Normalizer`) — **komplett nicht gefunden** im Projekt. Wichtig für NFC/NFD/NFKC/NFKD-Normalisierung. **Plattformabhängig/ICU nötig**: Auf Apple-Plattformen über `Foundation`/ICU verfügbar (`String.precomposedStringWithCanonicalMapping` etc. als Basis nutzbar), unter Linux/MUSL/WASM ohne volle ICU-Bibliothek eingeschränkt oder gar nicht verfügbar — Machbarkeit vorab prüfen (z. B. swift-foundation/ICU4C-Verfügbarkeit unter statischem MUSL).
- [ ] `Bidi` (java.text.Bidi, bidirektionaler Text) — **komplett nicht gefunden**. **Plattformabhängig/ICU nötig**: benötigt Unicode-Bidi-Algorithmus-Implementierung; auf Apple ggf. über CoreText/ICU, unter Linux GLibc/MUSL und insbesondere WASM ohne ICU praktisch nicht sinnvoll umsetzbar ohne Zusatzbibliothek. Empfehlung: als "Nice-to-have, nur auf Plattformen mit ICU" einstufen, ggf. leere/Stub-Implementierung mit `preconditionFailure` auf Plattformen ohne Unterstützung.
- [ ] `Formattable`/`Format.formatToCharacterIterator` — `AttributedCharacterIterator`-Rückgabepfad einiger `Format`-Unterklassen (`NumberFormat.formatToCharacterIterator`, `DateFormat.formatToCharacterIterator`) — nicht gefunden, vermutlich nicht implementiert.
- [ ] `Collator.compare(Object, Object)` / `equals(String, String)` sowie volle `RuleBasedCollator`-Regelsprache — Umfang der Regel-Grammatik gegenüber Java (ICU-basiert) prüfen; **plattformabhängig**, da Java/ICU-Kollationsregeln komplex sind und auf schlanken Zielplattformen (WASM, statisches MUSL) nur eingeschränkt nachbildbar sind ohne eigene ICU-Daten.
- [ ] `BreakIterator` — Grundgerüst vorhanden (Character/Word/Sentence/Line-Instanzen), aber die tatsächliche Iterationslogik (`next()`, `previous()`, `following()`, `preceding()`, `isBoundary()`) muss geprüft werden, ob sie sprachunabhängig korrekt Wort-/Satzgrenzen findet oder nur ASCII-Heuristiken nutzt — **ICU-Datenabhängigkeit** für nicht-lateinische Skripte.
- [ ] `MessageFormat.autoQuoting`, `ChoiceFormat.nextDouble/previousDouble` Sonderfälle — Detailprüfung empfohlen (Kleinteile).
- [ ] `NumberFormat`/`DecimalFormat`: `getCurrency()`/`setCurrency()`, `parse(String, ParsePosition)` (die Überladung mit `ParsePosition` statt `throws`) — prüfen, ob vorhanden (aus Kurzscan nicht sichtbar, ggf. Lücke).
- [ ] `DateFormat.setLenient`/`isLenient`, `getCalendar`/`setCalendar`, `getNumberFormat`/`setNumberFormat` — Ergänzungsmethoden, aus Kurzscan nicht sichtbar, Review nötig.

### java.nio.charset.* — größte funktionale Lücke
- [ ] `CharsetEncoder` / `CharsetDecoder` — **komplett nicht gefunden**. Java verwendet diese für kontrollierte Kodierung mit `CodingErrorAction` (REPORT/IGNORE/REPLACE), `CoderResult`, Malformed-/Unmappable-Behandlung. Aktuell bietet `Charset` nur ein simples `encode(_:) -> ByteBuffer` ohne Fehlerbehandlungsstrategie. (**Kern**, da für robuste I/O-Pfade wichtig.)
- [ ] `CodingErrorAction`, `CoderResult`, `CharacterCodingException`, `MalformedInputException`, `UnmappableCharacterException` — fehlen komplett.
- [ ] `Charset.decode(ByteBuffer) -> CharBuffer` — nur die Encode-Richtung ist vorhanden.
- [ ] `Charset.availableCharsets()`, `isSupported(String)`, `aliases()`, `displayName()`, `canEncode()` — fehlen.
- [ ] `StandardCharsets.UTF_16` Alias-Vollständigkeit ok, aber `Charset.forName` unterstützt nur eine kleine Teilmenge (UTF-8/16[BE/LE]/US-ASCII/ISO-8859-1/-2) — Java unterstützt deutlich mehr eingebaute Charsets (z. B. `windows-1252`, `Shift_JIS`, `EUC-JP` — die `name()`-Methode kennt sie zwar für die Anzeige, aber `forName` kann sie nicht zurück auflösen). Inkonsistenz zwischen `name()` (viele Encodings) und `forName()` (wenige) beheben.
- [ ] `CharsetProvider` (SPI) — für dieses Projekt vermutlich verzichtbar (Nice-to-have, sehr rand-ständig).

### Sonstiges
- [ ] `java.lang.Runtime.Version`/Switch-Pattern-Matching auf Strings (Java 21 Pattern Matching for switch) — reines Sprachfeature, kein API-Gegenstück nötig; nur als Hinweis dokumentieren, dass Swift `switch` auf `String` bereits nativ funktioniert.
- [ ] Fehlende dedizierte Tests: `StringBuffer`, `Character`, `Collator`/`RuleBasedCollator`, `BreakIterator`, `AttributedString`, `Charset`/`StandardCharsets`, `MessageFormat`, `ChoiceFormat`, `DateFormat`/`SimpleDateFormat` haben (Stand dieser Analyse) keine sichtbaren eigenen Testdateien unter `Tests/JavApiTests/` — vor jeder API-Erweiterung sollte zumindest die bestehende Funktionalität mit Tests abgesichert werden.

## Hinweise zur Umsetzung

- **Swift 6.3 Concurrency**: `StringBuilder` ist aktuell nicht `Sendable` (kein Lock, Referenztyp mit mutablem `var content`), `StringBuffer` ist durch `NSLock` faktisch thread-sicher, sollte aber explizit als `@unchecked Sendable` markiert und dokumentiert werden, sobald neue Methoden hinzukommen — insbesondere wenn zukünftig `Formattable`/`CharsetEncoder`-Typen mit Closures/Zustand ergänzt werden, müssen deren Sendable-Eigenschaften geprüft werden (Closures, die in `async`-Kontexten über Aktorgrenzen gereicht werden, brauchen `@Sendable`).
- **ICU-/Unicode-Datenabhängigkeit**: `Collator`, `RuleBasedCollator`, `BreakIterator`, `Normalizer`, `Bidi`, `Character.UnicodeBlock/UnicodeScript` benötigen in der Java-Referenzimplementierung ICU-Daten (CLDR/UCD). Für die Zielplattformen dieses Projekts (Apple, Linux X11 mit MUSL/GLibc, Windows GDI, FreeBSD, Android, WASM) ist das ein zentrales Risiko:
  - **Apple**: `Foundation`/`ICU` in der Regel vollständig verfügbar → volle Umsetzung realistisch.
  - **Linux GLibc**: Swift-Foundation bringt i. d. R. ICU4C mit (Paketabhängigkeit) → machbar, aber Build-Dependency beachten.
  - **Linux MUSL (statisch)**: ICU4C oft nicht oder nur eingeschränkt verfügbar; swift-corelibs-foundation unter statischem MUSL hat historisch Lücken bei ICU-abhängigen APIs → vor Implementierung Machbarkeits-Spike empfohlen, ggf. Fallback auf ASCII-/einfache Heuristiken mit klarer Dokumentation der Einschränkung.
  - **Windows (GDI)**: eigenes Unicode-Subsystem vorhanden, ICU meist über Windows-eigene Bibliotheken oder gebündeltes ICU verfügbar.
  - **FreeBSD**: ähnlich GLibc-Linux, ICU-Verfügbarkeit über Ports/Pkg prüfen.
  - **Android**: NDK bringt kein volles ICU für native Swift-Toolchains standardmäßig mit — Prüfen nötig.
  - **WASM**: keine Foundation-ICU-Anbindung im klassischen Sinn; hier ist von vollständiger `Collator`/`BreakIterator`/`Normalizer`/`Bidi`-Unterstützung eher abzuraten — Empfehlung: Stub mit klarer Fehlermeldung (`preconditionFailure` gemäß Java2Swift.md-Konvention) statt stiller Falsch-Implementierung.
  - Empfehlung: API-Oberfläche (Methodensignaturen, Exceptions) plattformunabhängig bereitstellen, die tatsächliche Implementierung pro Plattform hinter `#if canImport(...)`-Guards mit Fallback bündeln (analog zur bestehenden MUSL/CoreFoundation-Guard-Praxis bei X11-Code, siehe Projekt-Memory `project_open_issues.md`).
- **CharsetEncoder/Decoder**: Sollte analog zum bestehenden `Charset`-Muster mit `String.Encoding`-Mapping umgesetzt werden, aber mit expliziter `CodingErrorAction`-Steuerung — Foundations `String(data:encoding:)` liefert bei Fehlern nur `nil`, daher wird für REPLACE/REPORT/IGNORE-Semantik eine byteweise/`Data`-Analyse nötig sein (kein 1:1-Foundation-Äquivalent).
- **StringBuilder/StringBuffer-Angleichung**: Bevor neue Methoden ergänzt werden, empfiehlt sich ein gemeinsames internes Storage-Protokoll, um Code-Duplikation zwischen beiden Klassen zu vermeiden und den in `deleteCharAt` gefundenen Bug (`removeFirst(offset)` statt Entfernen an Index `offset`) zentral zu beheben.
- **Fehlerkonvention**: Neue Methoden, die in Java `StringIndexOutOfBoundsException` werfen, sollten konsequent `throws` mit `StringIndexOutOfBoundsException` (bereits vorhanden in `Sources/JavApi/lang/StringIndexOutOfBoundsException.swift`) verwenden statt hart abzustürzen, gemäß der in `Java2Swift.md` beschriebenen Exception-Konvention.
