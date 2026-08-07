# java.util – Implementierungs-Arbeitsplan

Temporäres Arbeitsdokument zur schrittweisen Schließung der API-Lücken in `java.util`.
Priorisierung: Java 1.0 → 1.1 → 1.2 → 1.4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 16 → 17 → 21.

Legende: `[ ]` offen · `[x]` erledigt · `[-]` bewusst ausgelassen

---

## Priority-Tasks

Dieser Abschnitt fasst alle Aufgaben zusammen, die für eine vollständige Kompatibilität mit Java 1.0, 1.1 und 1.2 erforderlich sind. Diese haben Vorrang vor allen anderen Einträgen im Dokument.

---

### P0 – Interfaces und naive Konstanten

Interfaces haben minimale Seiteneffekte und können meist ohne Abhängigkeiten zu noch fehlenden konkreten Typen implementiert werden. Gleiches gilt für naive Konstanten (reine `static let`-Werte). Dieser Abschnitt beschreibt den Vollständigkeitsgrad der vorhandenen Interfaces und zeigt, welche noch fehlen.

> **Legende Probleme:** `⚠️` = Methodensignatur referenziert noch nicht bereitgestellten Typ · `🔧` = Signatur abweichend von Java-API

---

### Vorhandene java.util-Interfaces – Lücken und Signaturprobleme

| Interface | Seit | Status | Signaturprobleme / fehlende Methoden |
|-----------|------|--------|--------------------------------------|
| `Collection<E>` | 1.2 | ✓ vorhanden | `stream()` ⚠️ `Stream<E>` fehlt · `spliterator()` ⚠️ `Spliterator<E>` fehlt · `forEach()` ⚠️ `Consumer<E>` fehlt |
| `Comparator<T>` | 1.2 | ✓ vorhanden | ✅ `reversed()` · `thenComparing(comparator)` · `naturalOrder()` · `reverseOrder()` · `nullsFirst()` · `nullsLast()` implementiert · `comparing(keyExtractor)` fehlt ⚠️ `Function<T,R>` · `thenComparing(keyExtractor)` fehlt ⚠️ `Function<T,R>` · `comparingInt/Long/Double()` fehlt ⚠️ |
| `Deque<E>` | 6 | ✓ vorhanden | Vollständig |
| `Enumeration<E>` | 1.0 | ✓ vorhanden | ✅ `asIterator()` implementiert (Java 9, via `_EnumerationIterator`) |
| `EventListener` | 1.1 | ✓ vorhanden | Marker-Interface, vollständig |
| `Iterator<E>` | 1.2 | ✓ vorhanden | `forEachRemaining()` fehlt ⚠️ `Consumer<E>` fehlt |
| `List<E>` | 1.2 | ✓ vorhanden | `sort()` fehlt (Comparator ✓ OK) · `replaceAll()` fehlt ⚠️ `UnaryOperator<E>` fehlt |
| `ListIterator<E>` | 1.2 | ✓ vorhanden | Vollständig |
| `Map<K,V>` | 1.2 | ✓ vorhanden | ✅ `keySet()` gibt `any java.util.Set<K>` · `values()` gibt `[V]` statt `Collection<V>` 🔧 blockiert (siehe P0-Checklist) · `entrySet()` fehlt komplett ⚠️ `Map.Entry<K,V>` fehlt · Java-8: `forEach()` ⚠️ `BiConsumer` fehlt · `replaceAll()` ⚠️ `BiFunction` fehlt · `computeIfAbsent()` ⚠️ `Function` fehlt |
| `Observer` | 1.0 | ✓ vorhanden | Vollständig |
| `Queue<E>` | 5 | ✓ vorhanden | Vollständig |
| `Set<E>` | 1.2 | ✓ vorhanden | Vollständig (Marker-Protokoll) |
| `SortedMap<K,V>` | 1.2 | ✓ vorhanden | ✅ `comparator() -> (any Comparator<K>)?` implementiert |
| `SortedSet<E>` | 1.2 | ✓ vorhanden | ✅ `comparator() -> (any Comparator<E>)?` implementiert |

---

### Fehlende java.util-Interfaces

| Interface | Seit | Erweitert | Signatur-Abhängigkeiten | Problem? |
|-----------|------|-----------|------------------------|---------|
| `NavigableSet<E>` | 6 | `SortedSet<E>` ✓ | nur eigene Typen | — |
| `NavigableMap<K,V>` | 6 | `SortedMap<K,V>` ✓ | `Map.Entry<K,V>` in einigen Methoden | ⚠️ `Map.Entry` fehlt |
| `SequencedCollection<E>` | 21 | `Collection<E>` ✓ | nur eigene Typen | — |
| `SequencedSet<E>` | 21 | `SequencedCollection` + `Set` ✓ | nur eigene Typen | — |
| `SequencedMap<K,V>` | 21 | `Map<K,V>` ✓ | `Map.Entry<K,V>` | ⚠️ `Map.Entry` fehlt |

**Umsetzungsreihenfolge:**
- [ ] `NavigableSet<E>` — nur Typ-eigene Abhängigkeiten, sofort möglich
- [ ] `SequencedCollection<E>` — sofort möglich
- [ ] `SequencedSet<E>` — nach `SequencedCollection`
- [ ] `NavigableMap<K,V>` — Grundgerüst ohne `Map.Entry`-Methoden möglich; `pollFirstEntry()`/`pollLastEntry()` etc. erst nach `Map.Entry`
- [ ] `SequencedMap<K,V>` — Grundgerüst ohne `Map.Entry`-Methoden möglich

---

### Fehlende java.util.function-Interfaces (Java 8)

Alle ohne externe Typ-Abhängigkeiten — sofort implementierbar.

| Interface | Signatur | Benötigt |
|-----------|----------|----------|
| [ ] `Predicate<T>` | `test(_ t: T) -> Bool` + `and/or/negate()` | — |
| [ ] `Function<T,R>` | `apply(_ t: T) -> R` + `andThen/compose()` | — |
| [ ] `Consumer<T>` | `accept(_ t: T)` + `andThen()` | — |
| [ ] `BiConsumer<T,U>` | `accept(_ t: T, _ u: U)` + `andThen()` | — |
| [ ] `BiFunction<T,U,R>` | `apply(_ t: T, _ u: U) -> R` + `andThen()` | — |
| [ ] `UnaryOperator<T>` | extends `Function<T,T>` + `identity()` | `Function<T,T>` |
| [ ] `BinaryOperator<T>` | extends `BiFunction<T,T,T>` + `minBy/maxBy()` | `BiFunction` + `Comparator` ✓ |
| [ ] `Supplier<T>` | `get() -> T` | — (bereits vorhanden ✓) |
| [ ] `BooleanSupplier` | `getAsBoolean() -> Bool` | — |
| [ ] `IntConsumer` / `LongConsumer` / `DoubleConsumer` | Spezialisierungen | — |
| [ ] `IntPredicate` / `LongPredicate` / `DoublePredicate` | Spezialisierungen | — |

> `Supplier<T>` ist bereits in `java.util.function` vorhanden.
> Priorität: `Predicate`, `Function`, `Consumer`, `BiConsumer`, `BiFunction` — diese werden von Java-8-Methoden in `Collection`, `Map`, `Iterator` direkt benötigt.

---

### Fehlende java.util.concurrent-Interfaces (Auswahl)

| Interface | Seit | Signatur | Problem? |
|-----------|------|----------|---------|
| [ ] `Callable<V>` | 5 | `call() throws -> V` | — |
| [ ] `Future<V>` | 5 | `get()`, `isDone()`, `cancel()`, etc. | `ExecutionException` fehlt ⚠️ |

---

### Naive Konstanten

Reine `static let`-Konstanten ohne Typ-Abhängigkeiten — keine Implementierungsrisiken.

**`Collections` — fehlende Konstanten**
- [ ] `EMPTY_LIST` (`static let EMPTY_LIST: any java.util.List`) — benötigt leere List-Implementierung
- [ ] `EMPTY_SET` (`static let EMPTY_SET: any java.util.Set`) — benötigt leere Set-Implementierung
- [ ] `EMPTY_MAP` (`static let EMPTY_MAP: any java.util.Map`) — benötigt leere Map-Implementierung

> Diese drei sind nicht wirklich "naiv" — sie benötigen typisierte leere Wrapper. Besser als `nonisolated(unsafe) static let` mit leerer `ArrayList`/`HashSet`/`HashMap` realisieren.

---

## P1 – Java 1.0 Kompatibilität

#### `Date`
- [ ] `getTime() -> Int64`
- [ ] `setTime(_ time: Int64)`
- [ ] `before(_ when: Date) -> Bool`
- [ ] `after(_ when: Date) -> Bool`
- [ ] `clone() -> Date`
- [ ] `getYear()`, `setYear()`, `getMonth()`, `setMonth()`, `getDate()`, `setDate()` (deprecated, aber public API)
- [ ] `getDay()`, `getHours()`, `setHours()`, `getMinutes()`, `setMinutes()`, `getSeconds()`, `setSeconds()`
- [ ] `toLocaleString() -> String`, `toGMTString() -> String`

#### `Vector`
- [ ] `clone() -> Vector<E>`
- [ ] `containsAll(_ c: Collection) -> Bool`
- [ ] `addAll(_ c: Collection<E>) -> Bool`
- [ ] `addAll(_ index: Int, _ c: Collection<E>) -> Bool`
- [ ] `removeAll(_ c: Collection) -> Bool`
- [ ] `retainAll(_ c: Collection) -> Bool`
- [ ] `indexOf(_ elem: E, _ index: Int) -> Int`
- [ ] `lastIndexOf(_ elem: E, _ index: Int) -> Int`

#### `Stack`
- [ ] `search(_ o: Any?) -> Int` (1-basiert, von oben)

#### `Hashtable`
- [ ] `putAll(_ t: Map<K, V>)`
- [ ] `equals(_ o: Any?) -> Bool`
- [ ] `hashCode() -> Int`
- [ ] `entrySet()` als `Set`-äquivalent
- [ ] `keySet()` als `Set<K>` (zusätzlich zu `keys()` als Enumeration)
- [ ] `values()` als `Collection<V>`

#### `Properties` (0 Tests — zuerst Tests, dann Lücken schließen)
- [ ] Tests für alle vorhandenen Methoden
- [ ] `list(_ out: PrintWriter)`

#### `BitSet`
- [ ] `andNot(_ set: BitSet)` (Java 1.2, hier vorgezogen)
- [ ] `length() -> Int`
- [ ] `isEmpty() -> Bool`
- [ ] `cardinality() -> Int`
- [ ] `intersects(_ set: BitSet) -> Bool`
- [ ] `flip(_ bitIndex: Int)`, `flip(_ from: Int, _ to: Int)`
- [ ] `set(_ bitIndex: Int, _ value: Bool)`, `set(_ from: Int, _ to: Int)`, `set(_ from: Int, _ to: Int, _ value: Bool)`
- [ ] `clear(_ from: Int, _ to: Int)`
- [ ] `get(_ from: Int, _ to: Int) -> BitSet`
- [ ] `nextSetBit(_ from: Int) -> Int`
- [ ] `nextClearBit(_ from: Int) -> Int`

---

### P2 – Java 1.1 Kompatibilität

#### `Calendar`
- [ ] `add(_ field: Int, _ amount: Int)` ← höchste Priorität
- [ ] `roll(_ field: Int, _ up: Bool)`, `roll(_ field: Int, _ amount: Int)`
- [ ] `before(_ when: Any?) -> Bool`, `after(_ when: Any?) -> Bool`
- [ ] `clone() -> Calendar`
- [ ] `isSet(_ field: Int) -> Bool`
- [ ] `clear()`, `clear(_ field: Int)`
- [ ] `getTimeInMillis() -> Int64`, `setTimeInMillis(_ millis: Int64)`
- [ ] `getActualMinimum(_ field: Int) -> Int`, `getActualMaximum(_ field: Int) -> Int`
- [ ] `getMinimum(_ field: Int) -> Int`, `getMaximum(_ field: Int) -> Int`
- [ ] `getGreatestMinimum(_ field: Int) -> Int`, `getLeastMaximum(_ field: Int) -> Int`
- [ ] `getTimeZone() -> TimeZone`, `setTimeZone(_ value: TimeZone)`
- [ ] `getFirstDayOfWeek() -> Int`, `setFirstDayOfWeek(_ value: Int)`
- [ ] `isLenient() -> Bool`, `setLenient(_ lenient: Bool)`
- [ ] `getMinimalDaysInFirstWeek() -> Int`, `setMinimalDaysInFirstWeek(_ value: Int)`
- [ ] `getInstance(_ zone: TimeZone) -> Calendar`
- [ ] `getInstance(_ zone: TimeZone, _ locale: Locale) -> Calendar`
- [ ] `getAvailableLocales() -> [Locale]`

#### `GregorianCalendar` (0 Tests)
- [ ] Tests für vorhandene Konstruktoren
- [ ] Konstanten `BC = 0`, `AD = 1`
- [ ] `isLeapYear(_ year: Int) -> Bool`
- [ ] `getGregorianChange() -> Date`, `setGregorianChange(_ date: Date)`
- [ ] Konstruktoren: `(TimeZone)`, `(Locale)`, `(TimeZone, Locale)`
- [ ] Alle `Calendar`-Methoden von P2 oben implementieren

#### `Locale`
- [ ] Konstanten `SIMPLIFIED_CHINESE`, `TRADITIONAL_CHINESE`, `PRC`, `TAIWAN`
- [ ] `getVariant() -> String`
- [ ] `toString() -> String`
- [ ] `getDisplayLanguage() -> String`, `getDisplayLanguage(_ inLocale: Locale) -> String`
- [ ] `getDisplayCountry() -> String`, `getDisplayCountry(_ inLocale: Locale) -> String`
- [ ] `getDisplayVariant() -> String`, `getDisplayVariant(_ inLocale: Locale) -> String`
- [ ] `getDisplayName() -> String`, `getDisplayName(_ inLocale: Locale) -> String`
- [ ] `getISO3Country() -> String`, `getISO3Language() -> String`
- [ ] `getAvailableLocales() -> [Locale]`
- [ ] `getISOCountries() -> [String]`, `getISOLanguages() -> [String]`

---

### P3 – Java 1.2 Kompatibilität (Collections Framework)

Java 1.2 führte das Collections Framework ein. Ziel ist eine vollständige Swift-Implementierung der Java Collections API.

#### Interface-Hierarchie vervollständigen

- [ ] `Map.Entry<K, V>` — expliziter Typ für Schlüssel-Wert-Paare (aktuell nur als Tuple)
- [x] `Comparator<T>` — `reversed()`, `thenComparing(comparator)`, `naturalOrder()`, `reverseOrder()`, `nullsFirst()`, `nullsLast()` implementiert (Java 8 Default-Methoden)
- [ ] `Comparator<T>` — `comparing(keyExtractor)`, `thenComparing(keyExtractor)`, `comparingInt/Long/Double()` noch offen ⚠️ benötigt `Function<T,R>`

#### `Collections` – fehlende 1.2-Methoden
- [ ] `reverseOrder<T: Comparable>() -> Comparator<T>`
- [ ] `reverseOrder<T>(_ cmp: Comparator<T>) -> Comparator<T>`
- [ ] `singleton<T>(_ o: T) -> Set<T>`
- [ ] `singletonMap<K, V>(_ key: K, _ value: V) -> Map<K, V>`
- [ ] `enumeration<T>(_ c: Collection<T>) -> Enumeration<T>`
- [ ] `list<T>(_ e: Enumeration<T>) -> ArrayList<T>`
- [ ] `unmodifiableCollection<T>(_ c: Collection<T>) -> Collection<T>`
- [ ] `unmodifiableSet<T>(_ s: Set<T>) -> Set<T>`
- [ ] `unmodifiableSortedSet<T>(_ s: SortedSet<T>) -> SortedSet<T>`
- [ ] `unmodifiableMap<K, V>(_ m: Map<K, V>) -> Map<K, V>`
- [ ] `unmodifiableSortedMap<K, V>(_ m: SortedMap<K, V>) -> SortedMap<K, V>`
- [ ] `synchronizedCollection<T>(_ c: Collection<T>) -> Collection<T>`
- [ ] `synchronizedSet<T>(_ s: Set<T>) -> Set<T>`
- [ ] `synchronizedSortedSet<T>(_ s: SortedSet<T>) -> SortedSet<T>`
- [ ] `synchronizedMap<K, V>(_ m: Map<K, V>) -> Map<K, V>`
- [ ] `synchronizedSortedMap<K, V>(_ m: SortedMap<K, V>) -> SortedMap<K, V>`

#### `HashMap`
- [ ] `HashMap(_ map: Map<K, V>)` Copy-Konstruktor
- [ ] `clone() -> HashMap<K, V>`

#### `TreeMap`
- [ ] `TreeMap(_ comparator: (K, K) -> Int)` Konstruktor
- [ ] `TreeMap(_ m: SortedMap<K, V>)` Konstruktor
- [ ] `comparator() -> ((K, K) -> Int)?`
- [ ] `clone() -> TreeMap<K, V>`

#### `TreeSet`
- [ ] `TreeSet(_ comparator: (E, E) -> Int)` Konstruktor
- [ ] `TreeSet(_ s: SortedSet<E>)` Konstruktor
- [ ] `comparator() -> ((E, E) -> Int)?`
- [ ] `clone() -> TreeSet<E>`

#### `Arrays` – fehlende 1.2-Methoden
- [ ] `deepEquals(_ a1: [Any?], _ a2: [Any?]) -> Bool`
- [ ] `deepHashCode(_ a: [Any?]) -> Int`
- [ ] `hashCode` für primitive Typen (`[Int]`, `[Bool]`, etc.)

---

### P4 – Vollständige Java Collections API in Swift

Ziel: Swift-Entwickler können die gesamte `java.util` Collections API nutzen, ohne auf Workarounds zurückgreifen zu müssen.

#### Fehlende Kerntypen (nach Priorität)

1. **`LinkedHashSet<E>`** (Java 1.4) — komplettiert die Set-Hierarchie; oft als geordnetes `HashSet` benötigt
2. **`ArrayDeque<E>`** (Java 6) — Standard-`Deque`-Implementierung; `Deque`-Interface ohne Implementierung ist unbrauchbar
3. **`PriorityQueue<E>`** (Java 5) — einzige Heap-basierte Collection; fehlt komplett
4. **`Objects`** (Java 7) — `requireNonNull`, `equals`, `hash` werden in portiertem Code überall genutzt
5. **`Optional<T>`** (Java 8) — modern Java ohne Optional nicht denkbar
6. **`NavigableMap` / `NavigableSet`** (Java 6) — vervollständigt `TreeMap`/`TreeSet`-API

#### `Map.Entry<K, V>` als eigenständiger Typ
- [ ] Interface/Struct `Map.Entry<K, V>` mit `getKey() -> K`, `getValue() -> V`, `setValue(_ value: V) -> V`
- [ ] `equals(_ o: Any?) -> Bool`, `hashCode() -> Int`
- [ ] `Map.Entry.comparingByKey() -> Comparator` (Java 8)
- [ ] `Map.Entry.comparingByValue() -> Comparator` (Java 8)
- [ ] `HashMap`, `TreeMap`, `LinkedHashMap` auf echtes `entrySet() -> Set<Map.Entry<K,V>>` umstellen

#### `LinkedHashMap` – Testabdeckung und LRU-Support
- [ ] Tests auf ≥ 15 erweitern (Einfügungsreihenfolge, Iterationsreihenfolge)
- [ ] `LinkedHashMap(_ initialCapacity: Int, _ loadFactor: Float, _ accessOrder: Bool)`
- [ ] `removeEldestEntry(_ eldest: Map.Entry<K, V>) -> Bool` (protected)

---

### P5 – Java 21: Sequenced Collections (JEP 431)

Java 21 führte drei neue Interfaces ein, die rückwirkend in die bestehende Typhierarchie eingebettet wurden. Ohne sie ist die Collections-Hierarchie strukturell unvollständig.

#### Neue Interfaces

- [ ] **`SequencedCollection<E>`** — erweitert `Collection<E>`
  - [ ] `reversed() -> SequencedCollection<E>`
  - [ ] `getFirst() -> E`, `getLast() -> E`
  - [ ] `addFirst(_ e: E)`, `addLast(_ e: E)`
  - [ ] `removeFirst() -> E`, `removeLast() -> E`

- [ ] **`SequencedSet<E>`** — erweitert `SequencedCollection<E>` und `Set<E>`
  - [ ] `reversed() -> SequencedSet<E>` (kovariante Überschreibung)

- [ ] **`SequencedMap<K, V>`** — erweitert `Map<K, V>`
  - [ ] `reversed() -> SequencedMap<K, V>`
  - [ ] `firstEntry() -> Map.Entry<K, V>?`, `lastEntry() -> Map.Entry<K, V>?`
  - [ ] `pollFirstEntry() -> Map.Entry<K, V>?`, `pollLastEntry() -> Map.Entry<K, V>?`
  - [ ] `putFirst(_ k: K, _ v: V) -> V?`, `putLast(_ k: K, _ v: V) -> V?`
  - [ ] `sequencedEntrySet() -> SequencedSet<Map.Entry<K, V>>`
  - [ ] `sequencedKeySet() -> SequencedSet<K>`
  - [ ] `sequencedValues() -> SequencedCollection<V>`

#### Bestehende Typen anpassen (Interface-Conformance)

| Typ | Interface(s) hinzufügen |
|-----|------------------------|
| `List<E>` | `SequencedCollection<E>` |
| `Deque<E>` | `SequencedCollection<E>` |
| `LinkedHashSet<E>` | `SequencedSet<E>` |
| `SortedSet<E>` | `SequencedSet<E>` |
| `LinkedHashMap<K,V>` | `SequencedMap<K,V>` |
| `SortedMap<K,V>` | `SequencedMap<K,V>` |

#### `Collections` – neue Wrapper (Java 21)
- [ ] `unmodifiableSequencedCollection<T>(_ c: SequencedCollection<T>) -> SequencedCollection<T>`
- [ ] `unmodifiableSequencedSet<T>(_ s: SequencedSet<T>) -> SequencedSet<T>`
- [ ] `unmodifiableSequencedMap<K,V>(_ m: SequencedMap<K,V>) -> SequencedMap<K,V>`

---

## Java 1.0 – Lücken in vorhandenen Typen

### `Date`

- [ ] `getTime() -> Int64` (Millisekunden seit Epoch)
- [ ] `setTime(_ time: Int64)`
- [ ] `before(_ when: Date) -> Bool`
- [ ] `after(_ when: Date) -> Bool`
- [ ] `clone() -> Date`
- Deprecated, aber öffentliche API (müssen vorhanden sein):
  - [ ] `getYear() -> Int`
  - [ ] `setYear(_ year: Int)`
  - [ ] `getMonth() -> Int`
  - [ ] `setMonth(_ month: Int)`
  - [ ] `getDate() -> Int`
  - [ ] `setDate(_ date: Int)`
  - [ ] `getDay() -> Int` (Wochentag, read-only)
  - [ ] `getHours() -> Int`
  - [ ] `setHours(_ hours: Int)`
  - [ ] `getMinutes() -> Int`
  - [ ] `setMinutes(_ minutes: Int)`
  - [ ] `getSeconds() -> Int`
  - [ ] `setSeconds(_ seconds: Int)`
  - [ ] `toLocaleString() -> String`
  - [ ] `toGMTString() -> String`

**Tests:** 43 vorhanden, decken aber `getTime`/`setTime`, `before`/`after`, `clone` nicht ab.

---

### `Hashtable`

- [ ] `putAll(_ t: Map<K, V>)` — Java 1.2
- [ ] `equals(_ o: Any?) -> Bool` — Java 1.2
- [ ] `hashCode() -> Int` — Java 1.2
- [ ] `entrySet()` als `Set<Map.Entry>` — Java 1.2 (aktuell nur Enumeration)
- [x] `keySet()` als `any java.util.Set<K>` — Java 1.2 ✅
- [-] `values()` als `Collection<V>` — Java 1.2 · blockiert: `Collection<E>` erfordert `E: Equatable`, `V` unkonstrained

**Tests:** 26 vorhanden, keine Tests für obige Methoden.

---

### `Properties` (vorhanden, **0 Tests**)

- [ ] Tests für alle vorhandenen Methoden schreiben:
  - `getProperty`, `setProperty`, `propertyNames`, `load`, `store`, `save`, `list`
- [ ] `list(_ out: PrintWriter)` — Java 1.1
- [ ] `loadFromXML(_ in: InputStream)` — Java 5
- [ ] `storeToXML(_ os: OutputStream, _ comment: String?)` — Java 5
- [ ] `stringPropertyNames() -> Set<String>` — Java 6

---

### `Vector`

Vorhanden: breite Abdeckung (55 Tests). Lücken:

- [ ] `clone() -> Vector<E>`
- [ ] `containsAll(_ c: Collection) -> Bool`
- [ ] `addAll(_ c: Collection<E>) -> Bool` (Bulk ohne Index)
- [ ] `addAll(_ index: Int, _ c: Collection<E>) -> Bool`
- [ ] `removeAll(_ c: Collection) -> Bool`
- [ ] `retainAll(_ c: Collection) -> Bool`
- [ ] `indexOf(_ elem: E, _ index: Int) -> Int` (Suche ab Position)
- [ ] `lastIndexOf(_ elem: E, _ index: Int) -> Int`
- Felder: `protected elementData`, `protected elementCount`, `protected capacityIncrement` (in Java public-sichtbare protected-Felder)

---

### `Stack` (erbt von Vector)

- [ ] `search(_ o: Any?) -> Int` (1-basiert, von oben)

**Tests:** 31 vorhanden. `search()` fehlt komplett.

---

### `BitSet`

Vorhanden: `set(int)`, `clear(int)`, `get(int)`, `and`, `or`, `xor`, `size`, `clone`, `equals`, `hashCode`, `toString`. **28 Tests.**

Fehlend (Java 1.2):
- [ ] `andNot(_ set: BitSet)`

Fehlend (Java 1.4):
- [ ] `length() -> Int` (Index des höchsten gesetzten Bits + 1; verschieden von `size()`)
- [ ] `isEmpty() -> Bool`
- [ ] `cardinality() -> Int` (Anzahl gesetzter Bits)
- [ ] `intersects(_ set: BitSet) -> Bool`
- [ ] `flip(_ bitIndex: Int)`
- [ ] `flip(_ fromIndex: Int, _ toIndex: Int)`
- [ ] `set(_ bitIndex: Int, _ value: Bool)` (set mit boolean)
- [ ] `set(_ fromIndex: Int, _ toIndex: Int)` (Bereich setzen)
- [ ] `set(_ fromIndex: Int, _ toIndex: Int, _ value: Bool)`
- [ ] `clear(_ fromIndex: Int, _ toIndex: Int)` (Bereich löschen)
- [ ] `get(_ fromIndex: Int, _ toIndex: Int) -> BitSet` (Sub-BitSet)
- [ ] `nextSetBit(_ fromIndex: Int) -> Int`
- [ ] `nextClearBit(_ fromIndex: Int) -> Int`

Fehlend (Java 7):
- [ ] `previousSetBit(_ fromIndex: Int) -> Int`
- [ ] `previousClearBit(_ fromIndex: Int) -> Int`
- [ ] `toLongArray() -> [Int64]`
- [ ] `toByteArray() -> [UInt8]`
- [ ] `static valueOf(_ bytes: [UInt8]) -> BitSet`
- [ ] `static valueOf(_ longs: [Int64]) -> BitSet`

---

## Java 1.1 – Lücken in vorhandenen Typen

### `Calendar` (abstract)

Vorhanden: alle Konstanten, `getInstance()`, `get(int)`, `set(int, int)`, `setTime(Date)`, `getTime()`.

- [ ] `add(_ field: Int, _ amount: Int)` — für Datumsarithmetik zentral
- [ ] `roll(_ field: Int, _ up: Bool)`
- [ ] `roll(_ field: Int, _ amount: Int)` — Java 1.2
- [ ] `before(_ when: Any?) -> Bool`
- [ ] `after(_ when: Any?) -> Bool`
- [ ] `compareTo(_ anotherCalendar: Calendar) -> Int` — Java 1.5
- [ ] `clone() -> Calendar`
- [ ] `isSet(_ field: Int) -> Bool`
- [ ] `clear()` (alle Felder)
- [ ] `clear(_ field: Int)` (einzelnes Feld)
- [ ] `getTimeInMillis() -> Int64` — Java 1.2
- [ ] `setTimeInMillis(_ millis: Int64)` — Java 1.2
- [ ] `getActualMinimum(_ field: Int) -> Int` — Java 1.2
- [ ] `getActualMaximum(_ field: Int) -> Int` — Java 1.2
- [ ] `getMinimum(_ field: Int) -> Int`
- [ ] `getMaximum(_ field: Int) -> Int`
- [ ] `getGreatestMinimum(_ field: Int) -> Int`
- [ ] `getLeastMaximum(_ field: Int) -> Int`
- [ ] `getTimeZone() -> TimeZone`
- [ ] `setTimeZone(_ value: TimeZone)`
- [ ] `getFirstDayOfWeek() -> Int`
- [ ] `setFirstDayOfWeek(_ value: Int)`
- [ ] `isLenient() -> Bool`
- [ ] `setLenient(_ lenient: Bool)`
- [ ] `getMinimalDaysInFirstWeek() -> Int`
- [ ] `setMinimalDaysInFirstWeek(_ value: Int)`
- [ ] `static getInstance(_ zone: TimeZone) -> Calendar`
- [ ] `static getInstance(_ zone: TimeZone, _ locale: Locale) -> Calendar`
- [ ] `static getAvailableLocales() -> [Locale]`
- [ ] `toInstant()` — Java 8

**Tests:** 23 vorhanden, keine Arithmetik- oder Vergleichstests.

---

### `GregorianCalendar` (vorhanden, **0 Tests**)

- [ ] Tests für alle Konstruktoren schreiben
- [ ] `BC` und `AD` Konstanten (als eigene Felder in GregorianCalendar, zusätzlich zu Calendar)
- [ ] `isLeapYear(_ year: Int) -> Bool`
- [ ] `getGregorianChange() -> Date`
- [ ] `setGregorianChange(_ date: Date)`
- [ ] Konstruktoren: `GregorianCalendar(TimeZone)`, `GregorianCalendar(Locale)`, `GregorianCalendar(TimeZone, Locale)`
- [ ] Implementierung aller vererbten `Calendar`-Methoden (add, roll, etc.)
- [ ] `toZonedDateTime()` — Java 8

---

### `Locale`

Vorhanden: Sprachkonstanten (ENGLISH…KOREAN, CHINESE), Länderkonstanten (US…TAIWAN fehlen!), `getDefault()`, `setDefault()`, `getCountry()`, `getLanguage()`. **18 Tests.**

Fehlende Konstanten:
- [ ] `SIMPLIFIED_CHINESE` (= `CHINA`)
- [ ] `TRADITIONAL_CHINESE` (= `TAIWAN`)
- [ ] `PRC`
- [ ] `TAIWAN`
- [ ] `ROOT` — Java 6

Fehlende Methoden:
- [ ] `getVariant() -> String`
- [ ] `toString() -> String` (format: language_COUNTRY_variant)
- [ ] `getDisplayLanguage() -> String`
- [ ] `getDisplayLanguage(_ inLocale: Locale) -> String`
- [ ] `getDisplayCountry() -> String`
- [ ] `getDisplayCountry(_ inLocale: Locale) -> String`
- [ ] `getDisplayVariant() -> String`
- [ ] `getDisplayVariant(_ inLocale: Locale) -> String`
- [ ] `getDisplayName() -> String`
- [ ] `getDisplayName(_ inLocale: Locale) -> String`
- [ ] `getISO3Country() -> String` (throws MissingResourceException)
- [ ] `getISO3Language() -> String` (throws MissingResourceException)
- [ ] `static getAvailableLocales() -> [Locale]`
- [ ] `static getISOCountries() -> [String]`
- [ ] `static getISOLanguages() -> [String]`
- Java 7:
  - [ ] `getScript() -> String`
  - [ ] `getDisplayScript() -> String`
  - [ ] `getDisplayScript(_ inLocale: Locale) -> String`
  - [ ] `toLanguageTag() -> String`
  - [ ] `static forLanguageTag(_ languageTag: String) -> Locale`
  - [ ] `getExtension(_ key: Character) -> String?`
  - [ ] `getExtensionKeys() -> Set<Character>`
  - [ ] `getUnicodeLocaleType(_ key: String) -> String?`
  - [ ] `getUnicodeLocaleKeys() -> Set<String>`
  - [ ] `getUnicodeLocaleAttributes() -> Set<String>`
  - [ ] `Locale.Builder` (innere Klasse)
  - [ ] `Locale.Category` Enum (DISPLAY, FORMAT)
  - [ ] `static getDefault(_ category: Category) -> Locale`
  - [ ] `static setDefault(_ category: Category, _ locale: Locale)`

---

## Java 1.2 – Lücken in vorhandenen Typen

### `Collections`

Vorhanden: `sort`, `binarySearch`, `reverse`, `shuffle`, `min`, `max`, `fill`, `copy`, `frequency`, `disjoint`, `addAll`, `unmodifiableList`, `synchronizedList`, `emptySet/List/Map`, `singletonList`, `nCopies`. **42 Tests.**

Fehlende Konstanten:
- [ ] `static let EMPTY_SET: Set` (als Feld, nicht nur Methode)
- [ ] `static let EMPTY_LIST: List`
- [ ] `static let EMPTY_MAP: Map`

Fehlende Methoden (Java 1.2):
- [ ] `static reverseOrder<T: Comparable>() -> Comparator<T>`
- [ ] `static reverseOrder<T>(_ cmp: Comparator<T>) -> Comparator<T>`
- [ ] `static singleton<T>(_ o: T) -> Set<T>`
- [ ] `static singletonMap<K, V>(_ key: K, _ value: V) -> Map<K, V>`
- [ ] `static enumeration<T>(_ c: Collection<T>) -> Enumeration<T>`
- [ ] `static list<T>(_ e: Enumeration<T>) -> ArrayList<T>`
- [ ] `static unmodifiableCollection<T>(_ c: Collection<T>) -> Collection<T>`
- [ ] `static unmodifiableSet<T>(_ s: Set<T>) -> Set<T>`
- [ ] `static unmodifiableSortedSet<T>(_ s: SortedSet<T>) -> SortedSet<T>`
- [ ] `static unmodifiableMap<K, V>(_ m: Map<K, V>) -> Map<K, V>`
- [ ] `static unmodifiableSortedMap<K, V>(_ m: SortedMap<K, V>) -> SortedMap<K, V>`
- [ ] `static synchronizedCollection<T>(_ c: Collection<T>) -> Collection<T>`
- [ ] `static synchronizedSet<T>(_ s: Set<T>) -> Set<T>`
- [ ] `static synchronizedSortedSet<T>(_ s: SortedSet<T>) -> SortedSet<T>`
- [ ] `static synchronizedMap<K, V>(_ m: Map<K, V>) -> Map<K, V>`
- [ ] `static synchronizedSortedMap<K, V>(_ m: SortedMap<K, V>) -> SortedMap<K, V>`

Fehlende Methoden (Java 1.4):
- [ ] `static swap<T>(_ list: List<T>, _ i: Int, _ j: Int)`
- [ ] `static replaceAll<T>(_ list: List<T>, _ oldVal: T, _ newVal: T) -> Bool`
- [ ] `static rotate<T>(_ list: List<T>, _ distance: Int)`
- [ ] `static indexOfSubList<T>(_ source: List<T>, _ target: List<T>) -> Int`
- [ ] `static lastIndexOfSubList<T>(_ source: List<T>, _ target: List<T>) -> Int`

Fehlende Methoden (Java 5):
- [ ] `static checkedCollection`, `checkedList`, `checkedSet`, `checkedSortedSet`, `checkedMap`, `checkedSortedMap`

Fehlende Methoden (Java 7):
- [ ] `static emptyIterator<T>() -> Iterator<T>`
- [ ] `static emptyListIterator<T>() -> ListIterator<T>`
- [ ] `static emptyEnumeration<T>() -> Enumeration<T>`

Fehlende Methoden (Java 8):
- [ ] `static unmodifiableNavigableMap`, `unmodifiableNavigableSet`
- [ ] `static checkedNavigableMap`, `checkedNavigableSet`, `checkedQueue`
- [ ] `static emptyNavigableMap`, `emptyNavigableSet`

---

### `HashMap`

Vorhanden: `put`, `get`, `remove`, `containsKey`, `containsValue`, `size`, `isEmpty`, `clear`, `keySet`, `values`, `putAll`, `entrySet`. **33 Tests.**

- [ ] `HashMap(_ map: Map<K, V>)` Copy-Konstruktor — Java 1.2
- [ ] `clone() -> HashMap<K, V>` — Java 1.2
- Java 8:
  - [ ] `getOrDefault(_ key: K, _ defaultValue: V) -> V`
  - [ ] `putIfAbsent(_ key: K, _ value: V) -> V?`
  - [ ] `replace(_ key: K, _ value: V) -> V?`
  - [ ] `replace(_ key: K, _ oldValue: V, _ newValue: V) -> Bool`
  - [ ] `remove(_ key: K, _ value: V) -> Bool`
  - [ ] `compute(_ key: K, _ remappingFunction: (K, V?) -> V?) -> V?`
  - [ ] `computeIfAbsent(_ key: K, _ mappingFunction: (K) -> V) -> V`
  - [ ] `computeIfPresent(_ key: K, _ remappingFunction: (K, V) -> V?) -> V?`
  - [ ] `merge(_ key: K, _ value: V, _ remappingFunction: (V, V) -> V?) -> V?`
  - [ ] `forEach(_ action: (K, V) -> Void)`
  - [ ] `replaceAll(_ function: (K, V) -> V)`

---

### `TreeMap`

Vorhanden: Basisoperationen, `firstKey`, `lastKey`, `headMap`, `tailMap`, `subMap`. **24 Tests.**

- [ ] `TreeMap(_ comparator: (K, K) -> Int)` Konstruktor
- [ ] `TreeMap(_ m: SortedMap<K, V>)` Konstruktor
- [ ] `comparator() -> ((K, K) -> Int)?`
- [ ] `clone() -> TreeMap<K, V>`
- `NavigableMap`-Interface implementieren (Java 6):
  - [ ] `ceilingKey(_ key: K) -> K?`
  - [ ] `ceilingEntry(_ key: K) -> (key: K, value: V)?`
  - [ ] `floorKey(_ key: K) -> K?`
  - [ ] `floorEntry(_ key: K) -> (key: K, value: V)?`
  - [ ] `higherKey(_ key: K) -> K?`
  - [ ] `higherEntry(_ key: K) -> (key: K, value: V)?`
  - [ ] `lowerKey(_ key: K) -> K?`
  - [ ] `lowerEntry(_ key: K) -> (key: K, value: V)?`
  - [ ] `pollFirstEntry() -> (key: K, value: V)?`
  - [ ] `pollLastEntry() -> (key: K, value: V)?`
  - [ ] `descendingMap() -> NavigableMap<K, V>`
  - [ ] `descendingKeySet() -> NavigableSet<K>`
  - [ ] `navigableKeySet() -> NavigableSet<K>`
  - [ ] `headMap(_ toKey: K, _ inclusive: Bool) -> NavigableMap<K, V>`
  - [ ] `tailMap(_ fromKey: K, _ inclusive: Bool) -> NavigableMap<K, V>`
  - [ ] `subMap(_ fromKey: K, _ fromInclusive: Bool, _ toKey: K, _ toInclusive: Bool) -> NavigableMap<K, V>`

---

### `TreeSet`

Vorhanden: Basisoperationen, `first`, `last`, `headSet`, `tailSet`, `subSet`. **28 Tests.**

- [ ] `TreeSet(_ comparator: (E, E) -> Int)` Konstruktor
- [ ] `TreeSet(_ s: SortedSet<E>)` Konstruktor
- [ ] `comparator() -> ((E, E) -> Int)?`
- [ ] `clone() -> TreeSet<E>`
- `NavigableSet`-Interface implementieren (Java 6):
  - [ ] `ceiling(_ e: E) -> E?`
  - [ ] `floor(_ e: E) -> E?`
  - [ ] `higher(_ e: E) -> E?`
  - [ ] `lower(_ e: E) -> E?`
  - [ ] `pollFirst() -> E?`
  - [ ] `pollLast() -> E?`
  - [ ] `descendingSet() -> NavigableSet<E>`
  - [ ] `descendingIterator() -> Iterator<E>`
  - [ ] `headSet(_ toElement: E, _ inclusive: Bool) -> NavigableSet<E>`
  - [ ] `tailSet(_ fromElement: E, _ inclusive: Bool) -> NavigableSet<E>`
  - [ ] `subSet(_ fromElement: E, _ fromInclusive: Bool, _ toElement: E, _ toInclusive: Bool) -> NavigableSet<E>`

---

### `Arrays`

Vorhanden: `sort`, `fill`, `copyOf`, `copyOfRange`, `equals`, `binarySearch`, `toString`, `deepToString`, `asList`. **45 Tests.**

- [ ] `deepEquals(_ a1: [Any?], _ a2: [Any?]) -> Bool` — Java 5
- [ ] `deepHashCode(_ a: [Any?]) -> Int` — Java 5
- [ ] `hashCode(_ a: [Int]) -> Int` etc. (primitive Überladungen) — Java 5
- Java 8:
  - [ ] `parallelSort<T: Comparable>(_ a: inout [T])`
  - [ ] `parallelSort<T: Comparable>(_ a: inout [T], _ fromIndex: Int, _ toIndex: Int)`
  - [ ] `setAll<T>(_ array: inout [T], _ generator: (Int) -> T)`
  - [ ] `parallelSetAll<T>(_ array: inout [T], _ generator: (Int) -> T)`
  - [ ] `parallelPrefix<T>(_ array: inout [T], _ op: (T, T) -> T)`

---

### `LinkedHashMap` (Java 1.4)

Vorhanden: Basisoperationen. **4 Tests** (sehr dünn).

- [ ] `LinkedHashMap(_ initialCapacity: Int, _ loadFactor: Float, _ accessOrder: Bool)` Konstruktor
- [ ] `removeEldestEntry(_ eldest: (key: K, value: V)) -> Bool` (protected, für LRU-Subklassen)
- [ ] Tests deutlich erweitern (Einfügungsreihenfolge, accessOrder-Modus)

---

## Java 1.4 – Fehlende Typen

### `LinkedHashSet<E>` (komplett fehlend)

- [ ] Klasse anlegen als `HashSet`-Subklasse mit `LinkedHashMap`-Backing
- [ ] Konstruktoren: `()`, `(int)`, `(int, float)`, `(Collection<E>)`
- [ ] `clone() -> LinkedHashSet<E>`
- [ ] Tests

### `java.util.regex` (komplett fehlend)

- [ ] `PatternSyntaxException`
- [ ] `Pattern` (kompiliertes Regex-Muster):
  - `compile(_ regex: String) -> Pattern`
  - `compile(_ regex: String, _ flags: Int) -> Pattern`
  - `matcher(_ input: String) -> Matcher`
  - `matches(_ regex: String, _ input: String) -> Bool`
  - `split(_ input: String) -> [String]`
  - `split(_ input: String, _ limit: Int) -> [String]`
  - `pattern() -> String`
  - `flags() -> Int`
  - Konstanten: `CASE_INSENSITIVE`, `MULTILINE`, `DOTALL`, `UNICODE_CASE`, `CANON_EQ`, `LITERAL`, `UNIX_LINES`, `COMMENTS`, `UNICODE_CHARACTER_CLASS`
- [ ] `Matcher`:
  - `matches() -> Bool`, `find() -> Bool`, `find(_ start: Int) -> Bool`
  - `group() -> String`, `group(_ group: Int) -> String`, `group(_ name: String) -> String`
  - `start() -> Int`, `start(_ group: Int) -> Int`
  - `end() -> Int`, `end(_ group: Int) -> Int`
  - `groupCount() -> Int`
  - `replaceAll(_ replacement: String) -> String`
  - `replaceFirst(_ replacement: String) -> String`
  - `reset()`, `reset(_ input: String) -> Matcher`
  - `pattern() -> Pattern`
  - `appendReplacement`, `appendTail`
  - `lookingAt() -> Bool`
  - `region(_ start: Int, _ end: Int) -> Matcher`
  - `usePattern(_ newPattern: Pattern) -> Matcher`
- [ ] Tests

---

## Java 5 – Fehlende Typen

### `PriorityQueue<E>` (komplett fehlend)

- [ ] Min-Heap-Implementierung
- [ ] Konstruktoren: `()`, `(int)`, `(int, Comparator<E>)`, `(Collection<E>)`
- [ ] `offer`, `poll`, `peek`, `add`, `remove`, `contains`, `size`, `clear`, `iterator`
- [ ] `comparator() -> Comparator<E>?`
- [ ] `toArray()`
- [ ] Tests

### `ArrayDeque<E>` (komplett fehlend)

- [ ] Ring-Buffer-Implementierung des `Deque`-Interface
- [ ] Alle `Deque`-Methoden: `addFirst/Last`, `offerFirst/Last`, `peekFirst/Last`, `pollFirst/Last`, `removeFirst/Last`
- [ ] Queue-Methoden: `add`, `offer`, `peek`, `poll`, `remove`, `element`
- [ ] `push`, `pop` (Stack-Methoden)
- [ ] `clone()`, `toArray()`, `size()`, `isEmpty()`, `clear()`, `contains()`, `iterator()`, `descendingIterator()`
- [ ] Tests

### `EnumMap<K extends Enum<K>, V>` (komplett fehlend)

- [ ] Implementierung (Swift-Enums als Key problematisch — Designfrage)
- [ ] Tests

### `EnumSet<E extends Enum<E>>` (komplett fehlend)

- [ ] Implementierung (siehe EnumMap — Designfrage für Swift-Enums)
- [ ] Tests

### `Scanner` (komplett fehlend)

- [ ] Konstruktoren: `Scanner(InputStream)`, `Scanner(String)`, `Scanner(File)`
- [ ] `hasNext()`, `next() -> String`
- [ ] `hasNextLine()`, `nextLine() -> String`
- [ ] `hasNextInt()`, `nextInt() -> Int`, `nextInt(_ radix: Int) -> Int`
- [ ] `hasNextLong()`, `nextLong() -> Int64`
- [ ] `hasNextDouble()`, `nextDouble() -> Double`
- [ ] `hasNextFloat()`, `nextFloat() -> Float`
- [ ] `hasNextBoolean()`, `nextBoolean() -> Bool`
- [ ] `useDelimiter(_ pattern: String) -> Scanner`
- [ ] `useRadix(_ radix: Int) -> Scanner`
- [ ] `close()`
- [ ] Tests

### `AbstractQueue<E>` (komplett fehlend)

- [ ] Abstrakte Basisklasse für Queue (add, remove, element als Wrapper um offer/poll/peek)
- [ ] Tests

### `UUID` (vorhanden, nur 3 Tests)

- [ ] `getLeastSignificantBits() -> Int64`
- [ ] `getMostSignificantBits() -> Int64`
- [ ] `version() -> Int`
- [ ] `variant() -> Int`
- [ ] `timestamp() -> Int64` (nur für Version-1-UUIDs)
- [ ] `clockSequence() -> Int` (nur für Version-1-UUIDs)
- [ ] `node() -> Int64` (nur für Version-1-UUIDs)
- [ ] `compareTo(_ val: UUID) -> Int`
- [ ] Tests für alle obigen Methoden

---

## Java 6 – Fehlende Typen / Interfaces

### `NavigableMap<K, V>` (Interface, komplett fehlend)

- [ ] Protocol als Erweiterung von `SortedMap`
- [ ] Methoden: `ceilingKey`, `ceilingEntry`, `floorKey`, `floorEntry`, `higherKey`, `higherEntry`, `lowerKey`, `lowerEntry`, `pollFirstEntry`, `pollLastEntry`, `descendingMap`, `descendingKeySet`, `navigableKeySet`
- [ ] Erweiterte `headMap/tailMap/subMap` mit inclusive-Parameter
- [ ] `TreeMap` auf dieses Interface umstellen

### `NavigableSet<E>` (Interface, komplett fehlend)

- [ ] Protocol als Erweiterung von `SortedSet`
- [ ] Methoden: `ceiling`, `floor`, `higher`, `lower`, `pollFirst`, `pollLast`, `descendingSet`, `descendingIterator`
- [ ] Erweiterte `headSet/tailSet/subSet` mit inclusive-Parameter
- [ ] `TreeSet` auf dieses Interface umstellen

### `ServiceLoader` (vorhanden, **0 Tests**)

- [ ] Tests schreiben

### `Timer` / `TimerTask` (vorhanden, **0 Tests**)

- [ ] Tests schreiben

---

## Java 7 – Fehlende Typen

### `Objects` (komplett fehlend)

- [ ] `static equals(_ a: Any?, _ b: Any?) -> Bool`
- [ ] `static deepEquals(_ a: Any?, _ b: Any?) -> Bool`
- [ ] `static hashCode(_ o: Any?) -> Int`
- [ ] `static hash(_ values: Any?...) -> Int`
- [ ] `static toString(_ o: Any?) -> String`
- [ ] `static toString(_ o: Any?, _ nullDefault: String) -> String`
- [ ] `static requireNonNull<T>(_ obj: T?) throws -> T`
- [ ] `static requireNonNull<T>(_ obj: T?, _ message: String) throws -> T`
- [ ] `static isNull(_ obj: Any?) -> Bool` — Java 8
- [ ] `static nonNull(_ obj: Any?) -> Bool` — Java 8
- [ ] `static requireNonNullElse<T>(_ obj: T?, _ defaultObj: T) -> T` — Java 9 (optional)
- [ ] Tests

---

## Java 8 – Fehlende Typen

### `Optional<T>` (komplett fehlend)

- [ ] `static empty<T>() -> Optional<T>`
- [ ] `static of<T>(_ value: T) -> Optional<T>`
- [ ] `static ofNullable<T>(_ value: T?) -> Optional<T>`
- [ ] `isPresent() -> Bool`
- [ ] `isEmpty() -> Bool` — Java 11 (ggf. vorziehen)
- [ ] `get() -> T` (throws NoSuchElementException wenn leer)
- [ ] `orElse(_ other: T) -> T`
- [ ] `orElseGet(_ supplier: () -> T) -> T`
- [ ] `orElseThrow<X>(_ exceptionSupplier: () -> X) throws -> T`
- [ ] `map<U>(_ mapper: (T) -> U?) -> Optional<U>`
- [ ] `flatMap<U>(_ mapper: (T) -> Optional<U>) -> Optional<U>`
- [ ] `filter(_ predicate: (T) -> Bool) -> Optional<T>`
- [ ] `ifPresent(_ consumer: (T) -> Void)`
- [ ] Tests

### `java.util.function` (nur `Supplier` vorhanden)

- [ ] `Consumer<T>` — `accept(_ t: T)`
- [ ] `BiConsumer<T, U>` — `accept(_ t: T, _ u: U)`
- [ ] `Function<T, R>` — `apply(_ t: T) -> R`, `compose`, `andThen`, `identity`
- [ ] `BiFunction<T, U, R>` — `apply(_ t: T, _ u: U) -> R`, `andThen`
- [ ] `Predicate<T>` — `test(_ t: T) -> Bool`, `and`, `or`, `negate`, `not`
- [ ] `BiPredicate<T, U>` — `test(_ t: T, _ u: U) -> Bool`
- [ ] `UnaryOperator<T>` (extends Function<T,T>) — `identity`
- [ ] `BinaryOperator<T>` (extends BiFunction<T,T,T>) — `minBy`, `maxBy`
- [ ] Primitive Varianten: `IntSupplier`, `LongSupplier`, `DoubleSupplier`, `BooleanSupplier`
- [ ] `IntConsumer`, `LongConsumer`, `DoubleConsumer`
- [ ] `IntFunction<R>`, `LongFunction<R>`, `DoubleFunction<R>`
- [ ] `IntUnaryOperator`, `LongUnaryOperator`, `DoubleUnaryOperator`
- [ ] `IntBinaryOperator`, `LongBinaryOperator`, `DoubleBinaryOperator`
- [ ] `IntPredicate`, `LongPredicate`, `DoublePredicate`
- [ ] `ToIntFunction<T>`, `ToLongFunction<T>`, `ToDoubleFunction<T>`
- [ ] Tests

### `StringJoiner` (komplett fehlend)

- [ ] `StringJoiner(_ delimiter: String)`
- [ ] `StringJoiner(_ delimiter: String, _ prefix: String, _ suffix: String)`
- [ ] `add(_ newElement: String) -> StringJoiner`
- [ ] `merge(_ other: StringJoiner) -> StringJoiner`
- [ ] `setEmptyValue(_ emptyValue: String) -> StringJoiner`
- [ ] `length() -> Int`
- [ ] `toString() -> String`
- [ ] Tests

### `Spliterator<T>` (komplett fehlend)

- [ ] Protocol-Definition mit: `tryAdvance`, `forEachRemaining`, `trySplit`, `estimateSize`, `characteristics`
- [ ] Konstanten: `ORDERED`, `DISTINCT`, `SORTED`, `SIZED`, `NONNULL`, `IMMUTABLE`, `CONCURRENT`, `SUBSIZED`
- [ ] Primitive Varianten: `Spliterator.OfInt`, `OfLong`, `OfDouble`

### `java.util.stream` (komplett fehlend — Designentscheidung erforderlich)

> **Hinweis:** `java.util.stream` ist tief in Java-8-Lambdas und lazy-Evaluation eingebettet.
> Swift bietet `Sequence`, `LazySequence` und `AsyncSequence` als natürliche Entsprechungen.
> Empfehlung: Schnittstellen definieren, Implementierung auf Swift-Sequenzen delegieren.

- [ ] `Stream<T>` Interface (zumindest als Protocol-Stub)
- [ ] `Collectors` (statische Factory-Klasse, zumindest `toList`, `toSet`, `joining`, `groupingBy`, `counting`)
- [ ] `StreamSupport` (low-level Bridge)

## Java 9 – Neue Typen und Methoden in java.util

### `List`, `Set`, `Map` — statische Factory-Methoden (Java 9, immutable)

Die wichtigste Neuerung in Java 9 für `java.util` sind die `of()`-Factory-Methoden auf den Collection-Interfaces, die unveränderliche Instanzen erzeugen.

#### `List.of(…)` (komplett fehlend)
- [ ] `static of<E>() -> List<E>` (leere unveränderliche Liste)
- [ ] `static of<E>(_ e1: E) -> List<E>` … `static of<E>(_ e1…e10: E) -> List<E>` (Varianten bis 10 Elemente)
- [ ] `static of<E>(_ elements: E...) -> List<E>` (vararg-Variante)
- Erzeugte Listen: null-feindlich, wirft `NullPointerException` bei nil-Elementen
- Erzeugte Listen: werfen `UnsupportedOperationException` bei Mutation (add/set/remove)

#### `Set.of(…)` (komplett fehlend)
- [ ] Analog zu `List.of(…)`, zusätzlich: wirft `IllegalArgumentException` bei Duplikaten
- [ ] `static of<E: Hashable>() -> Set<E>` … bis vararg

#### `Map.of(…)` / `Map.entry(…)` / `Map.ofEntries(…)` (komplett fehlend)
- [ ] `static of<K, V>() -> Map<K, V>` (leere unveränderliche Map)
- [ ] `static of<K, V>(_ k1: K, _ v1: V) -> Map<K, V>` … bis 10 Schlüssel-Wert-Paare
- [ ] `static entry<K, V>(_ key: K, _ value: V) -> Map.Entry<K, V>` (immutable Entry)
- [ ] `static ofEntries<K, V>(_ entries: Map.Entry<K, V>...) -> Map<K, V>`
- [ ] `Map.Entry<K, V>` als eigenständiger Typ (bisher fehlt ein explizites Entry-Interface)

---

### `Optional<T>` – Erweiterungen (Java 9)

- [ ] `ifPresentOrElse(_ action: (T) -> Void, _ emptyAction: () -> Void)`
- [ ] `or(_ supplier: () -> Optional<T>) -> Optional<T>` (Alternative falls leer)
- [ ] `stream() -> Stream<T>` (0- oder 1-elementiger Stream — abhängig von Stream-Implementierung)

---

### `Objects` – Erweiterungen (Java 9)

- [ ] `static requireNonNullElse<T>(_ obj: T?, _ defaultObj: T) -> T`
- [ ] `static requireNonNullElseGet<T>(_ obj: T?, _ supplier: () -> T) -> T`
- [ ] `static checkIndex(_ index: Int, _ length: Int) -> Int` (throws IndexOutOfBoundsException)
- [ ] `static checkFromToIndex(_ fromIndex: Int, _ toIndex: Int, _ length: Int) -> Int`
- [ ] `static checkFromIndexSize(_ fromIndex: Int, _ size: Int, _ length: Int) -> Int`

---

### `java.util.concurrent` – Erweiterungen (Java 9)

- [ ] `CompletableFuture` — neue Methoden: `copy()`, `minimalCompletionStage()`, `orTimeout()`, `completeOnTimeout()`, `failedFuture()`, `completedStage()`, `failedStage()`
- [ ] `Flow` — neues Interface-Set für reaktive Streams (Publisher, Subscriber, Subscription, Processor)

---

### `ServiceLoader` – Erweiterungen (Java 9)

- [ ] `static load<S>(_ service: S.Type, _ loader: ClassLoader?) -> ServiceLoader<S>`
- [ ] `static loadInstalled<S>(_ service: S.Type) -> ServiceLoader<S>`
- [ ] `findFirst() -> Optional<S>` (Java 9)
- [ ] `stream() -> Stream<ServiceLoader.Provider<S>>` (Java 9)
- [ ] `ServiceLoader.Provider<S>` innere Schnittstelle (Java 9)

---

### `Scanner` – Erweiterungen (Java 9)

- [ ] `tokens() -> Stream<String>` (gibt Token-Stream zurück)
- [ ] `findAll(_ pattern: Pattern) -> Stream<MatchResult>`
- [ ] `findAll(_ patternStr: String) -> Stream<MatchResult>`

---

### Sonstige java.util-Ergänzungen (Java 9)

- [ ] `ResourceBundle` — `getBaseBundleName() -> String`
- [ ] `ResourceBundle.Control` — Erweiterungen für Modul-System (weniger relevant ohne JPMS)

---

## Java 10 – Neue Typen und Methoden in java.util

Java 10 bringt primär `var` (lokale Typinferenz) und eine Erweiterung der unveränderlichen Collections.

### `List`, `Set`, `Map` — `copyOf(…)` (Java 10)

- [ ] `static copyOf<E>(_ coll: Collection<E>) -> List<E>` — unveränderliche Kopie einer Collection
- [ ] `static copyOf<E: Hashable>(_ coll: Collection<E>) -> Set<E>` — unveränderliche Kopie
- [ ] `static copyOf<K, V>(_ map: Map<K, V>) -> Map<K, V>` — unveränderliche Kopie

> **Hinweis:** `copyOf` ist nil-feindlich (wirft NullPointerException bei nil-Elementen) und erzeugt echte Kopien — keine Views.

---

### `Collectors` – Erweiterungen (Java 10)

- [ ] `Collectors.toUnmodifiableList() -> Collector`
- [ ] `Collectors.toUnmodifiableSet() -> Collector`
- [ ] `Collectors.toUnmodifiableMap(keyMapper, valueMapper) -> Collector`
- [ ] `Collectors.toUnmodifiableMap(keyMapper, valueMapper, mergeFunction) -> Collector`

---

### `Optional<T>` – Erweiterungen (Java 10)

- [ ] `orElseThrow() -> T` (NoSuchElementException ohne Parameter — Kurzform von get() mit besserer Semantik)

---

## Java 11 – Neue Typen und Methoden in java.util

### `Collection` – Erweiterungen (Java 11)

Keine neuen Methoden in `java.util.Collection` selbst, aber `toArray(IntFunction)` als Default-Methode:
- [ ] `toArray(_ generator: (Int) -> [E]) -> [E]`

---

### `Optional<T>` – Erweiterungen (Java 11)

- [ ] `isEmpty() -> Bool` (Gegenstück zu `isPresent()` — bereits in Java-8-Abschnitt vermerkt, offiziell Java 11)

---

### `String`-verwandte Ergänzungen in `java.util` (Java 11)

- [ ] `Collection.stream()` — Standardmethode auf `Collection`-Interface (abhängig von Stream-Implementierung)

---

### `java.util.function` – keine Änderungen in Java 11

Keine neuen Typen. Bereits in Java-8-Abschnitt vollständig erfasst.

---

### `java.util.concurrent` – Erweiterungen (Java 11)

- [ ] `TimeUnit.convert(Duration)` — Konvertierung von `java.time.Duration` (abhängig von `java.time`-Implementierung)

---

### `java.util.regex` – Erweiterungen (Java 11)

Falls `java.util.regex` implementiert wird:
- [ ] `Pattern.asMatchPredicate() -> Predicate<String>` (Java 11)
- [ ] `Pattern.asPredicate() -> Predicate<String>` (Java 8, hier nachgetragen)
- [ ] `Matcher.results() -> Stream<MatchResult>` (Java 11)
- [ ] `Matcher.replaceAll(_ replacer: (MatchResult) -> String) -> String` (Java 11)
- [ ] `Matcher.replaceFirst(_ replacer: (MatchResult) -> String) -> String` (Java 11)

---

### `java.util.spi` – Erweiterungen (Java 9–11)

- [ ] `LocaleNameProvider` — Abstrakte Klasse für Locale-Anzeigenamen (SPI, weniger kritisch)
- [ ] `TimeZoneNameProvider` — Abstrakte Klasse für Zeitzonennamen (SPI)
- [ ] `CalendarDataProvider` — SPI für Kalender-Daten (Java 8, oft übersehen)
- [ ] `CalendarNameProvider` — SPI für Kalender-Feldnamen (Java 8, oft übersehen)

---

## Java 12 – Neue Typen und Methoden in java.util

Java 12 ist ein Non-LTS-Release mit einer relevanten Ergänzung in `java.util.stream`.

### `Collectors` – Erweiterungen (Java 12)

- [ ] `static teeing<T, R1, R2, R>(_ downstream1: Collector<T, R1>, _ downstream2: Collector<T, R2>, _ merger: (R1, R2) -> R) -> Collector<T, R>`
  — Leitet jeden Stream-Eintrag an zwei Collector weiter und kombiniert die Ergebnisse. Typischer Einsatz: gleichzeitig `min` und `max` berechnen, oder `count` und `sum`.

---

## Java 13 – Neue Typen und Methoden in java.util

Java 13 ist ein Non-LTS-Release. **Keine öffentlichen API-Änderungen in `java.util`.**
Text-Blocks (Preview) und Switch-Ausdrücke (Preview) betreffen `java.lang`, nicht `java.util`.

---

## Java 14 – Neue Typen und Methoden in java.util

Java 14 ist ein Non-LTS-Release. **Keine öffentlichen API-Änderungen in `java.util`.**
Records (Preview) und Pattern Matching für `instanceof` (Preview) sind `java.lang`-Features.

---

## Java 15 – Neue Typen und Methoden in java.util

Java 15 ist ein Non-LTS-Release. **Keine öffentlichen API-Änderungen in `java.util`.**
Sealed Classes (Preview) sind ein Sprachfeature.

---

## Java 16 – Neue Typen und Methoden in java.util

### `Stream<T>` – Erweiterungen (Java 16)

- [ ] `toList() -> List<T>` — terminale Operation, liefert unveränderliche Liste; kürzer als `collect(Collectors.toUnmodifiableList())`
- [ ] `mapMulti<R>(_ mapper: (T, (R) -> Void) -> Void) -> Stream<R>` — flexibler als `flatMap` für Eins-zu-viele-Abbildungen mit weniger Overhead
- [ ] `mapMultiToInt(_ mapper: (T, (Int) -> Void) -> Void) -> IntStream`
- [ ] `mapMultiToLong(_ mapper: (T, (Int64) -> Void) -> Void) -> LongStream`
- [ ] `mapMultiToDouble(_ mapper: (T, (Double) -> Void) -> Void) -> DoubleStream`

> **Hinweis:** Records werden in Java 16 finalisiert. Falls `java.lang.Record` als Basisklasse eingeführt wird, wäre das ein `java.lang`-Thema.

---

## Java 17 – Neue Typen und Methoden in java.util (LTS)

Java 17 ist ein **LTS-Release** und bringt das neue Paket `java.util.random`.

### `java.util.random` (komplett fehlend — neues Unterpaket)

Dieses Paket strukturiert die Zufallszahlen-API neu und führt ein erweitertes Interface-System ein.

#### `RandomGenerator` Interface (komplett fehlend)
- [ ] `nextBoolean() -> Bool`
- [ ] `nextInt() -> Int`, `nextInt(_ bound: Int) -> Int`, `nextInt(_ origin: Int, _ bound: Int) -> Int`
- [ ] `nextLong() -> Int64`, `nextLong(_ bound: Int64) -> Int64`, `nextLong(_ origin: Int64, _ bound: Int64) -> Int64`
- [ ] `nextDouble() -> Double`, `nextDouble(_ bound: Double) -> Double`, `nextDouble(_ origin: Double, _ bound: Double) -> Double`
- [ ] `nextFloat() -> Float`, `nextFloat(_ bound: Float) -> Float`, `nextFloat(_ origin: Float, _ bound: Float) -> Float`
- [ ] `nextGaussian() -> Double`, `nextGaussian(_ mean: Double, _ stddev: Double) -> Double`
- [ ] `nextExponential() -> Double`
- [ ] `isDeprecated() -> Bool`
- [ ] `static of(_ algorithmName: String) -> RandomGenerator` (Factory)
- [ ] `ints()`, `longs()`, `doubles()` — Stream-Methoden

#### `RandomGenerator.SplittableGenerator` (Sub-Interface)
- [ ] `split() -> SplittableGenerator`
- [ ] `split(_ source: SplittableGenerator) -> SplittableGenerator`

#### `RandomGenerator.JumpableGenerator` (Sub-Interface)
- [ ] `jump()`
- [ ] `copy() -> JumpableGenerator`

#### `RandomGenerator.LeapableGenerator` (Sub-Interface)
- [ ] `leap()`

#### `RandomGeneratorFactory<T>` (komplett fehlend)
- [ ] `static all() -> Stream<RandomGeneratorFactory<RandomGenerator>>`
- [ ] `static of<T>(_ algorithmName: String) -> RandomGeneratorFactory<T>`
- [ ] `create() -> T`, `create(_ seed: Int64) -> T`
- [ ] `name() -> String`, `group() -> String`
- [ ] `isDeprecated() -> Bool`, `isStatistical() -> Bool`, `isStochastic() -> Bool`
- [ ] `isHardwareBased() -> Bool`, `isSplittable() -> Bool`, `isJumpable() -> Bool`
- [ ] `isLeapable() -> Bool`, `isArbitrarily()` etc.
- [ ] `stateBits() -> Int`, `equidistribution() -> Int`, `period() -> BigInteger`

#### `SplittableRandom` (bisher nicht in der Bestandsaufnahme — vorhanden?)
- [ ] Prüfen ob vorhanden; falls nicht: Implementierung als `SplittableGenerator`
- [ ] `split() -> SplittableRandom`
- [ ] Alle `next*`-Varianten mit `origin`/`bound`-Parametern

#### Konkrete Algorithmen (alle als `RandomGenerator`-Implementierungen)
> In Java 17 eingeführt; Swift-Implementierung kann auf Systemzufallsquellen delegieren.
- [ ] `L32X64MixRandom`
- [ ] `L64X128MixRandom` (empfohlener Default für allgemeine Verwendung)
- [ ] `L64X128StarStarRandom`
- [ ] `L64X256MixRandom`
- [ ] `L128X128MixRandom`
- [ ] `L128X256MixRandom`
- [ ] `Xoshiro256PlusPlus`
- [ ] `Xoroshiro128PlusPlus`

#### `Random` – Retrofit (Java 17)
`java.util.Random` implementiert jetzt `RandomGenerator`:
- [ ] `Random` um `RandomGenerator`-Protocol erweitern
- [ ] Neue Methoden aus `RandomGenerator` auf `Random` ergänzen (nextLong mit Bounds, nextDouble mit Bounds etc.)

---

## Java 18 – Neue Typen und Methoden in java.util

Java 18 ist ein Non-LTS-Release. Keine strukturellen `java.util`-Änderungen.

**UTF-8 als Standard-Charset** (JEP 400): Betrifft `java.io`, nicht `java.util` direkt, aber `Properties.load()` und `Scanner` lesen implizit vom Default-Charset — dokumentieren falls relevant.

---

## Java 19 – Neue Typen und Methoden in java.util

Java 19 ist ein Non-LTS-Release.

### `java.util.concurrent` – Virtual Threads (Preview, JEP 425)

- [ ] `Executors.newVirtualThreadPerTaskExecutor() -> ExecutorService` (Preview)
  — Erzeugt einen Executor der für jeden Task einen neuen Virtual Thread startet.
  > **Swift-Hinweis:** Swift Structured Concurrency (`async`/`await`, `TaskGroup`) erfüllt denselben Zweck idiomatisch. Abwägen ob eine Brücken-API sinnvoll ist.

### `java.util.concurrent` – Structured Concurrency (Incubator, JEP 428)

- [-] `StructuredTaskScope` (Incubator — `jdk.incubator.concurrent`)
  > Da Incubator-Status: bewusst ausgelassen bis Finalisierung in Java 21.

---

## Java 20 – Neue Typen und Methoden in java.util

Java 20 ist ein Non-LTS-Release.

### `java.util.concurrent` – Scoped Values (Incubator, JEP 429)

- [-] `ScopedValue<T>` (Incubator) — kein direktes `java.util`-API
  > Warten auf Finalisierung.

### `java.util.concurrent` – Structured Concurrency (zweites Incubator, JEP 437)

Weiterentwicklung von Java 19. Noch kein stabiles API — bewusst ausgelassen.

---

## Java 21 – Neue Typen und Methoden in java.util (LTS)

Java 21 ist ein **LTS-Release** und bringt die wichtigste strukturelle Änderung an den Collections seit Java 2: die **Sequenced Collections** (JEP 431).

### `SequencedCollection<E>` (Interface, komplett fehlend)

Neues Interface in der Collection-Hierarchie zwischen `Iterable` und `Collection`. Alle geordneten Collections (`List`, `Deque`, `LinkedHashSet`, `SortedSet`) implementieren es.

- [ ] `getFirst() -> E` (throws NoSuchElementException)
- [ ] `getLast() -> E` (throws NoSuchElementException)
- [ ] `addFirst(_ e: E)` (optional; throws UnsupportedOperationException wenn nicht unterstützt)
- [ ] `addLast(_ e: E)` (optional)
- [ ] `removeFirst() -> E` (optional)
- [ ] `removeLast() -> E` (optional)
- [ ] `reversed() -> SequencedCollection<E>` — liefert Rückwärts-View (keine Kopie!)

Zu retrofitten auf:
- [ ] `List` — getFirst/getLast/addFirst/addLast/removeFirst/removeLast/reversed
- [ ] `LinkedList` — bereits teilweise vorhanden (getFirst/getLast etc.), `reversed()` fehlt
- [ ] `Deque` — getFirst/getLast/reversed
- [ ] `ArrayList` — getFirst/getLast als Kurzform

---

### `SequencedSet<E>` (Interface, komplett fehlend)

Erweitert `SequencedCollection<E>` und `Set<E>`.

- [ ] `reversed() -> SequencedSet<E>` (kovariante Überschreibung)

Zu retrofitten auf:
- [ ] `SortedSet` — `reversed()` als View mit umgekehrter Ordnung
- [ ] `LinkedHashSet` — erhält geordnete reversed()-Ansicht
- [ ] `TreeSet` — `reversed()` als NavigableSet-Sicht

---

### `SequencedMap<K, V>` (Interface, komplett fehlend)

Erweitert `Map<K, V>` für alle geordneten Maps.

- [ ] `firstEntry() -> Map.Entry<K, V>?`
- [ ] `lastEntry() -> Map.Entry<K, V>?`
- [ ] `pollFirstEntry() -> Map.Entry<K, V>?`
- [ ] `pollLastEntry() -> Map.Entry<K, V>?`
- [ ] `putFirst(_ key: K, _ value: V) -> V?` (optional)
- [ ] `putLast(_ key: K, _ value: V) -> V?` (optional)
- [ ] `reversed() -> SequencedMap<K, V>` — Rückwärts-View
- [ ] `sequencedKeySet() -> SequencedSet<K>`
- [ ] `sequencedValues() -> SequencedCollection<V>`
- [ ] `sequencedEntrySet() -> SequencedSet<Map.Entry<K, V>>`

Zu retrofitten auf:
- [ ] `SortedMap` — erweitert `SequencedMap`
- [ ] `LinkedHashMap` — firstEntry/lastEntry/putFirst/putLast/reversed
- [ ] `TreeMap` — firstEntry/lastEntry bereits teilweise vorhanden; reversed() und sequenced*-Views fehlen

---

### `Collections` – Erweiterungen für Sequenced Collections (Java 21)

- [ ] `static unmodifiableSequencedCollection<T>(_ c: SequencedCollection<T>) -> SequencedCollection<T>`
- [ ] `static unmodifiableSequencedSet<T>(_ s: SequencedSet<T>) -> SequencedSet<T>`
- [ ] `static unmodifiableSequencedMap<K, V>(_ m: SequencedMap<K, V>) -> SequencedMap<K, V>`
- [ ] `static synchronizedSequencedCollection<T>(_ c: SequencedCollection<T>) -> SequencedCollection<T>`
- [ ] `static synchronizedSequencedSet<T>(_ s: SequencedSet<T>) -> SequencedSet<T>`
- [ ] `static synchronizedSequencedMap<K, V>(_ m: SequencedMap<K, V>) -> SequencedMap<K, V>`

---

### `java.util.concurrent` – Virtual Threads finalisiert (Java 21, JEP 444)

- [ ] `Executors.newVirtualThreadPerTaskExecutor() -> ExecutorService` (stabil)
  > **Swift-Hinweis:** Analog zu Swift `Task {}`. Brücken-API nur falls tatsächlich benötigt.

### `java.util.concurrent` – Structured Concurrency (Preview, JEP 453)

- [-] `StructuredTaskScope<T>` — Preview; bewusst ausgelassen bis Finalisierung.

### `java.util.concurrent` – Scoped Values (Preview, JEP 446)

- [-] `ScopedValue<T>` — Preview; bewusst ausgelassen bis Finalisierung.

---

## Übersicht: Java-Versionen ohne java.util-Änderungen

| Version | Status | Anmerkung |
|---|---|---|
| Java 13 | Non-LTS | Keine java.util-Änderungen |
| Java 14 | Non-LTS | Keine java.util-Änderungen |
| Java 15 | Non-LTS | Keine java.util-Änderungen |
| Java 18 | Non-LTS | UTF-8 Default (io-nah), kein java.util-API |
| Java 20 | Non-LTS | Nur Incubator-APIs (bewusst ausgelassen) |

---

## Testabdeckungs-Lücken ohne neue Implementierung

Vorhandene Typen mit unzureichenden Tests:

| Typ | Ist | Bedarf |
|---|---|---|
| `GregorianCalendar` | 0 | ≥ 10 |
| `Properties` | 0 | ≥ 15 |
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

## Java 22 – Neue Typen und Methoden in java.util

Java 22 ist ein Non-LTS-Release. Die wichtigste Neuerung für `java.util.stream` ist die erste Preview von **Stream Gatherers**.

### `java.util.stream` – Stream Gatherers (Preview, JEP 461)

`Gatherer` ist eine neue Abstraktion für eigene, zustandsbehaftete Stream-Zwischenoperationen — das Gegenstück zu `Collector` für terminale Operationen.

#### `Gatherer<T, A, R>` Interface (komplett fehlend)
- [ ] `supplier() -> () -> A` — erzeugt den privaten Zustandsbehälter
- [ ] `integrator() -> Integrator<A, T, R>` — verarbeitet jedes Element
- [ ] `combiner() -> (A, A) -> A` — für parallele Ausführung (optional)
- [ ] `finisher() -> (A, Downstream<R>) -> Void` — Abschlussverarbeitung (optional)
- [ ] `andThen<V>(_ downstream: Gatherer<R, ?, V>) -> Gatherer<T, ?, V>` — Verkettung
- [ ] `static of(integrator:)` — statische Kurzform ohne Zustand
- [ ] `static of(supplier:integrator:)` — mit Zustand, ohne finisher
- [ ] `static of(supplier:integrator:finisher:)` — mit Zustand und finisher
- [ ] `static ofSequential(…)` — explizit sequenzielle Varianten

#### `Gatherer.Integrator<A, T, R>` (funktionales Interface)
- [ ] `integrate(_ state: A, _ element: T, _ downstream: Downstream<R>) -> Bool`

#### `Gatherer.Downstream<T>` (funktionales Interface)
- [ ] `push(_ element: T) -> Bool`
- [ ] `isRejecting() -> Bool`

#### `Gatherers` Utility-Klasse (komplett fehlend)
- [ ] `static fold<T, R>(_ initial: R, _ folder: (R, T) -> R) -> Gatherer<T, ?, R>` — kumulative Reduktion
- [ ] `static scan<T, R>(_ initial: R, _ scanner: (R, T) -> R) -> Gatherer<T, ?, R>` — gibt jeden Zwischenzustand aus
- [ ] `static mapConcurrent<T, R>(_ n: Int, _ mapper: (T) -> R) -> Gatherer<T, ?, R>` — parallele Abbildung mit Limit
- [ ] `static windowFixed<T>(_ windowSize: Int) -> Gatherer<T, ?, List<T>>` — feste Fenstergröße
- [ ] `static windowSliding<T>(_ windowSize: Int) -> Gatherer<T, ?, List<T>>` — gleitendes Fenster

#### `Stream<T>` – neue Methode
- [ ] `gather<R>(_ gatherer: Gatherer<T, ?, R>) -> Stream<R>` — neue Zwischenoperation

---

### `java.util.concurrent` – Structured Concurrency (zweite Preview, JEP 462)

- [-] `StructuredTaskScope<T>` — zweite Preview; weiterhin bewusst ausgelassen.

### `java.util.concurrent` – Scoped Values (zweite Preview, JEP 464)

- [-] `ScopedValue<T>` — zweite Preview; weiterhin bewusst ausgelassen.

---

## Java 23 – Neue Typen und Methoden in java.util

Java 23 ist ein Non-LTS-Release.

### `java.util.stream` – Stream Gatherers (zweite Preview, JEP 473)

Keine API-Änderungen gegenüber Java 22 Preview — nur Verfeinerungen aufgrund von Feedback. Implementierung wie Java 22 beschrieben.

### `java.util.concurrent` – Structured Concurrency (dritte Preview, JEP 480)

- [-] `StructuredTaskScope<T>` — dritte Preview; weiterhin bewusst ausgelassen.

### `java.util.concurrent` – Scoped Values (dritte Preview, JEP 481)

- [-] `ScopedValue<T>` — dritte Preview; weiterhin bewusst ausgelassen.

---

## Java 24 – Neue Typen und Methoden in java.util

Java 24 ist ein Non-LTS-Release. **Stream Gatherers werden finalisiert.**

### `java.util.stream` – Stream Gatherers FINALISIERT (JEP 485)

Die in Java 22/23 als Preview eingeführten Gatherers sind ab Java 24 stabile öffentliche API.
Alle unter Java 22 aufgeführten `Gatherer`-, `Gatherers`- und `Stream.gather()`-Einträge gelten damit als finale Ziel-API.

### `java.util.concurrent` – Scoped Values FINALISIERT (JEP 487)

`ScopedValue<T>` ist ab Java 24 finale API — allerdings in `java.lang`, nicht `java.util`:
- [-] Implementierung in `java.lang`-Abschnitt verfolgen, nicht hier.

### `java.util.concurrent` – Structured Concurrency (vierte Preview, JEP 499)

- [-] `StructuredTaskScope<T>` — vierte Preview; weiterhin bewusst ausgelassen.

### `java.util.concurrent` – weitere Ergänzungen (Java 24)

- [ ] `Future.State` Enum (Java 24 Erweiterung): `RUNNING`, `SUCCESS`, `FAILED`, `CANCELLED`
- [ ] `Future.resultNow() -> T` (throws IllegalStateException wenn nicht SUCCESS)
- [ ] `Future.exceptionNow() -> Throwable` (throws IllegalStateException)
- [ ] `Future.state() -> Future.State`

> **Hinweis:** `Future.resultNow()` etc. wurden bereits in Java 21 als Preview eingeführt und in Java 24 finalisiert. Rückprüfen ob bereits in Java-21-Abschnitt erfasst.

---

## Java 25 – Neue Typen und Methoden in java.util (LTS)

Java 25 ist ein **LTS-Release** (September 2025).

### `java.util.concurrent` – Structured Concurrency FINALISIERT (JEP 505)

Ab Java 25 ist `StructuredTaskScope` stabile öffentliche API:
- [ ] `StructuredTaskScope<T>` — abstrakte Basisklasse
  - `fork<U extends T>(_ task: () throws -> U) -> Subtask<U>`
  - `join() throws -> StructuredTaskScope<T>`
  - `joinUntil(_ deadline: Instant) throws` (throws TimeoutException)
  - `shutdown()`
  - `close()` (AutoCloseable)
  - `isShutdown() -> Bool` (protected)
  - `handleComplete(_ subtask: Subtask<T>)` (protected, zu überschreiben)
- [ ] `StructuredTaskScope.ShutdownOnFailure`
  - `exception() -> Optional<Throwable>`
  - `throwIfFailed() throws`
  - `throwIfFailed(_ esf: (Throwable) -> X) throws`
- [ ] `StructuredTaskScope.ShutdownOnSuccess<T>`
  - `result() throws -> T`
  - `result(_ esf: () -> X) throws -> T`
- [ ] `Subtask<T>` Interface
  - `get() -> T` (throws IllegalStateException)
  - `exception() -> Throwable` (throws IllegalStateException)
  - `state() -> Subtask.State`
  - `Subtask.State` Enum: `UNAVAILABLE`, `SUCCESS`, `FAILED`
  > **Swift-Hinweis:** Swift `async let` und `TaskGroup` decken die meisten Anwendungsfälle idiomatisch ab. Eine Brücken-API nur bei tatsächlichem Portierungsbedarf.

### Sonstige Änderungen (Java 25)

Java 25 ist primär ein Konsolidierungs-LTS. Über die Finalisierung von `StructuredTaskScope` hinaus sind keine nennenswerten `java.util`-API-Ergänzungen bekannt.

---

## Java 26 – Neue Typen und Methoden in java.util

Java 26 ist ein Non-LTS-Release (17. März 2026). Die 10 enthaltenen JEPs sind verifiziert gegen [openjdk.org/projects/jdk/26](https://openjdk.org/projects/jdk/26/).

### JEP 526 – Lazy Constants (zweite Preview): `java.util.List` und `java.util.Map`

Die wichtigste `java.util`-Änderung in Java 26: Im Zuge von JEP 526 wurden Factory-Methoden für lazy (deferred-initialization) Collections direkt in die `java.util.List`- und `java.util.Map`-Interfaces verschoben.

> **Preview-Status:** JEP 526 ist in Java 26 zweite Preview (nach erster Preview in Java 25 als „Stable Values" / JEP 502 umbenannt). API kann sich in Java 27 noch ändern — vorerst `[-]` bis Finalisierung.

- [-] `List.of(int size, IntFunction<E> generator) -> List<E>` — lazy List mit bedarfsweiser Initialisierung je Element
- [-] `Map.of(…)` — analoge lazy-Map-Factory
- [-] `LazyConstant<V>` — Trägertyp für einmalig berechnete Werte (Companion zu `@Stable`)

### JEP 525 – Structured Concurrency (sechste Preview)

- [-] `StructuredTaskScope<T>` — sechste Preview in Java 26; bewusst ausgelassen bis Finalisierung.

---

## Übersicht: Java-Versionen ohne java.util-Änderungen (Ergänzung)

| Version | Status | Anmerkung |
|---|---|---|
| Java 23 | Non-LTS | Nur Preview-Fortschreibungen, kein finales java.util-API |
| Java 26 | Non-LTS | Nur Preview-APIs (JEP 526/525) und JVM-Warning (JEP 500) |

---

*Stand: 2026-08-03 · Basis: Java 1.1–26 public API*
