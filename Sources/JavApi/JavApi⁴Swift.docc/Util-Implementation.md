# java.util – Implementierungs-Arbeitsplan

> **Hinweis:** Dieses Dokument ist eine reine Aufgabenübersicht und enthält ausschließlich offene bzw. noch ausstehende Punkte. Vollständig implementierte Typen und Methoden werden hier **nicht** aufgeführt. Es ist kein Erledigungsprotokoll.

Temporäres Arbeitsdokument zur schrittweisen Schließung der API-Lücken in `java.util`.
Priorisierung: Java 1.0 → 1.1 → 1.2 → 1.4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 16 → 17 → 21 -> 26.

Legende: `[ ]` offen · `[-]` bewusst ausgelassen

---

## P2 – Java 1.1 Kompatibilität

### `Calendar`

- [ ] `static getInstance(_ zone: TimeZone, _ locale: Locale) -> Calendar`
- [ ] `toInstant()` (Java 8)

### `GregorianCalendar`

- [ ] `toZonedDateTime()` (Java 8)

### `Locale`

## P3 – Java 1.2 Kompatibilität

### `Collections` – Implementierungsstand

Java 1.2:
- [ ] `static singleton<T>(_ o: T) -> Set<T>`
- [ ] `static singletonMap<K, V>(_ key: K, _ value: V) -> Map<K, V>`
- [ ] `static enumeration<T>(_ c: Collection<T>) -> Enumeration<T>`
- [ ] `static list<T>(_ e: Enumeration<T>) -> ArrayList<T>`
- [ ] `static unmodifiableSet/SortedSet/Map/SortedMap` (reine Varianten ohne Sequenced)
- [ ] `static synchronizedSet/SortedSet/Map/SortedMap` (reine Varianten ohne Sequenced)

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
- Java 8 (offen): [ ] `compute`, `computeIfPresent`, `merge`

### `Arrays`

- [ ] `deepEquals(_ a1: [Any?], _ a2: [Any?]) -> Bool` (Java 5)
- [ ] `deepHashCode(_ a: [Any?]) -> Int` (Java 5)
- [ ] `hashCode` für primitive Typen `[Int]`, `[Bool]` etc. (Java 5)
- Java 8: [ ] `parallelSort`, `setAll`, `parallelSetAll`, `parallelPrefix`

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

---

## Java 8

### `java.util.stream` — Implementierungsstand

Noch offen:
- [ ] `Collectors`: `partitioningBy`, `toUnmodifiable*` (Java 10), `teeing` (Java 12)
- [ ] `gather<R>(_ gatherer:)` (Java 24, finalisiert)
- [ ] `Gatherer<T, A, R>` + `Gatherers` Utility-Klasse (Java 24)

---

## Java 9

### `List`, `Set`, `Map` – immutable Factory-Methoden
- [ ] `List.of(…)` (leer + bis 10 Elemente + vararg) — null-feindlich, unveränderlich
- [ ] `Set.of(…)` — zusätzlich: `IllegalArgumentException` bei Duplikaten
- [ ] `Map.of(…)` (bis 10 Paare) + `Map.entry(_:_:)` + `Map.ofEntries(…)`

### `Optional<T>` – Java 9
- [ ] `or(_ supplier: () -> Optional<T>)` — gibt `self` zurück wenn present, sonst Ergebnis des Suppliers
- [ ] `ifPresentOrElse(_ action: (T) -> Void, _ emptyAction: () -> Void)`

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
| Stream `parallel()` | Als No-Op implementiert; `AsyncSequence`-Integration out of scope |
| `java.util.spi.*` | SPI-Layer, kein direkter Portierungsbedarf |
| `LazyConstant<V>` / `List.of(size:generator:)` | JEP 526 noch Preview in Java 26 |

---

## Testabdeckungs-Lücken (keine neue Implementierung nötig)

| Typ | Ist | Bedarf | Anmerkung |
|-----|-----|--------|-----------|
| `ServiceLoader` | 0 | ≥ 5 | Implementiert, keine Tests |
| `UUID` | 3 | ≥ 15 | |
| `Enumeration` | 3 | ≥ 5 | |
| `TimeZone` | 8 | ≥ 12 | |
| `SimpleTimeZone` | 5 | ≥ 10 | |
| `Random` | 12 | ≥ 20 | |
| `Base64` | 13 | ≥ 20 | |
| `WeakHashMap` | 0 | ≥ 8 | Implementiert, keine Tests |
| `Currency` | 0 | ≥ 5 | Implementiert, keine Tests |

---

*Stand: 2026-08-10 · Basis: Java 1.0–26 public API
