# java.util – Implementierungs-Arbeitsplan

Temporäres Arbeitsdokument zur schrittweisen Schließung der API-Lücken in `java.util`.
Priorisierung: Java 1.0 → 1.1 → 1.2 → 1.4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 16 → 17 → 21.

Legende: `[ ]` offen · `[-]` bewusst ausgelassen

---

## P0 – Vorhandene Interfaces: Signaturlücken

> **Legende:** `⚠️` = referenziert noch nicht bereitgestellten Typ · `🔧` = Signatur abweichend von Java-API

| Interface | Fehlende Methoden / Probleme |
|-----------|------------------------------|
| `Collection<E>` | `stream()` ⚠️ `Stream<E>` fehlt · `spliterator()` ⚠️ `Spliterator<E>` fehlt · `forEach()` ⚠️ `Consumer<E>` fehlt |
| `Comparator<T>` | `comparing(keyExtractor)` ⚠️ `Function<T,R>` · `thenComparing(keyExtractor)` ⚠️ · `comparingInt/Long/Double()` ⚠️ |
| `Iterator<E>` | `forEachRemaining()` ⚠️ `Consumer<E>` fehlt |
| `List<E>` | `sort()` · `replaceAll()` ⚠️ `UnaryOperator<E>` fehlt |
| `Map<K,V>` | `forEach()` ⚠️ `BiConsumer` · `replaceAll()` ⚠️ `BiFunction` · `computeIfAbsent()` ⚠️ `Function` |

---

## P0 – Fehlende java.util.function-Interfaces (Java 8)

| Interface | Signatur | Benötigt |
|-----------|----------|----------|
| [ ] `Predicate<T>` | `test(_ t: T) -> Bool` + `and/or/negate()` | — |
| [ ] `Function<T,R>` | `apply(_ t: T) -> R` + `andThen/compose()` | — |
| [ ] `Consumer<T>` | `accept(_ t: T)` + `andThen()` | — |
| [ ] `BiConsumer<T,U>` | `accept(_ t: T, _ u: U)` + `andThen()` | — |
| [ ] `BiFunction<T,U,R>` | `apply(_ t: T, _ u: U) -> R` + `andThen()` | — |
| [ ] `UnaryOperator<T>` | extends `Function<T,T>` + `identity()` | `Function<T,T>` |
| [ ] `BinaryOperator<T>` | extends `BiFunction<T,T,T>` + `minBy/maxBy()` | `BiFunction` + `Comparator` |
| [ ] `BooleanSupplier` | `getAsBoolean() -> Bool` | — |
| [ ] `IntConsumer` / `LongConsumer` / `DoubleConsumer` | Spezialisierungen | — |
| [ ] `IntPredicate` / `LongPredicate` / `DoublePredicate` | Spezialisierungen | — |

> Priorität: `Predicate`, `Function`, `Consumer`, `BiConsumer`, `BiFunction` — werden von Java-8-Methoden in `Collection`, `Map`, `Iterator` direkt benötigt.

---

## P0 – Fehlende java.util.concurrent-Interfaces

| Interface | Seit | Problem |
|-----------|------|---------|
| [ ] `Callable<V>` | 5 | — |
| [ ] `Future<V>` | 5 | `ExecutionException` fehlt ⚠️ |

---


## P1 – Java 1.0 Kompatibilität

### `Date`
- [ ] `getTime() -> Int64`
- [ ] `setTime(_ time: Int64)`
- [ ] `before(_ when: Date) -> Bool`
- [ ] `after(_ when: Date) -> Bool`
- [ ] `clone() -> Date`
- [ ] `getYear()`, `setYear()`, `getMonth()`, `setMonth()`, `getDate()`, `setDate()` (deprecated, aber public API)
- [ ] `getDay()`, `getHours()`, `setHours()`, `getMinutes()`, `setMinutes()`, `getSeconds()`, `setSeconds()`
- [ ] `toLocaleString() -> String`, `toGMTString() -> String`

**Tests:** 43 vorhanden, decken `getTime`/`setTime`, `before`/`after`, `clone` nicht ab.

### `Vector`
- [ ] `clone() -> Vector<E>`
- [ ] `containsAll(_ c: Collection) -> Bool`
- [ ] `addAll(_ c: Collection<E>) -> Bool`
- [ ] `addAll(_ index: Int, _ c: Collection<E>) -> Bool`
- [ ] `removeAll(_ c: Collection) -> Bool`
- [ ] `retainAll(_ c: Collection) -> Bool`
- [ ] `indexOf(_ elem: E, _ index: Int) -> Int`
- [ ] `lastIndexOf(_ elem: E, _ index: Int) -> Int`

### `Hashtable`
- [ ] `putAll(_ t: Map<K, V>)`
- [ ] `equals(_ o: Any?) -> Bool`
- [ ] `hashCode() -> Int`
- [ ] `entrySet()` als `Set<Map.Entry>`
- [ ] `values()` als `any java.util.Collection<V>` — `Hashtable` konformiert noch nicht zu `java.util.Map`

**Tests:** 26 vorhanden.

### `Properties`

Vorhanden: `getProperty`, `getProperty(default)`, `setProperty`, `propertyNames`, `load(InputStream)`, `store(OutputStream, String?)`, `save` (deprecated), `list(PrintStream)`, `list(PrintWriter)`, `stringPropertyNames()`, `loadFromXML(InputStream)`, `storeToXML(OutputStream, String?)`, `storeToXML(OutputStream, String?, String)`.

- [x] Tests für alle vorhandenen Methoden (`getProperty`, `setProperty`, `propertyNames`, `load`, `store`, `save`, `list`)
- [x] `list(_ out: PrintWriter)`
- [x] `loadFromXML(_ in: InputStream)` — Java 5
- [x] `storeToXML(_ os: OutputStream, _ comment: String?)` — Java 5
- [x] `stringPropertyNames() -> Set<String>` — Java 6

**Tests:** 21 vorhanden.

### `BitSet`

Vorhanden: `set(int)`, `clear(int)`, `get(int)`, `and`, `or`, `xor`, `size`, `clone`, `equals`, `hashCode`, `toString`. 28 Tests.

- [ ] `andNot(_ set: BitSet)` (Java 1.2)
- [ ] `length() -> Int` (Java 1.4)
- [ ] `isEmpty() -> Bool` (Java 1.4)
- [ ] `cardinality() -> Int` (Java 1.4)
- [ ] `intersects(_ set: BitSet) -> Bool` (Java 1.4)
- [ ] `flip(_ bitIndex: Int)`, `flip(_ from: Int, _ to: Int)` (Java 1.4)
- [ ] `set(_ bitIndex: Int, _ value: Bool)`, `set(_ from: Int, _ to: Int)`, `set(_ from: Int, _ to: Int, _ value: Bool)` (Java 1.4)
- [ ] `clear(_ from: Int, _ to: Int)` (Java 1.4)
- [ ] `get(_ from: Int, _ to: Int) -> BitSet` (Java 1.4)
- [ ] `nextSetBit(_ from: Int) -> Int` (Java 1.4)
- [ ] `nextClearBit(_ from: Int) -> Int` (Java 1.4)
- [ ] `previousSetBit(_ from: Int) -> Int` (Java 7)
- [ ] `previousClearBit(_ from: Int) -> Int` (Java 7)
- [ ] `toLongArray() -> [Int64]` (Java 7)
- [ ] `toByteArray() -> [UInt8]` (Java 7)
- [ ] `static valueOf(_ bytes: [UInt8]) -> BitSet` (Java 7)
- [ ] `static valueOf(_ longs: [Int64]) -> BitSet` (Java 7)

---

## P2 – Java 1.1 Kompatibilität

### `Calendar`

Vorhanden: alle Konstanten, `getInstance()`, `get(int)`, `set(int, int)`, `setTime(Date)`, `getTime()`. 23 Tests.

- [ ] `add(_ field: Int, _ amount: Int)` ← höchste Priorität
- [ ] `roll(_ field: Int, _ up: Bool)`, `roll(_ field: Int, _ amount: Int)`
- [ ] `before(_ when: Any?) -> Bool`, `after(_ when: Any?) -> Bool`
- [ ] `compareTo(_ anotherCalendar: Calendar) -> Int` (Java 5)
- [ ] `clone() -> Calendar`
- [ ] `isSet(_ field: Int) -> Bool`
- [ ] `clear()`, `clear(_ field: Int)`
- [ ] `getTimeInMillis() -> Int64`, `setTimeInMillis(_ millis: Int64)` (Java 1.2)
- [ ] `getActualMinimum(_ field: Int) -> Int`, `getActualMaximum(_ field: Int) -> Int` (Java 1.2)
- [ ] `getMinimum(_ field: Int) -> Int`, `getMaximum(_ field: Int) -> Int`
- [ ] `getGreatestMinimum(_ field: Int) -> Int`, `getLeastMaximum(_ field: Int) -> Int`
- [ ] `getTimeZone() -> TimeZone`, `setTimeZone(_ value: TimeZone)`
- [ ] `getFirstDayOfWeek() -> Int`, `setFirstDayOfWeek(_ value: Int)`
- [ ] `isLenient() -> Bool`, `setLenient(_ lenient: Bool)`
- [ ] `getMinimalDaysInFirstWeek() -> Int`, `setMinimalDaysInFirstWeek(_ value: Int)`
- [ ] `static getInstance(_ zone: TimeZone) -> Calendar`
- [ ] `static getInstance(_ zone: TimeZone, _ locale: Locale) -> Calendar`
- [ ] `static getAvailableLocales() -> [Locale]`
- [ ] `toInstant()` (Java 8)

### `GregorianCalendar`

**Tests:** 0 vorhanden.

- [ ] Tests für alle Konstruktoren schreiben
- [ ] `BC = 0`, `AD = 1` Konstanten
- [ ] `isLeapYear(_ year: Int) -> Bool`
- [ ] `getGregorianChange() -> Date`, `setGregorianChange(_ date: Date)`
- [ ] Konstruktoren: `(TimeZone)`, `(Locale)`, `(TimeZone, Locale)`
- [ ] Alle `Calendar`-Methoden von oben implementieren
- [ ] `toZonedDateTime()` (Java 8)

### `Locale`

Vorhanden: Sprachkonstanten (ENGLISH…KOREAN, CHINESE), Länderkonstanten, `getDefault()`, `setDefault()`, `getCountry()`, `getLanguage()`. 18 Tests.

- [ ] `SIMPLIFIED_CHINESE`, `TRADITIONAL_CHINESE`, `PRC`, `TAIWAN`, `ROOT` (Java 6)
- [ ] `getVariant() -> String`
- [ ] `toString() -> String` (format: language_COUNTRY_variant)
- [ ] `getDisplayLanguage() -> String` (und `(_ inLocale:)`)
- [ ] `getDisplayCountry() -> String` (und `(_ inLocale:)`)
- [ ] `getDisplayVariant() -> String` (und `(_ inLocale:)`)
- [ ] `getDisplayName() -> String` (und `(_ inLocale:)`)
- [ ] `getISO3Country() -> String`, `getISO3Language() -> String`
- [ ] `static getAvailableLocales() -> [Locale]`
- [ ] `static getISOCountries() -> [String]`, `static getISOLanguages() -> [String]`
- [ ] `getScript() -> String`, `toLanguageTag() -> String`, `static forLanguageTag(_:) -> Locale` (Java 7)
- [ ] `Locale.Builder`, `Locale.Category` (Java 7)

---

## P3 – Java 1.2 Kompatibilität

### `Comparator<T>`
- [ ] `comparing(keyExtractor)`, `thenComparing(keyExtractor)`, `comparingInt/Long/Double()` ⚠️ benötigt `Function<T,R>`

### `Collections` – fehlende Methoden

Java 1.2:
- [ ] `static singleton<T>(_ o: T) -> Set<T>`
- [ ] `static singletonMap<K, V>(_ key: K, _ value: V) -> Map<K, V>`
- [ ] `static enumeration<T>(_ c: Collection<T>) -> Enumeration<T>`
- [ ] `static list<T>(_ e: Enumeration<T>) -> ArrayList<T>`
- [ ] `static unmodifiableCollection/Set/SortedSet/Map/SortedMap`
- [ ] `static synchronizedCollection/Set/SortedSet/Map/SortedMap`


Java 5:
- [ ] `static checked*` (checkedCollection, checkedList, checkedSet, …)

Java 7:
- [ ] `static emptyIterator<T>() -> Iterator<T>`
- [ ] `static emptyListIterator<T>() -> ListIterator<T>`
- [ ] `static emptyEnumeration<T>() -> Enumeration<T>`

Java 8:
- [ ] `static unmodifiableNavigableMap/NavigableSet`
- [ ] `static checkedNavigableMap/NavigableSet/Queue`
- [ ] `static emptyNavigableMap/NavigableSet`


### `HashMap`

- [ ] `HashMap(_ map: Map<K, V>)` Copy-Konstruktor
- [ ] `clone() -> HashMap<K, V>`
- Java 8 (offen): [ ] `compute`, `computeIfAbsent`, `computeIfPresent`, `merge`, `forEach`, `replaceAll`

### `Arrays`

- [ ] `deepEquals(_ a1: [Any?], _ a2: [Any?]) -> Bool` (Java 5)
- [ ] `deepHashCode(_ a: [Any?]) -> Int` (Java 5)
- [ ] `hashCode` für primitive Typen `[Int]`, `[Bool]` etc. (Java 5)
- Java 8: [ ] `parallelSort`, `setAll`, `parallelSetAll`, `parallelPrefix`

---

## P4 – Ergänzungen

### `Map.Entry<K,V>` – noch offen
- [ ] `Map.Entry.comparingByKey() -> Comparator` (Java 8)
- [ ] `Map.Entry.comparingByValue() -> Comparator` (Java 8)
- [ ] `HashMap`, `TreeMap` auf `entrySet() -> Set<MapEntry<K,V>>` umstellen (aktuell nur LinkedHashMap vollständig)

### `LinkedHashMap` – Testabdeckung und LRU-Support

- [ ] Tests auf ≥ 15 erweitern (Einfügungsreihenfolge, Iterationsreihenfolge, putFirst/putLast)
- [ ] `LinkedHashMap(_ initialCapacity: Int, _ loadFactor: Float, _ accessOrder: Bool)` Konstruktor
- [ ] `removeEldestEntry(_ eldest: Map.Entry<K, V>) -> Bool` (protected, für LRU-Subklassen)

---

## Java 1.4 – Fehlende Typen

### `java.util.regex` (komplett fehlend)

- [ ] `PatternSyntaxException`
- [ ] `Pattern`: `compile`, `matcher`, `matches`, `split`, `pattern`, `flags` + Konstanten
- [ ] `Matcher`: `matches`, `find`, `group`, `start`, `end`, `groupCount`, `replaceAll`, `replaceFirst`, `reset`, `lookingAt`, `region`, `appendReplacement`, `appendTail`, `usePattern`
- [ ] Tests

---

## Java 5 – Restarbeiten

### `EnumMap<K, V>` (komplett fehlend)
- [ ] Implementierung (Swift-Enums als Key — Designfrage)
- [ ] Tests

### `EnumSet<E>` (komplett fehlend)
- [ ] Implementierung (Swift-Enums — Designfrage)
- [ ] Tests

### `Scanner` (komplett fehlend)
- [ ] Konstruktoren: `Scanner(InputStream)`, `Scanner(String)`, `Scanner(File)`
- [ ] `hasNext/next`, `hasNextLine/nextLine`, `hasNextInt/nextInt`, `hasNextLong/nextLong`, `hasNextDouble/nextDouble`, `hasNextBoolean/nextBoolean`
- [ ] `useDelimiter`, `useRadix`, `close`
- [ ] Tests

### `AbstractQueue<E>` (komplett fehlend)
- [ ] Abstrakte Basisklasse (`add`, `remove`, `element` als Wrapper um `offer`/`poll`/`peek`)
- [ ] Tests

### `UUID`

- [ ] `getLeastSignificantBits() -> Int64`
- [ ] `getMostSignificantBits() -> Int64`
- [ ] `version() -> Int`, `variant() -> Int`
- [ ] `timestamp() -> Int64`, `clockSequence() -> Int`, `node() -> Int64` (nur Version-1)
- [ ] `compareTo(_ val: UUID) -> Int`
- [ ] Tests

---

## Java 6 – Restarbeiten

### `ServiceLoader` (0 Tests)
- [ ] Tests schreiben

### `Timer` / `TimerTask` (0 Tests)
- [ ] Tests schreiben

---

## Java 8

### `Optional<T>` – Restarbeiten
- [ ] `stream() -> Stream<T>` (abhängig von Stream-Implementierung)

### `java.util.function` (nur `Supplier<T>` vorhanden)
- [ ] `Consumer<T>`, `BiConsumer<T, U>`
- [ ] `Function<T, R>` + `compose`, `andThen`, `identity`
- [ ] `BiFunction<T, U, R>` + `andThen`
- [ ] `Predicate<T>` + `and`, `or`, `negate`, `not`
- [ ] `BiPredicate<T, U>`
- [ ] `UnaryOperator<T>`, `BinaryOperator<T>`
- [ ] Primitive Varianten: `IntSupplier`, `LongSupplier`, `DoubleSupplier`, `BooleanSupplier`
- [ ] `IntConsumer`, `LongConsumer`, `DoubleConsumer`
- [ ] `IntFunction<R>`, `LongFunction<R>`, `DoubleFunction<R>`
- [ ] `IntUnaryOperator`, `LongUnaryOperator`, `DoubleUnaryOperator`
- [ ] `IntBinaryOperator`, `LongBinaryOperator`, `DoubleBinaryOperator`
- [ ] `IntPredicate`, `LongPredicate`, `DoublePredicate`
- [ ] `ToIntFunction<T>`, `ToLongFunction<T>`, `ToDoubleFunction<T>`
- [ ] Tests

### `StringJoiner` (komplett fehlend)
- [ ] `StringJoiner(_ delimiter: String)` und `(_, prefix:, suffix:)`
- [ ] `add`, `merge`, `setEmptyValue`, `length`, `toString`
- [ ] Tests

### `Spliterator<T>` (komplett fehlend)
- [ ] Protocol mit `tryAdvance`, `forEachRemaining`, `trySplit`, `estimateSize`, `characteristics`
- [ ] Konstanten: `ORDERED`, `DISTINCT`, `SORTED`, `SIZED`, `NONNULL`, `IMMUTABLE`, `CONCURRENT`, `SUBSIZED`

### `java.util.stream` (komplett fehlend)

Architektur-Entscheidungen (festgelegt):
- `Stream<T>` als class-Wrapper über `AnySequence<T>`/`LazySequence`
- Intermediate ops delegieren an Swift `lazy`-Ketten
- `collect(Collector)` mit `Collector<T, A, R>`-Protocol
- Primitive Streams: `Stream<Int>`, `Stream<Int64>`, `Stream<Double>` (kein Separattyp nötig)
- `stream.parallel()`: No-Op oder Swift `AsyncSequence` / `withTaskGroup` (noch offen ⚠️)
- `Stream.generate()` / `iterate()` via Swift `sequence(state:next:)`

Aufgaben:
- [ ] `Stream<T>` Klasse
- [ ] Intermediate ops: `filter`, `map`, `flatMap`, `distinct`, `sorted`, `limit`, `skip`, `peek`
- [ ] Terminal ops: `forEach`, `count`, `reduce`, `findFirst`, `findAny`, `anyMatch`, `allMatch`, `noneMatch`, `min`, `max`, `toArray`, `toList` (Java 16)
- [ ] `collect(_ collector:)`
- [ ] `Collector<T, A, R>` Protocol
- [ ] `Collectors`: `toList`, `toSet`, `joining`, `groupingBy`, `counting`, `toMap`, `partitioningBy`, `toUnmodifiable*` (Java 10), `teeing` (Java 12)
- [ ] `Stream.of(…)`, `Stream.empty()`, `Stream.generate(_:)`, `Stream.iterate(_:_:)`
- [ ] `gather<R>(_ gatherer:)` (Java 24, finalisiert)
- [ ] `Gatherer<T, A, R>` + `Gatherers` Utility-Klasse (Java 24)

---

## Java 9

### `List`, `Set`, `Map` – immutable Factory-Methoden
- [ ] `List.of(…)` (leer + bis 10 Elemente + vararg) — null-feindlich, unveränderlich
- [ ] `Set.of(…)` — zusätzlich: `IllegalArgumentException` bei Duplikaten
- [ ] `Map.of(…)` (bis 10 Paare) + `Map.entry(_:_:)` + `Map.ofEntries(…)`

### `Optional<T>` – Java 9
- [ ] `stream() -> Stream<T>` (abhängig von Stream-Implementierung)

### `Objects` – Java 9
- [ ] `static requireNonNullElse<T>(_:_:) -> T`
- [ ] `static requireNonNullElseGet<T>(_:_:) -> T`
- [ ] `static checkIndex(_:_:) -> Int`
- [ ] `static checkFromToIndex(_:_:_:) -> Int`
- [ ] `static checkFromIndexSize(_:_:_:) -> Int`

### `ServiceLoader` – Java 9
- [ ] `findFirst() -> Optional<S>`
- [ ] `stream() -> Stream<ServiceLoader.Provider<S>>`
- [ ] `ServiceLoader.Provider<S>` innere Schnittstelle

### `Scanner` – Java 9
- [ ] `tokens() -> Stream<String>`
- [ ] `findAll(_ pattern:) -> Stream<MatchResult>`

---

## Java 10

### `List`, `Set`, `Map` – `copyOf(…)`
- [ ] `static copyOf<E>(_ coll: Collection<E>) -> List<E>` (unveränderlich, null-feindlich)
- [ ] `static copyOf<E: Hashable>(_ coll: Collection<E>) -> Set<E>`
- [ ] `static copyOf<K, V>(_ map: Map<K, V>) -> Map<K, V>`

---

## Java 16

### `Stream<T>` – Java 16
- [ ] `toList() -> List<T>`
- [ ] `mapMulti<R>(_ mapper: (T, (R) -> Void) -> Void) -> Stream<R>`

---

## Java 17 – `java.util.random` (komplett fehlend)

### `RandomGenerator` Interface
- [ ] `nextBoolean/Int/Long/Double/Float/Gaussian/Exponential` (alle Überladungen)
- [ ] `isDeprecated() -> Bool`, `static of(_ algorithmName:)`
- [ ] `ints()`, `longs()`, `doubles()` (Stream-Methoden)
- [ ] Sub-Interfaces: `SplittableGenerator`, `JumpableGenerator`, `LeapableGenerator`

### `RandomGeneratorFactory<T>`
- [ ] `static all()`, `static of(_ algorithmName:)`, `create()`, `name()`, `group()`, Eigenschaften

### `Random` – Retrofit (Java 17)
- [ ] `Random` um `RandomGenerator`-Protocol erweitern
- [ ] Neue Methoden mit `origin`/`bound`-Parametern ergänzen

---

## Java 22–24 – Stream Gatherers (finalisiert in Java 24)

### `Gatherer<T, A, R>` Interface
- [ ] `supplier`, `integrator`, `combiner`, `finisher`, `andThen`
- [ ] `static of(integrator:)`, `of(supplier:integrator:)`, `of(supplier:integrator:finisher:)`, `ofSequential(…)`

### `Gatherers` Utility-Klasse
- [ ] `fold`, `scan`, `mapConcurrent`, `windowFixed`, `windowSliding`

### `Stream<T>` – neue Methode
- [ ] `gather<R>(_ gatherer: Gatherer<T, ?, R>) -> Stream<R>`

---

## Java 25 – `java.util.concurrent.StructuredTaskScope` (finalisiert)

- [ ] `StructuredTaskScope<T>`: `fork`, `join`, `joinUntil`, `shutdown`, `close`, `isShutdown`, `handleComplete`
- [ ] `StructuredTaskScope.ShutdownOnFailure`: `exception()`, `throwIfFailed()`
- [ ] `StructuredTaskScope.ShutdownOnSuccess<T>`: `result()`
- [ ] `Subtask<T>`: `get()`, `exception()`, `state()`, `Subtask.State`

> **Swift-Hinweis:** Swift `async let` und `TaskGroup` decken die meisten Anwendungsfälle idiomatisch ab. Brücken-API nur bei tatsächlichem Portierungsbedarf.

---

## Derzeit Bewusst ausgelassen (`[-]`) mit Prüfung im Nachgang

| Feature | Begründung |
|---------|------------|
| `java.util.concurrent.ScopedValue<T>` | In `java.lang` finalisiert (Java 24), nicht `java.util` |
| `java.util.concurrent` Virtual Threads | Swift `Task {}` ist das idiomatische Äquivalent |
| Stream `parallel()` | Strategie noch offen (No-Op vs. `AsyncSequence`) |
| `java.util.spi.*` | SPI-Layer, kein direkter Portierungsbedarf |
| `LazyConstant<V>` / `List.of(size:generator:)` | JEP 526 noch Preview in Java 26 |

---

## Testabdeckungs-Lücken (keine neue Implementierung nötig)

| Typ | Ist | Bedarf |
|-----|-----|--------|
| `GregorianCalendar` | 0 | ≥ 10 |
| `Properties` | 21 | ≥ 15 | ✅ |
| `Timer` / `TimerTask` | 0 | ≥ 8 |
| `ServiceLoader` | 0 | ≥ 5 |
| `LinkedHashMap` | 4 | ≥ 15 |
| `UUID` | 3 | ≥ 15 |
| `Enumeration` | 1 | ≥ 5 |
| `TimeZone` | 8 | ≥ 12 |
| `SimpleTimeZone` | 5 | ≥ 10 |
| `Random` | 12 | ≥ 20 |
| `Base64` | 13 | ≥ 20 |

---

*Stand: 2026-08-09 · Basis: Java 1.1–26 public API*
