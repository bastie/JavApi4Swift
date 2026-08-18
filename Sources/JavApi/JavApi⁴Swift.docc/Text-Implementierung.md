# Text-Implementierung – Offene Punkte der Java-String-Verarbeitung in JavApi4Swift

*Stand: 2026-08-18*

> **Hinweis zur Pflege dieses Dokuments:** Dies ist eine reine TODO-Liste
> offener Punkte, kein Bestandsbericht. Bereits implementierte Java-APIs
> werden hier **nicht** aufgeführt — sobald ein Punkt umgesetzt ist, wird er
> aus der Liste entfernt statt in einen "erledigt"-Abschnitt verschoben.
> Die Liste ist sortiert nach: (1) Priorität/Bugfixes zuerst, dann (2)
> aufsteigend nach der Java-Version, in der die jeweilige API eingeführt
> wurde. Neue Punkte bitte an der Stelle der zutreffenden Java-Version
> einsortieren (nicht ans Ende anhängen) und Abhängigkeiten zu anderen
> offenen Punkten oder zu bereits vorhandenen Bausteinen im Feld
> „Abhängig von:" vermerken.

Dieses Dokument sammelt die noch fehlenden Teile der Java-Zeichenketten-
Verarbeitung (`java.lang.String`/`StringBuilder`/`StringBuffer`/
`CharSequence`/`Character`, `java.util.regex`, `java.util.StringTokenizer`/
`StringJoiner`/`Formatter`/`Scanner`, `java.text.*`, `java.nio.charset.*`) –
von Java 1.0 bis zu den aktuellen Java-Versionen – im Projekt. Es dient als
Arbeitsgrundlage für die nächste Implementierungsphase (analog zu den bereits
abgeschlossenen Phasen zu `java.util` Collections/HashMap/Arrays und den
Java 8–16 Stream-APIs, siehe Projekt-Memory).

Die Übersetzungskonventionen aus
`Sources/JavApi/JavApi⁴Swift.docc/Java2Swift.md` gelten unverändert (z. B.
abstract class → protocol + default-Implementierung, Exceptions als eigene
Datei pro Klasse mit den vier Standard-Initialisierern, `@unchecked Sendable`
für die `Throwable`-Hierarchie, `final`/`let`, `char` → `Character` bzw.
UTF-16-Codeunit-Semantik).

> **Implementierungsprinzip:** Wo immer möglich wird bei der Umsetzung der
> unten stehenden Punkte an vorhandene Swift-Standardbibliotheks-/
> Foundation-Funktionalität delegiert (dünner Wrapper/Adapter), statt
> Algorithmen von Grund auf neu zu implementieren — z. B. `String`/
> `StringProtocol`-Methoden, `Unicode.Scalar`-Properties, `NumberFormatter`/
> `DateFormatter`, sowie ICU-gestützte Foundation-APIs für `Collator`/
> `Normalizer`/`BreakIterator` auf Plattformen, auf denen sie verfügbar
> sind. Eigenimplementierungen sind nur dort vorgesehen, wo Swift/
> Foundation keine Entsprechung bietet oder Plattform-Guards (MUSL/WASM
> ohne ICU) einen Fallback erzwingen.

## Priorität (vor der versionsweisen Abarbeitung)

Diese Punkte sind unabhängig von der Java-Versions-Reihenfolge zuerst zu
erledigen, weil sie entweder einen Fehler in bereits vorhandenem Code
betreffen oder als Grundlage für mehrere spätere Punkte gebraucht werden.

- [ ] **Bugfix `StringBuilder.deleteCharAt`**: nutzt fälschlich
  `removeFirst(offset)` statt an Position `offset` ein einzelnes Zeichen zu
  entfernen (`Array.removeFirst(k)` entfernt die ersten `k` Elemente, nicht
  das Element bei Index `k`) — funktionale Abweichung von Java (seit
  Java 1.0/1.5). *Abhängig von:* nichts; blockiert aber sinnvolle Tests für
  die unten aufgeführten `StringBuilder`-Ergänzungen (Java 1.5-Abschnitt).
- [ ] **Gemeinsames Storage-Protokoll für `StringBuilder`/`StringBuffer`**:
  bevor `insert`/`delete`/`replace`/`reverse`/`indexOf` in `StringBuilder`
  nachgezogen werden (siehe Java-1.5-Abschnitt), sollte geprüft werden, ob
  beide Klassen ein gemeinsames internes Storage nutzen können, um
  Code-Duplikation zu vermeiden und den `deleteCharAt`-Bug zentral zu
  beheben. *Abhängig von:* obigem Bugfix.
- [ ] **Fehlende Tests nachziehen**, bevor bestehende Funktionalität
  erweitert wird: `StringBuffer`, `Character`, `Collator`/
  `RuleBasedCollator`, `BreakIterator`, `AttributedString`, `Charset`/
  `StandardCharsets`, `MessageFormat`, `ChoiceFormat`,
  `DateFormat`/`SimpleDateFormat` haben derzeit keine sichtbaren eigenen
  Testdateien unter `Tests/JavApiTests/`. *Abhängig von:* nichts; ist aber
  Voraussetzung, um Regressionen bei den Ergänzungen in den
  versionsspezifischen Abschnitten unten sicher zu erkennen.
- [ ] **Fehlerkonvention klären**: Neue Methoden, die in Java
  `StringIndexOutOfBoundsException` werfen, sollten konsequent `throws`
  mit `StringIndexOutOfBoundsException` (bereits vorhanden in
  `Sources/JavApi/lang/StringIndexOutOfBoundsException.swift`) verwenden
  statt hart abzustürzen (aktuell z. B. bei `String.charAt` in
  `String+Java.swift` der Fall), gemäß der in `Java2Swift.md`
  beschriebenen Exception-Konvention. *Abhängig von:* nichts; betrifft aber
  praktisch jeden Punkt unten, der Index-Zugriffe hat.

## Java 1.0

- [ ] `String.concat(String)` — triviales `+`-Äquivalent, fehlt als
  explizite Methode. *Abhängig von:* nichts.
- [ ] `String.regionMatches(...)` (mit/ohne `ignoreCase`). *Abhängig von:*
  nichts.
- [ ] `String.intern()` — in Swift ggf. No-Op/Dokumentationshinweis, da
  Swift-Strings kein String-Pool-Konzept haben. *Abhängig von:* nichts.
- [ ] `String.copyValueOf(char[])` / `copyValueOf(char[], int, int)` — Alias
  zu `valueOf`. *Abhängig von:* nichts.
- [ ] `ChoiceFormat.nextDouble`/`previousDouble` Sonderfälle — Detailprüfung
  empfohlen (Kleinteil, `java.text.ChoiceFormat` seit 1.0). *Abhängig von:*
  nichts.
- [ ] `StringBuffer`: `capacity()` / `ensureCapacity(int)` / `trimToSize()`
  — bislang nicht vorhanden (in Swift ohnehin nur als Hinweis/No-Op
  sinnvoll, da `String` dynamisch wächst). *Abhängig von:* nichts.

## Java 1.1

- [ ] `Character.isJavaIdentifierStart`/`isJavaIdentifierPart`,
  `isUnicodeIdentifierStart`/`Part`. *Abhängig von:* nichts.
- [ ] `Character.getType(char)` (Unicode-Kategorie). *Abhängig von:*
  Unicode-Kategoriedaten — siehe Plattform-Hinweis unten.
- [ ] `BreakIterator` — Grundgerüst vorhanden (Character-/Word-/Sentence-/
  Line-Instanzen), aber die tatsächliche Iterationslogik (`next()`,
  `previous()`, `following()`, `preceding()`, `isBoundary()`) muss geprüft
  werden, ob sie sprachunabhängig korrekt Wort-/Satzgrenzen findet oder nur
  ASCII-Heuristiken nutzt. *Abhängig von:* **ICU-Datenverfügbarkeit** pro
  Zielplattform (siehe Abschnitt „Plattform-/ICU-Abhängigkeiten" unten).
- [ ] `Collator.compare(Object, Object)` / `equals(String, String)` sowie
  volle `RuleBasedCollator`-Regelsprache — Umfang der Regel-Grammatik
  gegenüber Java (ICU-basiert) prüfen. *Abhängig von:* **ICU-Regeldaten**,
  siehe Plattform-Hinweis.
- [ ] `DateFormat.setLenient`/`isLenient`, `getCalendar`/`setCalendar`,
  `getNumberFormat`/`setNumberFormat`. *Abhängig von:* nichts.

## Java 1.2

- [ ] `String.compareTo(String)` / `compareToIgnoreCase(String)` —
  `Comparable<String>` seit Einführung von `Comparable` in 1.2 bzw.
  `CASE_INSENSITIVE_ORDER` seit 1.2. Aktuell nur für numerische Wrapper
  implementiert (`Int+Java.swift` etc.), nicht für `String`. *Abhängig
  von:* nichts; wichtig für Sortierung, sollte früh kommen.
- [ ] `Character.UnicodeBlock`. *Abhängig von:* **Unicode-Blockdaten** pro
  Plattform, siehe Plattform-Hinweis.

## Java 1.4

- [ ] `String.matches(String regex)` — delegiert auf `Pattern`/`Matcher`,
  aber auf `String` fehlt der Convenience-Wrapper. *Abhängig von:*
  vorhandenem `java.util.regex` (bereits implementiert) — reiner
  Fassaden-Aufruf, kein Blocker.
- [ ] `String.contentEquals(StringBuffer)`. *Abhängig von:* nichts.
- [ ] `Pattern`/`Matcher`-Flag-Konstanten vollständig prüfen:
  `UNIX_LINES`, `COMMENTS`, `LITERAL`, `UNICODE_CASE`, `CANON_EQ`
  (aktuell nur `flags()` als Getter sichtbar, keine Konstanten-Liste
  geprüft — Review nötig). *Abhängig von:* nichts.
- [ ] `Matcher.hasAnchoringBounds`/`hasTransparentBounds`/
  `useAnchoringBounds`/`useTransparentBounds`. *Abhängig von:* nichts.
- [ ] `Bidi` (bidirektionaler Text) — **komplett nicht gefunden**.
  *Abhängig von:* **ICU-Bidi-Algorithmus-Implementierung**, auf Apple ggf.
  über CoreText/ICU, unter Linux GLibc/MUSL und insbesondere WASM ohne ICU
  praktisch nicht sinnvoll umsetzbar ohne Zusatzbibliothek — siehe
  Plattform-Hinweis. Empfehlung: als „Nice-to-have, nur auf Plattformen mit
  ICU" einstufen, ggf. Stub mit `preconditionFailure` auf Plattformen ohne
  Unterstützung.
- [ ] `Format.formatToCharacterIterator` (`AttributedCharacterIterator`-
  Rückgabepfad von `NumberFormat`/`DateFormat`) — nicht gefunden, vermutlich
  nicht implementiert. *Abhängig von:* vorhandenem `AttributedCharacterIterator`
  (bereits implementiert).
- [ ] `NumberFormat`/`DecimalFormat`: `getCurrency()`/`setCurrency()`,
  `parse(String, ParsePosition)`-Überladung (statt `throws`) — prüfen, ob
  vorhanden (aus Kurzscan nicht sichtbar). *Abhängig von:* vorhandenem
  `ParsePosition` (bereits implementiert).
- [ ] `java.nio.charset.*` — größte funktionale Einzel-Lücke im gesamten
  Dokument, alles seit Java 1.4:
  - [ ] `CharsetEncoder` / `CharsetDecoder` — **komplett nicht gefunden**.
    Java nutzt diese für kontrollierte Kodierung mit `CodingErrorAction`
    (REPORT/IGNORE/REPLACE), `CoderResult`, Malformed-/Unmappable-
    Behandlung. Aktuell bietet `Charset` nur ein simples
    `encode(_:) -> ByteBuffer` ohne Fehlerbehandlungsstrategie. **Kern**,
    da für robuste I/O-Pfade wichtig. *Abhängig von:* nichts Bestehendem,
    ist aber Voraussetzung für die folgenden Punkte.
  - [ ] `CodingErrorAction`, `CoderResult`, `CharacterCodingException`,
    `MalformedInputException`, `UnmappableCharacterException`. *Abhängig
    von:* `CharsetEncoder`/`CharsetDecoder` (siehe oben).
  - [ ] `Charset.decode(ByteBuffer) -> CharBuffer` — nur die Encode-Richtung
    ist vorhanden. *Abhängig von:* `CharsetDecoder`.
  - [ ] `Charset.availableCharsets()`, `isSupported(String)`, `aliases()`,
    `displayName()`, `canEncode()`. *Abhängig von:* nichts.
  - [ ] `Charset.forName` unterstützt nur eine kleine Teilmenge
    (UTF-8/16[BE/LE]/US-ASCII/ISO-8859-1/-2) — Java unterstützt deutlich
    mehr eingebaute Charsets (z. B. `windows-1252`, `Shift_JIS`, `EUC-JP`;
    `name()` kennt sie zwar für die Anzeige, `forName` kann sie nicht
    zurück auflösen). Inkonsistenz zwischen `name()` (viele Encodings) und
    `forName()` (wenige) beheben. *Abhängig von:* nichts.
  - [ ] `CharsetProvider` (SPI) — für dieses Projekt vermutlich verzichtbar
    (Nice-to-have, sehr randständig). *Abhängig von:* nichts.

## Java 1.5

- [ ] `String.codePointAt(int)` / `codePointBefore(int)` /
  `codePointCount(...)` / `offsetByCodePoints(...)` direkt auf `String` —
  Vorarbeit über `Character.codePointAt` vorhanden, aber keine
  `String`-Instanzmethoden. *Abhängig von:* nichts (Vorarbeit vorhanden).
- [ ] `StringBuilder`: `insert(int, ...)`, `delete(int, int)`,
  `replace(int, int, String)`, `reverse()`, `indexOf(String)` /
  `lastIndexOf(String)`, `capacity()`/`ensureCapacity(int)`/`trimToSize()`,
  `getChars(...)` — in `StringBuffer` größtenteils vorhanden, in
  `StringBuilder` fehlt es komplett. *Abhängig von:* Priorität-Bugfix
  `deleteCharAt` und ggf. gemeinsamem Storage-Protokoll (siehe oben).
- [ ] `Character.valueOf`/Boxing-Cache-Semantik — in Swift ohne
  Objekt-Identität weniger relevant, nur als Hinweis dokumentieren.
  *Abhängig von:* nichts.
- [ ] `Matcher.quoteReplacement(String)`, `Pattern.quote(String)`.
  *Abhängig von:* nichts.
- [ ] `Formattable`-Protokoll (`formatTo`) — fehlt komplett; nötig, damit
  eigene Typen `%s`-kompatibel eigene Formatierung liefern. *Abhängig von:*
  vorhandenem `Formatter`/`Java2SwiftFormatter` (bereits implementiert).
- [ ] `FormatterClosedException`, `IllegalFormatException`-Hierarchie
  (`MissingFormatArgumentException`, `UnknownFormatConversionException`
  etc.) — aktuell unklar, ob `Java2SwiftFormatter` entsprechende Fehler
  differenziert oder nur generisch fehlschlägt (Review nötig). *Abhängig
  von:* nichts, sollte aber vor `Formattable` (s. o.) stehen, da
  `Formattable`-Implementierungen typischerweise diese Exceptions werfen.
- [ ] `Formatter(Locale)` / lokalisierte Zahl-/Datumsformatierung über
  `%d`/`%f`/`%t*` — zu prüfen, ob Locale-Parameter durchgereicht wird.
  *Abhängig von:* nichts.
- [ ] `Scanner`: `next(Pattern)` / `hasNext(Pattern)`,
  `nextBigInteger()` / `nextBigDecimal()`, `skip(Pattern)`, `match()`,
  `reset()`, `nextFloat()`/`hasNextFloat()`, `nextByte()`/`nextShort()` —
  nur Int/Long/Double/Boolean vorhanden. *Abhängig von:*
  `nextBigInteger`/`nextBigDecimal` zusätzlich abhängig vom
  `BigInteger`/`BigDecimal`-Implementierungsstand (separates Thema,
  außerhalb dieses Dokuments).

## Java 1.6

- [ ] `Normalizer` (`java.text.Normalizer`) — **komplett nicht gefunden**
  im Projekt. Wichtig für NFC/NFD/NFKC/NFKD-Normalisierung. *Abhängig
  von:* **ICU-/Unicode-Normalisierungsdaten** — auf Apple-Plattformen über
  `Foundation`/ICU verfügbar (`String.precomposedStringWithCanonicalMapping`
  etc. als Basis nutzbar), unter Linux/MUSL/WASM ohne volle ICU-Bibliothek
  eingeschränkt oder gar nicht verfügbar — Machbarkeit vorab prüfen (z. B.
  swift-foundation/ICU4C-Verfügbarkeit unter statischem MUSL). Siehe
  Plattform-Hinweis unten.

## Java 7

- [ ] `Character.isAlphabetic(int)`, `isIdeographic(int)`. *Abhängig von:*
  nichts.
- [ ] `Character.UnicodeScript`. *Abhängig von:* **Unicode-Script-Daten**,
  siehe Plattform-Hinweis (analog zu `UnicodeBlock`, Java 1.2).
- [ ] `Character.compare(char, char)` statisch. *Abhängig von:* nichts.
- [ ] Named-Capturing-Groups in `Pattern` (`(?<name>...)`) end-to-end
  verifizieren — `Matcher.group(name:)` existiert, aber ob `Pattern.compile`
  alle Java-Regex-Syntaxerweiterungen unterstützt, hängt von der
  zugrunde liegenden `NSRegularExpression`/ICU-Regex-Engine ab.
  *Abhängig von:* **plattformabhängige Regex-Engine**, muss pro
  Zielplattform (Linux ohne Foundation-Vollausbau, WASM) verifiziert
  werden.

## Java 8

- [ ] `String.join(CharSequence, CharSequence...)` /
  `join(CharSequence, Iterable<? extends CharSequence>)` — `StringJoiner`
  existiert bereits, aber die `String.join`-Fassade fehlt. *Abhängig von:*
  vorhandenem `StringJoiner` (bereits implementiert) — reine Fassade,
  kein Blocker.
- [ ] `String.chars()` / `codePoints()` als `IntStream` sowie
  `CharSequence.chars()` / `codePoints()` (Default-Methoden auf
  `CharSequence`). *Abhängig von:* **`java.util.stream`-Fortschritt**
  (`IntStream`) — dieser Punkt kann erst sinnvoll umgesetzt werden, wenn
  `IntStream` im Projekt verfügbar ist (siehe Java-8-16-Streams-Phase in
  Projekt-Memory).
- [ ] `Pattern.splitAsStream(CharSequence)`. *Abhängig von:*
  **`java.util.stream`** (`Stream<String>`), siehe oben.

## Java 9

- [ ] `Matcher.replaceAll(Function<MatchResult,String>)` /
  `replaceFirst(Function<MatchResult,String>)`. *Abhängig von:* nichts
  Zusätzlichem (Funktionsinterface-Unterstützung in Swift bereits nativ
  über Closures gegeben).
- [ ] `Matcher.results()` → `Stream<MatchResult>`. *Abhängig von:*
  **`java.util.stream`** (`Stream<MatchResult>`).

## Java 11

- [ ] `String.stripLeading()` / `stripTrailing()`. *Abhängig von:* nichts
  (`strip()` bereits vorhanden).
- [ ] `String.lines()` (`Stream<String>`). *Abhängig von:*
  **`java.util.stream`**.
- [ ] `String.repeat(int)`. *Abhängig von:* nichts.
- [ ] `CharSequence.compare(CharSequence, CharSequence)` (statische
  Utility). *Abhängig von:* nichts.
- [ ] `StringBuilder`/`StringBuffer` implementieren `Comparable` seit
  Java 11 — `compareTo(StringBuilder)` fehlt. *Abhängig von:*
  vorhandenem `StringBuilder`/`StringBuffer` (bereits implementiert).

## Java 12

- [ ] `String.transform(Function<String,R>)`. *Abhängig von:* nichts.
- [ ] `String.indent(int)`. *Abhängig von:* nichts.
- [ ] `String.describeConstable()` / `resolveConstantDesc(...)` — für
  Swift ohne `invokedynamic`/Konstantenpool nicht sinnvoll übertragbar;
  nur als „nicht anwendbar" dokumentieren, keine Implementierung geplant.

## Java 15

- [ ] `String.formatted(Object...)` (Instanzmethode, Pendant zur
  Text-Block-Nutzung). *Abhängig von:* vorhandenem `String.format`
  (bereits implementiert).
- [ ] `CharSequence.isEmpty()` (seit 15 als Default-Methode). *Abhängig
  von:* nichts.
- [ ] Text Blocks (`"""`) — reines Sprachfeature ohne Laufzeit-API-
  Äquivalent, nicht in Swift nachbildbar; kein API-Gegenstück nötig, nur
  zur Vollständigkeit hier vermerkt (keine Umsetzung geplant).

## Java 21 / 23 (Preview-Features, nicht übertragbar)

- [ ] String Templates (`STR."..."`) — Preview-Feature ohne stabiles API,
  für JavApi4Swift nicht relevant/nicht übertragbar (nur zur
  Vollständigkeit dokumentiert, keine Umsetzung geplant).
- [ ] Pattern Matching for switch auf Strings — reines Sprachfeature, kein
  API-Gegenstück nötig; Swift `switch` auf `String` funktioniert bereits
  nativ (nur Hinweis, keine Umsetzung nötig).

## Plattform-/ICU-Abhängigkeiten (Querschnittsthema)

Mehrere der oben aufgeführten Punkte hängen nicht von einer Java-Version,
sondern von derselben zugrunde liegenden Infrastruktur ab — hier
gebündelt, damit die Abhängigkeit nicht mehrfach unterschiedlich
beschrieben wird:

- **Betroffene Punkte:** `Collator`/`RuleBasedCollator` (Java 1.1),
  `BreakIterator` (Java 1.1), `Character.UnicodeBlock` (Java 1.2),
  `Character.UnicodeScript` (Java 7), `Bidi` (Java 1.4), `Normalizer`
  (Java 1.6), `Character.getType` (Java 1.1).
- Diese benötigen in der Java-Referenzimplementierung ICU-Daten
  (CLDR/UCD). Für die Zielplattformen dieses Projekts (Apple, Linux X11
  mit MUSL/GLibc, Windows GDI, FreeBSD, Android, WASM) ist das ein
  zentrales Risiko:
  - **Apple**: `Foundation`/`ICU` i. d. R. vollständig verfügbar → volle
    Umsetzung realistisch.
  - **Linux GLibc**: Swift-Foundation bringt i. d. R. ICU4C mit
    (Paketabhängigkeit) → machbar, Build-Dependency beachten.
  - **Linux MUSL (statisch)**: ICU4C oft nicht oder nur eingeschränkt
    verfügbar; swift-corelibs-foundation unter statischem MUSL hat
    historisch Lücken bei ICU-abhängigen APIs → vor Implementierung
    Machbarkeits-Spike empfohlen, ggf. Fallback auf ASCII-/einfache
    Heuristiken mit klarer Dokumentation der Einschränkung.
  - **Windows (GDI)**: eigenes Unicode-Subsystem vorhanden, ICU meist über
    Windows-eigene Bibliotheken oder gebündeltes ICU verfügbar.
  - **FreeBSD**: ähnlich GLibc-Linux, ICU-Verfügbarkeit über Ports/Pkg
    prüfen.
  - **Android**: NDK bringt kein volles ICU für native Swift-Toolchains
    standardmäßig mit — Prüfen nötig.
  - **WASM**: keine Foundation-ICU-Anbindung im klassischen Sinn; von
    vollständiger `Collator`/`BreakIterator`/`Normalizer`/`Bidi`-
    Unterstützung ist eher abzuraten — Empfehlung: Stub mit klarer
    Fehlermeldung (`preconditionFailure` gemäß Java2Swift.md-Konvention)
    statt stiller Falsch-Implementierung.
  - **Gemeinsame Empfehlung:** API-Oberfläche (Methodensignaturen,
    Exceptions) plattformunabhängig bereitstellen, die tatsächliche
    Implementierung pro Plattform hinter `#if canImport(...)`-Guards mit
    Fallback bündeln (analog zur bestehenden MUSL/CoreFoundation-Guard-
    Praxis bei X11-Code, siehe Projekt-Memory `project_open_issues.md`).

Ebenfalls Querschnitt: mehrere Java-8/9/11-Punkte (`chars()`/
`codePoints()`, `lines()`, `Pattern.splitAsStream`, `Matcher.results()`)
hängen an derselben Voraussetzung — dem Fortschritt der
`java.util.stream`-Implementierung (`IntStream`/`Stream<String>`/
`Stream<MatchResult>`). Diese sollten gebündelt angegangen werden, sobald
`IntStream` im Projekt verfügbar ist.

## Swift-6.3-Concurrency-Hinweis

- `StringBuilder` ist aktuell nicht `Sendable` (kein Lock, Referenztyp mit
  mutablem `var content`), `StringBuffer` ist durch `NSLock` faktisch
  thread-sicher, sollte aber explizit als `@unchecked Sendable` markiert
  und dokumentiert werden, sobald neue Methoden hinzukommen — insbesondere
  wenn zukünftig `Formattable`/`CharsetEncoder`-Typen mit Closures/Zustand
  ergänzt werden, müssen deren Sendable-Eigenschaften geprüft werden
  (Closures, die in `async`-Kontexten über Aktorgrenzen gereicht werden,
  brauchen `@Sendable`). *Betrifft:* alle `StringBuilder`-Punkte
  (Java 1.5, Java 11) sowie `Formattable`/`CharsetEncoder` (Java 1.5 bzw.
  1.4).
- **`CharsetEncoder`/`CharsetDecoder`**: sollte analog zum bestehenden
  `Charset`-Muster mit `String.Encoding`-Mapping umgesetzt werden, aber mit
  expliziter `CodingErrorAction`-Steuerung — Foundations
  `String(data:encoding:)` liefert bei Fehlern nur `nil`, daher wird für
  REPLACE/REPORT/IGNORE-Semantik eine byteweise/`Data`-Analyse nötig sein
  (kein 1:1-Foundation-Äquivalent).
