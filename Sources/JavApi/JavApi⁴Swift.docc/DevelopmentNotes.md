# Development Notes

Lessons learned and non-obvious design decisions for future contributors.

> **See also:** <doc:NotImplemented> — rationale for Java technologies that are deliberately not ported (currently: Serialization and RMI).

---

## Swing Hit-Test Coordinate Translation — `_SwingHitTest.find()` (2026-06)

### Problem
`_SwingHitTest.find(x:y:in:)` (formerly `_AWTHitTest.find`) checked whether a point fell within a child component's `bounds`,
but then passed the **original** (parent-relative) `x, y` unchanged when recursing into that child.
Because a child's own children store their bounds relative to the child's origin (not the root),
every nested hit-test was wrong: clicking a `JButton` inside a `JPanel` inside a `JFrame`
never returned the button.

This bug affected **all backends** (SwiftUI, X11, GDI) because the code lives in
platform-independent `_SwingHitTest.swift` / `_AWTHitTest.swift`.

### Solution
Translate into the child's local space before recursing:

```swift
let lx = x - b.x   // b = child.bounds (parent-relative)
let ly = y - b.y
// recurse with lx, ly  (child-local coordinates)
```

This mirrors how Java's own `Component.contains()` works: bounds are always
expressed relative to the parent, so you must subtract `b.x/b.y` at each level.

### Impact
Single fix unblocked JButton clicks, CardLayout navigation, menu interaction,
and every other pointer-driven event in Swing hierarchies across all platforms.

---

## Swing Layout Validation — `setFrameSize` Guard Removed (2026-06)

### Problem
`_SwiftUINativeCanvas.setFrameSize` had a size-equality guard:
if the incoming size matched `container.bounds.size`, it returned early and skipped `validate()`.
When `setSize()` was called on a `JDialog`/`JFrame` **before** the window appeared,
the container bounds were already set to the requested size — so when SwiftUI later called
`setFrameSize`, the guard fired and `validate()` was never called.
Result: all child component bounds remained `(0,0,0,0)`, nothing rendered.

### Solution
Remove the guard. Always set `container.bounds` and call `validate()`:

```swift
container.bounds = java.awt.Rectangle(0, 0, newW, newH)
container.validate()
```

The cost is negligible — `validate()` is cheap when the layout is already current
(it propagates `isValid` flags and stops early).

---

## Swing Dialog Close on macOS — `closeDialog()` vs `hide()` (2026-06)

### Problem
`SwiftUIToolkit.hide(dialog)` called `_SwiftUIWindowHost.shared.hide(dialog)`, which only
removed the dialog from the Swift-level registry. It did **not** call `nsPanel.orderOut(nil)`,
so the NSPanel remained visible on screen.

### Solution
Override `hide(_:)` in `SwiftUIToolkit` to detect `java.awt.Dialog` and route to `closeDialog()`:

```swift
public override func hide(_ window: java.awt.Window) {
  #if os(macOS)
  if let dialog = window as? java.awt.Dialog {
    _SwiftUIWindowHost.shared.closeDialog(dialog)
    return
  }
  #endif
  _SwiftUIWindowHost.shared.hide(window)
}
```

`closeDialog()` calls `NSApp.stopModal()` (for modal dialogs) and `nsPanel.orderOut(nil)`,
which actually removes the panel from the screen.

---

## `java.util.ArrayList` — Reference Type Implementation (2026-06)

### Problem
`java.util.ArrayList` was aliased to Swift's `Array` (`typealias ArrayList = Array`).
Swift `Array` is a **value type** (copy-on-write), Java `ArrayList` is a **reference type**.
This is a semantic dead end — aliasing cannot express Java's reference semantics.

### Solution
Implemented `ArrayList<E>` as a Swift `class` inheriting `AbstractList<E>`.
Tests explicitly verify reference semantics vs. Swift Array behavior.

---

## `java.util.Iterator` — Protocol Design (2026-06)

### Problem: Signature conflict
Java's `Iterator.next()` throws; Swift's `IteratorProtocol.next()` returns `Element?`.
Having `java.util.Iterator` inherit `IteratorProtocol` caused an irresolvable conflict:
- Java: `func next() throws -> Element`
- Swift: `func next() -> Element?`
Swift cannot satisfy both from one implementation.

### Solution
`java.util.Iterator` does **not** inherit `IteratorProtocol`.
Concrete iterator classes (`ArrayListIterator`, `ArrayListListIterator`) explicitly conform
to **both** protocols with two distinct overloads:

```swift
// java.util.Iterator — Java API
func next() throws(java.util.NoSuchElementException) -> E

// IteratorProtocol — Swift for-in
func next() -> E?
```

Swift 6 distinguishes the overloads by return type and `throws` clause.
`makeIterator()` returns `self` (concrete type) — no `AnyIterator` boxing needed.

### Why not the Extension default?
`Iterator+Swiftify.swift` provides a default `makeIterator() -> AnyIterator<Element?>`
for any `java.util.Iterator` conformer. However, Swift protocol-extension defaults do
**not** satisfy `Sequence` conformance for concrete types — the compiler requires
`makeIterator()` to be defined on the type itself. The extension default is still useful
for existentials (`any java.util.Iterator`) but cannot substitute for direct conformance.

---

## `java.lang.Iterable` — Not an Iterator (2026-06)

### Problem
`Iterable` had inherited `IteratorProtocol`. An `Iterable` **produces** iterators; it is
not one. This caused SIGABRT via a forced `as! Self.Iterator` cast in a Collection extension.

### Solution
`Iterable` has no `IteratorProtocol` inheritance. It only declares:
```swift
func iterator() -> any java.util.Iterator<E>
```

---

## `AbstractCollection.makeIterator()` (2026-06)

`AbstractCollection` satisfies Swift `Sequence` via:
```swift
public typealias Element = E?
public func makeIterator() -> AnyIterator<E?> {
  return self.iterator().makeIterator()
}
```

The `AnyIterator` wrapper is acceptable here because `AbstractCollection` works with
`any java.util.Iterator<E>` existentials (from subclass `iterator()` overrides) and
there is no single concrete iterator type to return directly.

---

## `remove(_:)` Overload Ambiguity (2026-06)

Java has two `remove` methods on `List`:
- `remove(int index)` — by position
- `remove(Object o)` — by value

In Swift both map to `remove(_:)` with different parameter types (`Int` vs `E?`).
When the element type is `Int`, the call `list.remove(5)` is ambiguous.

**Disambiguate with explicit cast in call sites:**
```swift
list.remove(5)       // ambiguous if E == Int
list.remove(5 as Int?)  // remove by value
try list.remove(0)   // remove by index (throws)
```

---

## Tests for deprecated API — suppress warnings with `@available(*, deprecated)` (2026-06)

### Problem
Deprecated API (e.g. `SimpleTimeZone`, `URLEncoder.encode(_:)`) must remain in the library
for backward compatibility, but calling it from test code produces:

```
warning: 'SimpleTimeZone' is deprecated: Deprecated in Java 26 for removal. [#DeprecatedDeclaration]
```

The warning is correct for production callers but noise in tests that intentionally cover the deprecated path.

### Solution
Annotate each test *method* (not the whole struct) with `@available(*, deprecated)`:

```swift
@available(*, deprecated)
@Test("SimpleTimeZone.getAvailableIDs returns a non-empty list")
func testGetAvailableIDsIsNotEmpty() {
  #expect(SimpleTimeZone.getAvailableIDs().count > 0)
}
```

Swift then treats the call site as intentionally deprecated and suppresses the warning.
Annotating the method — not the struct — keeps non-deprecated tests in the same file warning-free.

---

## `Boolean(String)` Constructor — Swift Built-in Initializer Conflict (2026-06)

### Problem

`Boolean` is a `typealias` for Swift's `Bool`. Swift's standard library declares:

```swift
Bool.init?(_ description: String)   // failable, case-sensitive: only "true"/"false"
```

Writing `Boolean("TRUE")` in Swift code is therefore ambiguous — the compiler resolves it to
the built-in failable initializer and returns `nil` instead of `true`, silently breaking
Java-compatible behaviour.

### JavApi implementation

`Boolean.swift` declares:

```swift
public init(_ value: String?) {
  self.init(value?.lowercased() == "true")
}
```

This is non-failable and case-insensitive, matching Java's `new Boolean(String)`.
Because the parameter type is `String?` (optional) rather than `String`, Swift can distinguish
the two initializers — but only when the call site passes an explicit `Optional`:

```swift
let s: String? = "TRUE"
let b = Boolean(s)   // → true  ✔  (JavApi init)

let b2 = Boolean("TRUE")  // → nil  ✗  (Swift built-in failable init)
```

### Rule for call sites and tests

Always use ``valueOf(_:)`` as the idiomatic API — it has no ambiguity:

```swift
Boolean.valueOf("TRUE")   // → true  ✔
```

When the `init(String?)` path must be tested directly (e.g. to verify nil-handling),
pass an explicit `String?` variable, never a string literal:

```swift
let s: String? = "TRUE"
#expect(Boolean(s) == true)
```

### Rule for tests covering the constructor

Test structs that exercise `Boolean.init(String?)` must include this comment so the
constraint is visible at the test site:

```swift
// Swift/Java interop: pass String? explicitly — Boolean("literal") resolves to
// Swift's built-in Bool.init? and returns nil. See DevelopmentNotes.md.
```
