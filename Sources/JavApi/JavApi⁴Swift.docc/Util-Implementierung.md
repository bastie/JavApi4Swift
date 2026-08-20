# Util-Implementierung – Offene Punkte des `java.util`-Pakets in JavApi4Swift

*Stand: 2026-08-20 (ergänzt um Funde aus einer Prüfung der letzten 50
Git-Commits gegen den tatsächlichen Implementierungsstand — mehrere als
„complete"/„implementiert" gekennzeichnete Commits waren nur teilweise
zutreffend, siehe Punkte mit „bestätigt durch Commit-Prüfung" unten)

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

Dieses Dokument sammelt die noch fehlenden Teile von `java.util` und seiner
Subpakete (`java.util.concurrent` inkl. `.atomic`/`.locks`,
`java.util.function`, `java.util.logging`, `java.util.random`,
`java.util.regex`, `java.util.spi`, `java.util.stream`, `java.util.zip`) —
von Java 1.0/1.1 bis zu den aktuellen Java-Versionen — im Projekt. Es dient
als Arbeitsgrundlage für die nächste Implementierungsphase, analog zu
`Text-Implementierung.md` (Java-`String`/Text-Verarbeitung).

Die Übersetzungskonventionen aus
`Sources/JavApi/JavApi⁴Swift.docc/Java2Swift.md` gelten unverändert (z. B.
abstract class → protocol + default-Implementierung, Exceptions als eigene
Datei pro Klasse mit den vier Standard-Initialisierern, `@unchecked Sendable`
für die `Throwable`-Hierarchie, `open`/`final`, `preconditionFailure` statt
`fatalError` bei abstrakten Vorlagenmethoden).

> **Implementierungsprinzip:** Wo immer möglich wird bei der Umsetzung der
> unten stehenden Punkte an vorhandene Swift-Standardbibliotheks-/
> Foundation-Funktionalität delegiert (dünner Wrapper/Adapter), statt
> Algorithmen von Grund auf neu zu implementieren — z. B. Swift `Dictionary`/
> `Array`/`Set` als Backing-Store (wie bereits bei `HashMap`/`ArrayList`
> praktiziert), Swift `RandomNumberGenerator` für `java.util.random`,
> Swift Concurrency (`Task`/`actor`/`AsyncSequence`) bzw. `DispatchQueue`
> für `java.util.concurrent` wo plattformseitig verfügbar, sowie
> `Foundation.NSLock`/`NSCondition` als Fallback. Eigenimplementierungen
> sind nur dort vorgesehen, wo Swift/Foundation keine Entsprechung bietet
> oder Plattform-Guards (MUSL/WASM ohne Threads) einen Fallback erzwingen.

## Priorität (vor der versionsweisen Abarbeitung)

- [ ] **BUG: `ArrayList.addAll(_:collection:)` (indexbasiert) stürzt mit
  `fatalError` statt eine Exception zu werfen**: In
  `Sources/JavApi/util/ArrayList.swift` prüft die Methode zwar den Index
  (`location >= 0 && location <= elements.count`), ruft bei Verletzung
  aber `fatalError("IndexOutOfBoundsException: ...")` auf — mit dem im
  Code selbst hinterlassenen Kommentar „Because AbstractList declares this
  as non-throwing, we crash like the Harmony reference implementation does
  on invalid indices." Das widerspricht der in `Java2Swift.md`
  dokumentierten Konvention (Exceptions über `throws`, nicht über harte
  Abstürze) und ist exakt das gleiche Muster, das bereits in
  `Text-Implementierung.md` für `String.charAt` bemängelt wurde. Die
  eigentliche Ursache liegt in der Signatur von
  `AbstractList.addAll(_:collection:)`, die nicht `throws` deklariert.
  *Abhängig von:* Erweiterung der `AbstractList`/`List`-Protokoll-Signatur
  um `throws`, was Auswirkungen auf alle konformen Typen (`Vector`,
  `LinkedList`, …) hat — vor der Änderung Kompatibilitäts-Review nötig.
- [ ] **BUG/Lücke: `ConcurrentModificationException` wird im gesamten
  `java.util`-Baum nirgends geworfen**: Die Klasse existiert
  (`Sources/JavApi/util/ConcurrentModificationException.swift`), aber eine
  Volltextsuche über `Sources/JavApi/util/*.swift` findet außer der
  Klassendefinition selbst keine einzige Verwendungsstelle — kein
  `modCount`-Feld, kein Iterator (`HashMap`, `ArrayList`, `LinkedList`,
  `TreeMap`, `HashSet`, `Vector`, …) prüft auf strukturelle Änderung
  während der Iteration. Damit fehlt Javas fail-fast-Semantik komplett;
  Iteration über eine während des Iterierens modifizierte Collection
  liefert in JavApi4Swift stillschweigend falsche/undefinierte Ergebnisse
  statt der in Java garantierten (wenn auch „best effort") Exception.
  *Abhängig von:* nichts technisch Blockierendes, aber ein grundlegendes
  Entwurfsmuster (z. B. `modCount`-Zähler in `AbstractList`/`AbstractMap`
  plus Prüfung in allen zugehörigen Iterator-Implementierungen), das vor
  Einzel-Nachbesserungen an bestehenden Collections geklärt werden sollte.
- [ ] **Korrektur zum Vorab-Audit: `Locale.Builder` ist entgegen der
  ursprünglichen Einschätzung bereits vorhanden** (`Sources/JavApi/util/
  Locale.swift`, ab `// MARK: - Locale.Builder (Java 7)`) — mit
  `setLanguage`/`setRegion`/`setScript`/`setVariant`/`setExtension`/
  `build()`. Es fehlen aber gegenüber Java 7 noch: `setLanguageTag(String)`,
  `setLocale(Locale)` (Java-Signatur nimmt zusätzlich Extensions/Variant
  aus dem übergebenen `Locale` mit, aktuelle Implementierung übernimmt nur
  Sprache+Land), `setUnicodeLocaleKeyword(String,String)`,
  `clear()`/`clearExtensions()`, sowie sämtliche Getter
  (`getLanguage()`/`getRegion()`/... existieren auf `Builder` in Java
  nicht, das ist korrekt — aber `removeExtension` fehlt). Dieser Punkt
  ersetzt die im Vorab-Audit genannte komplette Abwesenheit von
  `Locale.Builder`. *Abhängig von:* nichts.
- [ ] **`java.util.stream` Primitive Streams (`IntStream`/`LongStream`/
  `DoubleStream`/`BaseStream`/`StreamSupport`) sind eine strukturelle
  Vorbedingung für mehrere bereits in `Text-Implementierung.md`
  dokumentierte Punkte** (`String.chars()`/`codePoints()`,
  `CharSequence.chars()`/`codePoints()`, `Pattern.splitAsStream`,
  `Matcher.results()`, `String.lines()`) — siehe dortiger Abschnitt „Java
  8"/„Java 9"/„Java 11". Aktuell existieren im Projekt nur `Stream`,
  `Collector`, `Gatherer`/`Gatherers` (`Sources/JavApi/util/stream/`);
  `IntStream`, `LongStream`, `DoubleStream`, `BaseStream` und
  `StreamSupport` fehlen komplett. Da mehrere String/Text-Punkte davon
  abhängen, sollte dieser Block hoch priorisiert werden. *Abhängig von:*
  nichts technisch Blockierendem, aber Grundlage für o. g. Punkte in
  `Text-Implementierung.md`.
- [ ] **Machbarkeits-Klärung `java.util.concurrent` vor Implementierungs-
  beginn nötig** — siehe Abschnitt „Plattform-/Concurrency-Abhängigkeiten"
  unten. Fast das gesamte Paket (Executor-Framework, `ConcurrentHashMap`,
  `CompletableFuture`, `BlockingQueue`-Familie, `.atomic`, `.locks`) ist
  noch nicht begonnen (nur 6 Dateien: `Callable`, `Future`,
  `ExecutionException`, `TimeoutException`, `StructuredTaskScope`,
  `Subtask`); bevor hier in die Breite implementiert wird, muss geklärt
  sein, worauf plattformübergreifend aufgesetzt wird. *Abhängig von:*
  nichts.
- [ ] **Fehlende Tests nachziehen**, bevor bestehende Funktionalität
  erweitert wird: `java.util.random` (`RandomGenerator`/
  `RandomGeneratorFactory` — nur die klassische `Random`-Klasse hat eine
  Testdatei, `JavApi_util_Random_Tests.swift`, das neuere
  `RandomGenerator`-Protokoll/`RandomGeneratorFactory` nicht),
  `java.util.spi` (keine Testdatei unter `Tests/JavApiTests/util/`
  gefunden, obwohl `ServiceLoader` selbst getestet ist), `Callable`/
  `Future`/`ExecutionException`/`TimeoutException` (nur generisch über
  `JavApi_util_concurrent_Tests.swift` mit abgedeckt, keine dedizierten
  Testdateien pro Typ), `AbstractCollection`/`AbstractList`/`AbstractMap`/
  `AbstractQueue`/`AbstractSequentialList`/`AbstractSet` (keine eigenen
  Testdateien, nur indirekt über konkrete Unterklassen abgedeckt).
  *Abhängig von:* nichts; ist aber Voraussetzung, um Regressionen bei
  Ergänzungen in den unten stehenden Abschnitten sicher zu erkennen.
- [ ] **`HashMap<K: Hashable, V: Equatable>` erzwingt `V: Equatable`**,
  was Java's `HashMap<K,V>` (kein Constraint auf `V`) nicht kennt und
  einschränkt, welche Werttypen gespeichert werden können (Konsequenz:
  Werte ohne `Equatable`-Konformität — z. B. reine Funktions-/Closure-
  Wrapper-Typen — können nicht als `HashMap`-Werte verwendet werden,
  obwohl das in Java uneingeschränkt möglich ist). Sollte dokumentiert
  oder mittels eines separaten „nicht-vergleichbaren" Value-Pfads
  gemildert werden. *Abhängig von:* Architekturentscheidung, ob das
  Projekt hier bewusst von Java abweicht (dokumentieren) oder ein
  alternativer Ansatz (z. B. Wrapper mit `AnyEquatable`-Type-Erasure wie
  bereits in `ArrayList.hashCode()` für `AnyHashable` genutzt) verfolgt
  wird.

## Java 1.2

- [ ] `IdentityHashMap<K,V>` — Map-Implementierung mit `===`-Identitäts-
  statt `==`-Wertevergleich für Schlüssel; **komplett nicht gefunden**
  (nur Erwähnung in `JavaVersions/Java_1.4.md`, keine Implementierung).
  *Abhängig von:* nichts.

## Java 1.4

- [ ] `PropertyPermission` — **nicht gefunden**; für ein reines
  Bibliotheksprojekt ohne `SecurityManager`-Unterstützung vermutlich
  Nice-to-have/Stub-Kandidat. *Abhängig von:* Klärung, ob das Projekt
  `java.security`-Permission-Klassen überhaupt sinnvoll abbildet (siehe
  ggf. bestehenden Stand von `java.security`).

## Java 1.5

- [ ] `Formattable`-Protokoll (`formatTo`) — bereits in
  `Text-Implementierung.md` (Java-1.5-Abschnitt) dokumentiert; hier nur
  referenziert, da es formal zu `java.util.Formatter` gehört. *Abhängig
  von:* vorhandenem `Formatter` (bereits implementiert).
- [ ] `FormattableFlags` — Konstanten-Namespace (`LEFT_JUSTIFY`,
  `UPPERCASE`, `ALTERNATE`) für `Formattable.formatTo` — **nicht
  gefunden**. *Abhängig von:* `Formattable` (siehe oben).
- [ ] Vollständige `IllegalFormatException`-Hierarchie —
  `IllegalFormatException`, `IllegalFormatConversionException`,
  `IllegalFormatFlagsException`, `IllegalFormatPrecisionException`,
  `IllegalFormatWidthException`, `IllegalFormatCodePointException`,
  `MissingFormatArgumentException`, `MissingFormatWidthException`,
  `DuplicateFormatFlagsException`, `UnknownFormatConversionException`,
  `UnknownFormatFlagsException`, `FormatFlagsConversionMismatchException`
  — Vorab-Audit fand ~12 zusammengehörige Exception-Typen; laut
  Volltextsuche existieren `IllegalFormatException`,
  `MissingFormatArgumentException` und `FormatterClosedException` nur als
  **Erwähnung in `Text-Implementierung.md`**, keine Swift-Implementierung
  gefunden. Jeder Typ folgt dem in `Java2Swift.md` beschriebenen
  Exception-Datei-Muster (eigene Datei, vier Standard-Initialisierer).
  *Abhängig von:* vorhandenem `Formatter`/`Java2SwiftFormatter` (bereits
  implementiert), sollte vor `Formattable` umgesetzt werden (siehe auch
  Priority-Abschnitt in `Text-Implementierung.md`).
- [ ] `FormatterClosedException` — eigene Datei nach Exception-Muster,
  wird geworfen, wenn nach `Formatter.close()` weiterhin formatiert wird.
  *Abhängig von:* vorhandenem `Formatter`.
- [ ] **`java.util.concurrent` Kernpaket (seit Java 5)** — größte
  funktionale Einzel-Lücke des gesamten Dokuments. Aktuell nur `Callable`,
  `Future`, `ExecutionException`, `TimeoutException` vorhanden (plus die
  neueren `StructuredTaskScope`/`Subtask`, siehe Java-21/25-Abschnitt).
  Zur besseren Übersicht gruppiert statt methodenweise aufgeführt:
  - [ ] **Executor-Framework**: `Executor`, `ExecutorService`,
    `ScheduledExecutorService`, `Executors` (Factory-Methoden),
    `ThreadPoolExecutor`, `ScheduledThreadPoolExecutor`,
    `AbstractExecutorService`, `RejectedExecutionHandler`/
    `RejectedExecutionException`, `ThreadFactory`. Kernfunktionalität:
    Task-Einreichung/-Ausführung auf Thread-Pools, `Future`-Rückgabe für
    `submit(...)`, geplante/periodische Ausführung.
  - [ ] **`Future`-Ergänzungen**: `CompletableFuture`, `CompletionStage`,
    `FutureTask`, `RunnableFuture`, `Delayed`/`ScheduledFuture`.
    Kernfunktionalität: komponierbare asynchrone Berechnungsketten
    (`thenApply`/`thenCompose`/`allOf`/...).
  - [ ] **Nebenläufige Collections**: `ConcurrentHashMap`,
    `ConcurrentSkipListMap`, `ConcurrentSkipListSet`,
    `ConcurrentLinkedQueue`, `ConcurrentLinkedDeque`, `CopyOnWriteArrayList`,
    `CopyOnWriteArraySet`, `ConcurrentMap`-Protokoll. Kernfunktionalität:
    threadsichere Collection-Varianten mit feingranularer Sperrung/
    lock-freien Algorithmen.
  - [ ] **`BlockingQueue`-Familie**: `BlockingQueue`, `BlockingDeque`,
    `ArrayBlockingQueue`, `LinkedBlockingQueue`, `LinkedBlockingDeque`,
    `PriorityBlockingQueue`, `SynchronousQueue`, `DelayQueue`.
    Kernfunktionalität: Producer-Consumer-Warteschlangen mit blockierendem
    `put`/`take`.
  - [ ] **Synchronisationsprimitive**: `CountDownLatch`, `Semaphore`,
    `CyclicBarrier`, `Exchanger`, `Phaser`. Kernfunktionalität:
    koordinierte Thread-Synchronisation jenseits von `synchronized`.
  - [ ] **`ForkJoinPool`/`ForkJoinTask`**: `ForkJoinPool`, `ForkJoinTask`,
    `RecursiveTask`, `RecursiveAction`, `ForkJoinWorkerThread`.
    Kernfunktionalität: Work-Stealing-Framework, Basis für parallele
    Streams.
  - [ ] **`TimeUnit`** (Enum) — wird bereits in Kommentaren referenziert
    (`Future.swift`), ist aber selbst **nicht implementiert**;
    Voraussetzung für zeitbasierte Methoden fast aller obigen Typen
    (`awaitTermination(timeout, TimeUnit)` etc.).
  - [ ] **`java.util.concurrent.atomic`** (eigenes Unterpaket, komplett
    fehlend — 16 Referenztypen): `AtomicBoolean`, `AtomicInteger`,
    `AtomicLong`, `AtomicReference`, `AtomicIntegerArray`,
    `AtomicLongArray`, `AtomicReferenceArray`, `AtomicMarkableReference`,
    `AtomicStampedReference`, `LongAdder`, `DoubleAdder`, `LongAccumulator`,
    `DoubleAccumulator`, `AtomicIntegerFieldUpdater`,
    `AtomicLongFieldUpdater`, `AtomicReferenceFieldUpdater`.
    Kernfunktionalität: lock-freie atomare Operationen; in Swift ggf. über
    `Atomic`-Property-Wrapper/`ManagedAtomic` aus `swift-atomics` oder
    eigene `NSLock`-basierte Fallbacks umsetzbar — siehe
    Plattform-Abschnitt.
  - [ ] **`java.util.concurrent.locks`** (eigenes Unterpaket, komplett
    fehlend): `Lock`, `ReadWriteLock`, `ReentrantLock`,
    `ReentrantReadWriteLock`, `Condition`, `StampedLock`,
    `AbstractQueuedSynchronizer`, `AbstractQueuedLongSynchronizer`,
    `LockSupport`. Kernfunktionalität: explizite Sperr-APIs jenseits von
    `synchronized`; `AbstractQueuedSynchronizer` ist die Basis vieler
    JDK-Synchronisationsklassen und in Swift vermutlich nur mit
    erheblichem Aufwand (oder gar nicht 1:1) nachbildbar — Machbarkeit
    separat prüfen.
  - *Abhängig von (für alle o. g. Unterpunkte):* Klärung der
    Concurrency-Grundlage, siehe Priority-Abschnitt und
    „Plattform-/Concurrency-Abhängigkeiten" unten.

## Java 1.5 (java.util.regex — Ergänzung zu Text-Implementierung.md)

- [ ] **`Matcher.hitEnd()` / `requireEnd()` / `pattern()`-Getter fehlen** —
  neu bestätigt durch Commit-Prüfung (Commit `a1f8cc39` behauptet
  „implement java.util.regex", tatsächlich fehlen diese drei Methoden in
  `Sources/JavApi/util/regex/Matcher.swift`). `Matcher.quoteReplacement`
  (static), `Pattern.quote` (static) und `Pattern.splitAsStream`/
  `Matcher.results()` sind bereits als offene Punkte in
  `Text-Implementierung.md` (Java-1.5/8/9-Abschnitte) erfasst — hier nur
  die zusätzlich gefundenen drei Methoden, damit `java.util.regex` nicht
  in zwei Dokumenten unterschiedlich vollständig aussieht. *Abhängig von:*
  vorhandenem `Matcher`/`Pattern` (bereits implementiert für die
  Kernfunktionalität matches/find/group/replace).

## Java 6

- [ ] `Formatter`-Konstruktoren/-Methoden mit explizitem `Locale`- und
  `Appendable`-Parameter vollständig prüfen (Ergänzung zum bereits in
  `Text-Implementierung.md` genannten Punkt „Formatter(Locale)"; hier nur
  Querverweis, da beide Dokumente denselben Typ berühren). *Abhängig von:*
  vorhandenem `Formatter`.

## Java 7

- [ ] `java.util.concurrent.ForkJoinPool` — bereits oben (Java-5-Abschnitt,
  Konzernpunkt) enthalten; `ForkJoinPool` selbst kam mit Java 7 hinzu
  (ursprünglich als externe `jsr166y`-Bibliothek, seit 7 im JDK). Hier nur
  Versions-Klarstellung, kein separater Punkt. *Abhängig von:* siehe
  Java-5-Abschnitt.
- [ ] `Objects`-Klasse: `requireNonNullElse`/`requireNonNullElseGet` sind
  Java-9-Ergänzungen (siehe dort); für Java 7 zu prüfen, ob die
  Grundmethoden `requireNonNull(T)`/`requireNonNull(T, String)`/
  `equals`/`deepEquals`/`hash`/`hashCode`/`toString` in
  `Sources/JavApi/util/Objects.swift` vollständig sind (Review empfohlen,
  keine Lücke im Vorab-Audit vermerkt, aber ungeprüft). *Abhängig von:*
  nichts.

## Java 8

- [ ] `DoubleToIntFunction`, `DoubleToLongFunction`, `IntToDoubleFunction`,
  `IntToLongFunction`, `LongToDoubleFunction`, `LongToIntFunction` — sechs
  primitive Konvertierungs-Funktionsinterfaces aus `java.util.function`
  fehlen; die übrigen 37 von 43 Interfaces sind bereits vorhanden.
  *Abhängig von:* nichts.
- [ ] `DoubleSummaryStatistics`, `IntSummaryStatistics`,
  `LongSummaryStatistics` — Akkumulator-Klassen für
  `Stream.collect(Collectors.summarizingInt/...)` bzw.
  `IntStream.summaryStatistics()` — **komplett nicht gefunden**.
  *Abhängig von:* `IntStream`/`LongStream`/`DoubleStream` (siehe
  Priority-Abschnitt).
- [ ] `PrimitiveIterator` + Unter-Interfaces (`PrimitiveIterator.OfInt`,
  `OfLong`, `OfDouble`) — spezialisierte Iterator-Protokolle ohne Boxing;
  **nicht gefunden**. *Abhängig von:* nichts direkt Blockierendem, aber
  sinnvollerweise zusammen mit `IntStream`/`LongStream`/`DoubleStream`
  umgesetzt (gemeinsame Grundlage).
- [ ] `Spliterators` — Utility-Klasse mit statischen Factory-Methoden
  (`spliterator(...)`, `spliteratorUnknownSize(...)`,
  `emptySpliterator()` etc.) ergänzend zum bereits vorhandenen
  `Spliterator`-Protokoll (`Sources/JavApi/util/Spliterator.swift`).
  *Abhängig von:* vorhandenem `Spliterator` (bereits implementiert).
- [ ] `StreamSupport` — Brücke von `Spliterator` zu `Stream`/`IntStream`/
  etc. (`StreamSupport.stream(...)`); **nicht gefunden**. *Abhängig von:*
  `IntStream`/`LongStream`/`DoubleStream`/`BaseStream` (siehe
  Priority-Abschnitt) sowie vorhandenem `Spliterator`.
- [ ] `BaseStream` — gemeinsames Basis-Interface von `Stream`/`IntStream`/
  `LongStream`/`DoubleStream` (`onClose`, `close`, `isParallel`,
  `sequential`, `parallel`, `unordered`); aktuell hat `Stream` vermutlich
  keinen gemeinsamen Oberbau, da die primitiven Streams fehlen. *Abhängig
  von:* siehe Priority-Abschnitt.
- [ ] **`Comparator.thenComparingInt`/`thenComparingLong`/
  `thenComparingDouble` fehlen komplett** — bestätigt durch Commit-Prüfung
  (Commit `1278291f` behauptet „Java 8/9 API completions... Comparator",
  tatsächlich existiert in `Sources/JavApi/util/function/` bzw.
  `Comparator+Java8.swift` nur das generische `thenComparing`, die drei
  primitiven Spezialisierungen (analog zu `comparingInt`/`comparingLong`/
  `comparingDouble`, die laut Review vorhanden sind) fehlen. *Abhängig
  von:* nichts.
- [ ] `Optional.equals(Object)` / `hashCode()` / `toString()` fehlen —
  bestätigt durch Commit-Prüfung (Commit `1278291f` behauptet „Java 8/9
  API completions... Optional", tatsächlich fehlen in
  `Sources/JavApi/util/Optional.swift` alle drei Standard-`Optional`-
  Methoden seit Java 8; nur ~7 von ~20 Java-`Optional`-Methoden sind
  laut Review vorhanden). *Abhängig von:* nichts.

## Java 9

- [ ] `Objects.requireNonNullElse(T, T)` / `requireNonNullElseGet(T,
  Supplier<T>)`. *Abhängig von:* vorhandenem `Objects` (bereits
  implementiert) — reine Ergänzung.
- [ ] Restliches Executor-/Concurrent-Ökosystem seit Java 9
  (`Flow`-API: `Flow.Publisher`/`Subscriber`/`Subscription`/`Processor`
  als Reactive-Streams-Grundlage, `SubmissionPublisher`) — **nicht
  gefunden**. *Abhängig von:* Klärung der Concurrency-Grundlage (siehe
  Priority-Abschnitt).

## Java 11

- [ ] `Predicate.not(Predicate)` (statische Utility-Methode) — prüfen, ob
  in `Sources/JavApi/util/function/Predicate.swift` vorhanden (aus
  Kurzscan nicht sichtbar, Review empfohlen). *Abhängig von:* nichts.

## Java 12

- [ ] `Collectors.teeing(...)` — falls `java.util.stream.Collector`-
  Fabrikmethoden (`Collectors`-Klasse) im Projekt existieren, Review ob
  `teeing` (Java 12) abgedeckt ist; im Vorab-Audit ist unklar, ob eine
  `Collectors`-Utility-Klasse überhaupt existiert (nur `Collector`-
  Protokoll selbst gefunden, `Collectors`-Fabrik nicht explizit erwähnt —
  gesondert prüfen, ggf. eigener Punkt „`Collectors`-Fabrikklasse fehlt
  komplett" statt Einzelmethode). *Abhängig von:* Review-Ergebnis.

## Java 14

- [ ] `HexFormat`-Vorarbeit — **kein Java-14-Feature**, aber angrenzend:
  `Locale`-Datensatz-Erweiterungen (keine bekannte konkrete Lücke aus dem
  Audit) — kein separater Punkt nötig, nur Platzhalter für künftige
  Java-14-spezifische Funde bei Detailprüfung.

## Java 16

- [ ] `Stream.toList()` — Kurzform für
  `collect(Collectors.toUnmodifiableList())`; prüfen, ob auf dem
  vorhandenen `Stream`-Typ vorhanden. *Abhängig von:* vorhandenem `Stream`
  (bereits implementiert), unabhängig von den primitiven Streams.

## Java 17

- [ ] `HexFormat` — Klasse zur Hex-Kodierung/-Dekodierung von Bytes
  (`HexFormat.of()`, `formatHex`, `parseHex`, `toHexDigits`, Delimiter-/
  Prefix-/Suffix-Konfiguration); **komplett nicht gefunden** (verifiziert:
  erstmals in der Java-SE-17-API-Dokumentation vorhanden). *Abhängig
  von:* nichts — guter Kandidat für dünnen Wrapper um Swift/Foundation
  Hex-Encoding (`String(format:)`/manuelle Byte-Iteration).
- [ ] **`RandomGeneratorFactory` registriert bisher nur einen
  Dummy-Algorithmus** — bestätigt durch Commit-Prüfung (Commit `996e2c01`
  behauptet „implement java.util.random package", tatsächlich sind laut
  Code-Kommentar in `RandomGeneratorFactory.swift` bei `of()`/`.all()`
  aktuell nur der klassische LCG-Algorithmus („Random", Legacy) registriert.
  Von den seit Java 17 im JDK ausgelieferten ~17 konkreten Algorithmen
  (`L32X64MixRandom`, `L64X128MixRandom`, `L64X128StarStarRandom`,
  `L64X256MixRandom`, `L64X1024MixRandom`, `L128X128MixRandom`,
  `L128X256MixRandom`, `L128X1024MixRandom`, `Xoroshiro128PlusPlus`,
  `Xoshiro256PlusPlus`, `SecureRandom`-Anbindung, …) ist **keiner**
  implementiert — das Interface-/Factory-Gerüst (`RandomGenerator` +
  Sub-Interfaces) ist vollständig, aber ohne echte Algorithmen praktisch
  nur ein leeres Regal. *Abhängig von:* vorhandenem `RandomGenerator`-
  Protokoll-Stack (bereits implementiert); Testlücke siehe zusätzlich
  Priority-Abschnitt.

## Java 8 / 17 (SplittableRandom)

- [ ] `SplittableRandom` — laut Volltextsuche nur in
  `Sources/JavApi/util/random/RandomGenerator.swift` und
  `RandomGeneratorFactory.swift` **erwähnt** (vermutlich als
  Dokumentations-/Protokoll-Referenz), keine eigenständige `SplittableRandom`-
  Klasse gefunden, die `RandomGenerator.SplittableGenerator` konkret
  implementiert (seit Java 8, `RandomGenerator`-Konformität seit Java 17).
  *Abhängig von:* vorhandenem `RandomGenerator`-Protokoll.

## Java 21

- [ ] `SequencedCollection`/`SequencedMap`/`SequencedSet` — laut Datei-
  liste bereits vorhanden (`Sources/JavApi/util/SequencedCollection.swift`
  etc.) und mit eigener Testdatei (`JavApi_util_Java21_SequencedCollections_Tests.swift`)
  abgedeckt — hier nur zur Vollständigkeit erwähnt, kein offener Punkt
  ohne weitere Detailprüfung (Review empfohlen, ob alle Default-Methoden
  wie `reversed()`/`getFirst()`/`getLast()`/`addFirst()`/`addLast()`
  bereits auf allen relevanten Kern-Collections — `ArrayList`,
  `LinkedList`, `ArrayDeque`, `LinkedHashSet`, `LinkedHashMap` —
  angebunden sind, nicht nur auf den Protokollen selbst). *Abhängig
  von:* nichts.
- [ ] `Locale.LanguageRange` — repräsentiert Sprachbereiche für
  `Locale.filter`/`Locale.lookup` (`Locale.LanguageRange.parse(String)`);
  **komplett nicht gefunden**, obwohl seit Java 8 vorhanden (nicht 21 —
  Korrektur zum Vorab-Audit: `LanguageRange` existiert bereits seit
  Java 8, nicht erst 21; wird hier trotzdem im 21er-Abschnitt geführt,
  weil es typischerweise zusammen mit den übrigen `Locale`-Lücken
  bearbeitet werden dürfte — bei Umsetzung „seit Java 8" referenzieren).
  *Abhängig von:* vorhandenem `Locale` (bereits implementiert).
- [ ] `Calendar.Builder` — Analogon zu `Locale.Builder` für `Calendar`-
  Konstruktion (`setDate`, `setTimeOfDay`, `setFields`, `build()`); **nicht
  gefunden** (seit Java 8, nicht 21 — gleiche Korrektur wie bei
  `LanguageRange`). *Abhängig von:* vorhandenem `Calendar`/
  `GregorianCalendar` (bereits implementiert).
- [ ] **`StructuredTaskScope` implementiert eine bereits überholte
  Preview-API-Form** — bestätigt durch Commit-Prüfung (Commit `ab175adf`
  behauptet „implement java.util.concurrent.StructuredTaskScope
  (Java 25)"): Der Code in `Sources/JavApi/util/concurrent/
  StructuredTaskScope.swift` nutzt das alte Subklassen-Modell
  (`ShutdownOnFailure`/`ShutdownOnSuccess` als konkrete Unterklassen,
  öffentlicher Konstruktor `StructuredTaskScope<T>()`, zu überschreibende
  `handleComplete()`-Methode). Die aktuelle Preview-API (JEP 505
  „Structured Concurrency (Fifth Preview)", Java 23/24, bestätigt
  weitergeführt in JEP 525 „Sixth Preview" für Java 25) nutzt stattdessen
  eine statische Fabrikmethode `StructuredTaskScope.open(Joiner<T,R>)` mit
  einem separaten `Joiner`-Interface statt Vererbung — ein
  API-Bruch zwischen Preview-Iterationen, kein bloßes „noch Preview,
  ansonsten passt es". Migration auf das `Joiner`-Modell nötig, sobald das
  Projekt gegen eine aktuelle Java-Version ausgerichtet wird. *Abhängig
  von:* nichts technisch Blockierendem, aber Breaking-Change für
  bestehende `StructuredTaskScope`-Nutzung im Projekt (falls vorhanden) —
  vor Migration prüfen, ob/wo die aktuelle API bereits verwendet wird.

## Java 21 / 22 / 24 (ScopedValue)

- [ ] `ScopedValue` (`java.lang`, aber eng mit `StructuredTaskScope`
  verzahnt und thematisch hier mitgeführt) — Ersatz für vererbbare
  `ThreadLocal`-Werte in strukturierter Nebenläufigkeit; **nicht
  gefunden**. *Abhängig von:* Klärung der Concurrency-Grundlage (siehe
  Priority-Abschnitt) sowie vorhandenem `StructuredTaskScope`.

## Java 22 / 24 (Gatherer)

- [ ] `Gatherer`/`Gatherers` — laut Vorab-Audit bereits vorhanden
  (`Sources/JavApi/util/stream/Gatherer.swift`,
  `Gatherers.swift`, mit eigener Testdatei
  `JavApi_util_stream_Gatherer_Tests.swift`); hier nur der Hinweis, dass
  `Gatherer` seit Java 22 Preview, final seit Java 24 ist — Review, ob die
  im Projekt vorhandene Fassung der finalen (Java-24-)API-Form entspricht
  oder noch der Preview-Form aus Java 22/23 folgt. *Abhängig von:* nichts.

## Java 24 / 25 (Struktur, StructuredTaskScope-Nachfolge)

- [ ] Sobald `StructuredTaskScope` in einer künftigen Java-Version final
  wird, API-Oberfläche gegen die dann finale Fassung nachziehen
  (Platzhalter-Punkt, damit dieser Bereich bei der nächsten Java-Version
  nicht vergessen wird). *Abhängig von:* dem bereits vorhandenen
  `StructuredTaskScope`/`Subtask`.

## Java 17 / 20 / 21 / 22 (java.util.zip)

- [ ] `ZipError` — einzige laut Vorab-Audit fehlende Klasse in
  `java.util.zip` (19 von 20 Referenztypen vorhanden); wird als
  internal `Error`-Unterklasse bei defektem Zip-Dateiformat geworfen.
  *Abhängig von:* nichts.

## Java 1.4 / 9 (java.util.logging)

- [ ] `ErrorManager` — Fehlerbehandlung für `Handler`-Implementierungen
  (`publish`/`flush`/`close`-Fehler); **nicht gefunden**. *Abhängig von:*
  vorhandenem `Handler` (bereits implementiert).
- [ ] `LoggingMXBean`/`LoggingMXBean`-Registrierung über JMX — für ein
  Bibliotheksprojekt ohne volle JMX-Unterstützung vermutlich
  Nice-to-have/Stub-Kandidat; prüfen, ob JMX im Projekt überhaupt
  abgebildet wird, bevor investiert wird. *Abhängig von:* Klärung
  JMX-Umfang des Projekts.
- [ ] `LoggingPermission` — analog zu `PropertyPermission` oben, hängt an
  `SecurityManager`-Unterstützung. *Abhängig von:* Klärung `java.security`-
  Umfang.

## Java 5 (java.util.spi)

- [ ] `java.util.spi`-Interfaces (`CalendarDataProvider`,
  `CalendarNameProvider`, `CurrencyNameProvider`, `LocaleNameProvider`,
  `LocaleServiceProvider`, `TimeZoneNameProvider`, `ResourceBundleControlProvider`,
  `ResourceBundleProvider`) — laut Vorab-Audit „praktisch nicht vorhanden",
  nur die interne `_DynamicLoader.swift` (kein öffentliches SPI-API).
  Da `ServiceLoader` selbst bereits implementiert und getestet ist, aber
  die konkreten `*.spi`-Provider-Interfaces zur Lokalisierung fehlen,
  sollten diese als eigene, kleine Protokoll-Familie ergänzt werden (analog
  zum bereits etablierten Muster „Protokoll + Default-Extension").
  *Abhängig von:* vorhandenem `ServiceLoader` (bereits implementiert),
  `Locale`/`Calendar`/`Currency`/`TimeZone` (bereits implementiert).

## Java 1.0 (Sammelpunkt: `EventListenerProxy`, `TooManyListenersException`)

- [ ] `EventListenerProxy` — abstrakte Basisklasse für Proxy-Listener,
  Java 1.4 tatsächlich (nicht 1.0 — hier korrekt referenziert unter Java
  1.4). *Abhängig von:* vorhandenem `EventListener` (bereits
  implementiert).
- [ ] `TooManyListenersException` — Java 1.1 (nicht 1.0 — Korrektur:
  eingeführt mit dem `java.util`-Event-Modell in Java 1.1). *Abhängig
  von:* nichts.
- [ ] `InvalidPropertiesFormatException` — Java 5 (nicht 1.0 — Korrektur:
  eingeführt zusammen mit `Properties.loadFromXML`/`storeToXML` in Java 5).
  *Abhängig von:* vorhandenem `Properties` (bereits implementiert).

## Plattform-/Concurrency-Abhängigkeiten (Querschnittsthema)

`java.util.concurrent` ist mit Abstand der größte offene Block dieses
Dokuments und betrifft alle Zielplattformen des Projekts (Apple, Linux X11
MUSL/GLibc, Windows GDI, FreeBSD, Android, WASM) gemeinsam — daher hier
gebündelt statt pro Java-Version wiederholt:

- **Grundfrage:** Worauf wird die Nebenläufigkeits-Grundlage von
  `java.util.concurrent` (Executor-Framework, `BlockingQueue`, `.atomic`,
  `.locks`) unter Swift 6.3 aufgesetzt?
  - **Option A — Swift Concurrency** (`Task`, `actor`, `AsyncSequence`,
    Cooperative Thread Pool): idiomatisch, aber Javas `Thread`-basiertes
    Modell (klassische `ExecutorService.submit`, blockierendes
    `BlockingQueue.take()`, `Thread.join()`) passt semantisch nicht 1:1 —
    Java-APIs sind synchron/blockierend, Swift Concurrency ist
    `async`/kooperativ. Eine 1:1-Portierung von `BlockingQueue.put/take`
    z. B. würde den kooperativen Thread-Pool blockieren, wenn nicht via
    `Task { }`/Continuation sauber entkoppelt.
  - **Option B — `DispatchQueue`/Foundation-Threading** (Apple nativ, unter
    Linux über `swift-corelibs-libdispatch`/`Foundation`): näher am
    Java-Blockierungsmodell, aber Verfügbarkeit unter WASM und ggf.
    eingeschränkten Embedded-/Android-Toolchains unklar.
  - **Option C — eigene Thread-Primitive** (`pthread`/`Foundation.Thread`
    + `NSLock`/`NSCondition`): plattformunabhängigster, aber
    implementierungsaufwendigster Weg; nötig überall dort, wo weder
    Swift Concurrency noch `DispatchQueue` verfügbar sind.
  - **WASM-Sonderfall:** im Browser-Kontext ohne Web Workers gibt es
    **keine echten Threads** — `Thread`/`ExecutorService`/`BlockingQueue`
    lassen sich dort nicht sinnvoll blockierend implementieren. Empfehlung
    analog zum in `Text-Implementierung.md` etablierten Muster für
    ICU-lose Plattformen: API-Oberfläche bereitstellen, Implementierung
    hinter `#if canImport(...)`/Plattform-Guards mit klarem Stub
    (`preconditionFailure` gemäß `Java2Swift.md`-Konvention) statt
    stiller Fehlsemantik.
  - **`java.util.concurrent.atomic`:** hier bietet sich am ehesten die
    Swift-Package `swift-atomics` (falls bereits Projektabhängigkeit oder
    vertretbar als neue) oder ein `NSLock`-Fallback an — echte
    Lock-freie Atomics ohne Plattform-Intrinsics sind in reinem Swift
    ohne Zusatzpaket nicht darstellbar.
  - **`java.util.concurrent.locks` (`AbstractQueuedSynchronizer` u. a.):**
    dies ist die mit Abstand aufwendigste Einzelkomponente — JDK-intern
    die Basis für `ReentrantLock`, `Semaphore`, `CountDownLatch` u. v. m.
    Eine vollständige Nachbildung in Swift ist vermutlich nicht
    wirtschaftlich; realistischer ist, die *öffentlichen* Endtypen
    (`ReentrantLock`, `CountDownLatch`, `Semaphore`, …) direkt auf
    `NSLock`/`NSCondition`/`DispatchSemaphore` zu implementieren, ohne
    `AbstractQueuedSynchronizer` selbst nachzubauen (Empfehlung).
  - **Empfehlung:** Vor Beginn der `concurrent`-Implementierung einen
    kurzen Machbarkeits-Spike durchführen, der für jede Zielplattform
    dokumentiert, welche der drei Optionen (A/B/C) zum Einsatz kommt, und
    dies analog zur bestehenden MUSL/X11-Guard-Praxis aus dem
    Projekt-Memory (`project_open_issues.md`, dort insbesondere die
    MUSL-Guards für X11/CoreFoundation-abhängigen Code) als
    Plattform-Guard-Matrix festhalten, **bevor** einzelne
    `concurrent`-Klassen aus dem Java-5-Abschnitt oben umgesetzt werden.
- **Ebenfalls betroffen (sekundär):** `Timer`/`TimerTask` (bereits
  vorhanden, `Sources/JavApi/util/Timer.swift`) sollte daraufhin geprüft
  werden, welches der obigen Concurrency-Modelle es aktuell nutzt, damit
  neue `concurrent`-Typen (insbesondere `ScheduledExecutorService`)
  konsistent auf derselben Grundlage aufsetzen statt eine zweite,
  inkompatible Nebenläufigkeits-Strategie einzuführen.

## Swift-6.3-Concurrency-Hinweis

- Alle in diesem Dokument aufgeführten `java.util.concurrent`-Typen
  (Executor-Framework, `ConcurrentHashMap` & Co., `BlockingQueue`-Familie,
  `.atomic`, `.locks`) sind per Definition mehrfädig nutzbar und müssen
  daher von Beginn an mit expliziter `Sendable`-Konformität entworfen
  werden — nicht nachträglich angeflanscht wie es laut Vorab-Audit bei
  `StringBuilder` in `Text-Implementierung.md` der Fall war. Referenztypen
  mit mutablem internen Zustand (z. B. eine künftige
  `ConcurrentHashMap`-Implementierung) sollten entweder als `actor`
  modelliert werden (mit den sich daraus ergebenden `async`-Zugriffs-
  methoden, die von Javas synchronen API-Signaturen abweichen — API-
  Kompatibilität vs. Idiomatik hier bewusst abwägen) oder mit
  `@unchecked Sendable` plus internem Lock (`NSLock`) analog zum
  bestehenden `StringBuffer`-Muster.
- `HashMap`, `ArrayList`, `LinkedList` und die übrigen bereits vorhandenen
  Kern-Collections sind **nicht** thread-sicher (wie in Java auch nicht,
  abgesehen von `Hashtable`/`Vector`/synchronisierten Wrappern über
  `Collections.synchronizedMap(...)` etc.) und daher aktuell nicht
  `Sendable`. Sobald `ConcurrentModificationException`-Fail-Fast-Checks
  (siehe Priority-Abschnitt) ergänzt werden, sollte gleichzeitig geprüft
  werden, ob ein `modCount`-Feld unter Nebenläufigkeit selbst zu Data
  Races führen kann (reiner `Int`-Zähler ohne Synchronisation ist in
  Swift Concurrency strikt genommen ebenfalls ein Race, wenn auch in
  Java historisch toleriert) — ggf. `@unchecked Sendable`-Dokumentation
  ergänzen, die explizit macht, dass gleichzeitige Iteration + Mutation
  aus mehreren Threads weiterhin undefiniert bleibt (Java-Parität), nur
  die *Erkennung* im Single-Thread-Fall verbessert wird.
- **`java.util.random` (`RandomGenerator`):** bereits vorhandene
  Implementierung auf `Sendable`-Tauglichkeit prüfen, falls
  `RandomGenerator`-Instanzen künftig aus `ForkJoinPool`/parallelen
  Streams heraus verwendet werden sollen (Java erlaubt das für bestimmte
  `SplittableGenerator`-Implementierungen explizit über `splits()`).
