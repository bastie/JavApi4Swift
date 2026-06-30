# Java2Swift

<!--
* SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

How to translate Java to Swift.

## Overview

Most modern programming language can be easy translate between. But the detail mechanism are different. This article describe problems and some solutions if you want translate Java source code to Swift. Be aware sometime a implementation from the scratch are better. 

### How to translate Java source code to Swift

This bullet point list is an overview over methods. Look into source code for more informations. But some things can do before. For example kill all `for` loops or at minimum do not complex statements and checks in the a look header.

### Some steps I do

0. Exit factor: Find a Swift project that already meets your requirements.
1. Problem factor: In result of hidden check 3rd party dependencies.  
2. Problem factor: In result of sometimes complex test, check loops in code. Sometime refactoring of loops especially for loops on Java site is a good idea. Do same if you translate Non-Java code like C. A good for loop only iterate over elements, that is equal to count as iterate over number range. 
3. Problem factor: Check types contains names of types equals names of methods. It is not allowed in Swift. I rename most the type name in `...Value`.
4. Nice to have: Check if method parameternames equals to names of variables in source code. I like the often in C# used variant of call the parametername `new...`. 

#### abstract classes

Abstract classes are implemented as interface with default methods.

> **AI hint:** Replace `abstract class Foo { abstract void bar(); void baz() {} }` with a Swift `protocol Foo { func bar() }` plus an `extension Foo { func baz() {} }` for the concrete methods. Do not use Swift `class` as a stand-in for Java abstract classes.

When an abstract class pattern requires a base class with unimplemented methods (e.g. `AbstractList`), use `preconditionFailure` — not `fatalError` — and include the concrete type name and method signature in the message:

```swift
open func get(_ location: Int) throws -> E? {
  preconditionFailure("\(type(of: self)).get(_:) not implemented")
}
```

`preconditionFailure` signals that the *caller* (i.e. the subclass author) violated a contract. The `type(of: self)` interpolation produces the concrete subclass name at runtime, which makes crash reports immediately actionable. Never use the generic string `"Not implemented"` alone — it provides no diagnostic value.

#### arrays

The Java length property of an array is mapped over a readonly computed Swift property with result of Swift count property. If available use Swift `count` directly.

Arrays are reference types in Java, but value types in Swift. If you set a new variable in Java to the **same** array, all you can do is this **one** array modify. In Swift you create a **second** array and all you do has no effect on array one.

```Java
/// real existing anonymized example
class OnlyOnce {
  int [] hihi = {0,1,2,3,4};

  void changeIt () {
    final int[] hoho = hihi;
    hoho [0] = 5;
  }
}
```

```Swift
class NotTwice {
  var hihi = [0,1,2,3,4]

  func changeIt () {
    hihi [0] = 5 
  }
}
```

> **AI hint:** When Java code assigns one array variable to another (`int[] b = a`), do **not** translate this as two independent Swift arrays. Either keep the array on the enclosing class (shared state) or use a reference-wrapper class. Always check whether the aliased variable is modified after assignment — if yes, a value-type copy silently breaks semantics.

#### assert

Instead of `assert` use the `guard` with function `fatalError`.

> **AI hint:** Translate `assert(condition, "msg")` to `guard condition else { fatalError("msg") }`. For `assert(false)` use `fatalError()` directly. Do not use Swift's built-in `assert()` — it is stripped in release builds, which differs from Java's behaviour when assertions are enabled.

#### blocks of statements

In Java blocks are between curly braces {}. Swift need the `do` keyword before the open brace.

> **AI hint:** Translate bare Java `{ ... }` scoping blocks to Swift `do { ... }`. Do not confuse these with `do`-`catch` — add `catch` only when the block contains `try`.

#### byte type

Swift use `UInt8` instead `byte` but typealias are exported.

> **AI hint:** Replace Java `byte` with Swift `UInt8`. Note that Java `byte` is **signed** (−128…127) while Swift `UInt8` is unsigned (0…255). If signed arithmetic is required use `Int8` instead and add a comment explaining the deviation.

#### casting

To cast in Swift use `as!` keyword. If in Java is first check with `instanceof` you should use `as?`.

> **AI hint:** Translate `(Foo) obj` to `obj as! Foo`. Translate `if (obj instanceof Foo) { Foo f = (Foo) obj; ... }` to `if let f = obj as? Foo { ... }`. Never emit a bare `as!` without first verifying the Java code does not guard the cast with `instanceof`.

#### char

Not often but here Swift need explicite declaration and double quotes, for example

```swift
let chars : [Character] : "a string to char array".toCharArray()
let char : Character = "c"
```

In extension you can compare Character with Int value with `==`. If you need the Int value of character use `asDigit()` function.

> **AI hint:** Java `char` is a UTF-16 code unit (0–65535). Swift `Character` is a full Unicode grapheme cluster. For single-ASCII-character literals translate `'x'` to `"x" as Character`. For arrays translate `char[]` to `[Character]`. Use `asDigit()` from JavApi4Swift when the integer value of the character is needed.    

#### do while loop

Instead of `do` use keyword `repeat`.

> **AI hint:** Translate `do { body } while (cond);` literally to `repeat { body } while cond`. Do not add a `catch` clause — `repeat` is not a `do`-`catch` block.

#### enum

Java enumerations (`enum`) are translated as Swift `enum` types that conform to `java.lang.Enum`. Each enum must declare `typealias E = Self` so the protocol's default implementations for `values()` and `valueOf(_:)` work correctly.

```swift
public enum QuitStrategy : java.lang.Enum {
  public typealias E = QuitStrategy
  case CLOSE_ALL_WINDOWS
  case NORMAL_EXIT
}
```

The `java.lang.Enum` protocol provides:
- `values()` — returns all cases via `CaseIterable.allCases`
- `valueOf(_:)` — finds a case by name using `"\(value)"` string interpolation, throws `IllegalArgumentException` if not found

If a Java enum has a `RawValue` (e.g. `Int`) add it to the conformance list but keep `java.lang.Enum` in the list:

```swift
public enum RoundingMode : Int, CaseIterable, java.lang.Enum {
  public typealias E = RoundingMode
  case UP = 0
  // ...
}
```

Do **not** add `java.lang.Enum` to Swift-internal helper enums (namespaces, Swiftify adapters, platform-specific helpers) — only to types that directly mirror a Java `enum` type.

> **AI hint:** Every Java `enum Foo { ... }` becomes a Swift `enum Foo : java.lang.Enum { public typealias E = Foo; ... }`. Use UPPER_CASE for case names to match Java convention. Do not implement `values()` or `valueOf(_:)` manually — the protocol default implementations cover the standard cases. Only provide a custom `valueOf` override when the enum has a `RawRepresentable` mapping that differs from the case name.

#### equals method

Java provides an `equals` method on object instances and the `==` operator for test against same object or same primitive value. In Swift the test to check same object is written with `===` operator. Also a `Swift.Equatable` protocol is supported but did not take a unspecific `Any` or `AnyObject` as (second) parameter.

This example based on `java.awt.geom.Point2D` can be a template to port equals method to Swift: 

```Swift
enum java { enum awt { enum geom {
  class Point2D : Equatable {
    // some other in the class

    /// Implements the Java like equals method.
    public static func ==(lhs: java.awt.geom.Point2D, rhs: AnyObject) -> Bool {
      if lhs === rhs { return true }
        guard rhs is Point2D else {
        return false
      }
      let p = rhs as! Point2D
      return lhs.getX() == p.getX() && lhs.getY() == p.getY();
    }
    
    /// Implements the Equatable protocol
    public static func ==(lhs: java.awt.geom.Point2D, rhs: Point2D) -> Bool {
      if lhs === rhs { return true }
      return lhs.getX() == rhs.getX() && lhs.getY() == rhs.getY();
    }
  }
} /* geom */ } /* awt */ } /* java */ 
```

> **AI hint:** Translate Java `equals(Object o)` by implementing **two** Swift overloads of `==`: one accepting `AnyObject` (Java-like) and one accepting the concrete type (Swift `Equatable`). Always check identity (`===`) first. Never omit the `Equatable` conformance declaration on the class.

#### Equatable for Java interfaces (protocols)

Java interfaces do not inherit `equals()` semantics — each implementing class decides equality via `Object.equals()`. When porting a Java interface to a Swift `protocol` that should also conform to `Equatable` and `Hashable`, two separate extension files are used:

**`+Equatable.swift`** — provides cross-type equality for all conformers (value types and reference types alike). Different Observer types can never be equal, so the default returns `false`:

```swift
extension java.util.Observer {
  public static func == (lhs: Self, rhs: any java.util.Observer) -> Bool { return false }
  public static func == (lhs: any java.util.Observer, rhs: Self) -> Bool { return false }
}
```

**`+EquatableObject.swift`** — provides same-type equality for **class**-based conformers via identity (`===`). This matches Java's default `Object.equals()` behaviour (identity equality unless overridden):

```swift
extension java.util.Observer where Self: AnyObject {
  public static func == (lhs: Self, rhs: Self) -> Bool { return lhs === rhs }
}
```

**Why two files?** Swift resolves the more-specific `where Self: AnyObject` overload for classes automatically, while value types (`struct`, `enum`) fall back to the general overload. Value-type conformers that need meaningful equality must implement `==` themselves.

**`+Hashable.swift`** — provides `hash(into:)` and `hashCode()` for class-based conformers via `ObjectIdentifier`, again using `where Self: AnyObject`:

```swift
extension java.util.Observer where Self: AnyObject {
  public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
  public func hashCode() -> Int { return ObjectIdentifier(self).hashValue }
}
```

Value-type conformers must implement `hash(into:)` and `hashCode()` manually.

> **AI hint:** When porting a Java interface that participates in collections (used as Map key or Set element), always generate all three extension files (`+Equatable.swift`, `+EquatableObject.swift`, `+Hashable.swift`). Do not collapse them into a single file — the `where Self: AnyObject` constraint must stay in its own extension to resolve correctly for both class and value-type conformers.

#### exception handling

In Java exception can seperated in "RuntimeException" without explicit naming and "the other exception". The other exception must be declared and catched. RuntimeException and the super type Throwable can be declared and catched - or use `public static void main [] throws Throwable {}`. Java use a *try block* with *catch NamedException* instead to Swift with "normal" *do block* with *catch*. Swift also provide the *error* enum inside the catch block, Java has the NamedException instance.

How translation is realized by example:

```java
// Java
try {
  // do something throwable
}
catch (NullPointerException npe) {}
catch (Exception e) {}
catch (Throwable t) {}
```

```swift
/// Swift with JavApi⁴Swift
do {
  // do something throwable
}
catch {
  switch error {
  case Throwable.NullPointerException: do {}
  case Throwable.Exception : do {}
  default : do {}
  }
}
```

Unlike JavApi in your project use better the `Result` type as return value. 

```swift

private func toCall () -> Result<MySuccessValue, Error> {
  // do something with error or success
  if (OMG_NOOOOOOOOOO) {
    return .failure (Error())
  }
  return .success (MySuccessValue())
}

// some more code

let result = toCall ().flatMap { _ in
  toOtherCall ().flatMap { _ in
    andOtherCall ()
  }
}
```

With **Swift 6.0** typed throws is provided.

```swift
  public twoBeOrNotTwoBe (_ number : Int) throws (NumberFormatException) {
    guard 42 == number else {
      throw NumberFormatException () 
    }
  }
```

> **AI hint:** Map each Java `catch (XException e)` to a `case Throwable.XException` inside a `switch error` block. Translate multi-catch `catch (A | B e)` to two separate `case` entries. In new code prefer Swift typed throws (`throws(XException)`) over the `Throwable` enum pattern. Never silently swallow exceptions — always translate at minimum to a `default: break` with a comment.

#### exception classes

Each Java exception class is translated to a Swift class in its own file, placed in the namespace directory that matches the Java package. The class follows this fixed pattern:

```swift
extension java.<package> {

  open class XyzException : <SuperException>, @unchecked Sendable {

    public override init () {
      super.init()
    }

    public override init (_ message: String) {
      super.init(message)
    }

    public override init (_ newMessage : String, _ newCause : Throwable) {
      super.init(newMessage, newCause)
    }

    public override init (_ newCause : Throwable) {
      super.init(newCause)
    }
  }
}
```

**Rules:**
- One exception class per file, named `XyzException.swift`.
- Always extend the correct Java supertype: `RuntimeException` for unchecked, `Exception` (or a checked subclass such as `IOException`) for checked exceptions. Use `java.lang.Error` for error subclasses.
- Always mark the class `@unchecked Sendable` — the `Throwable` hierarchy predates Swift concurrency.
- Always provide all four initialisers shown above (no-arg, message, message+cause, cause-only). Omit only initialisers that the Java source explicitly does not define.
- If the exception carries extra fields (e.g. `MissingResourceException` stores `className` and `key`), add them as `private let` properties and expose them through `get…()` methods like Java. Store them before calling `super.init`.

**Example with extra fields** (`java.util.MissingResourceException`):

```swift
extension java.util {
  open class MissingResourceException : RuntimeException, @unchecked Sendable {

    private let className : String
    private let key : String

    public init(_ message: String, _ className: String, _ key: String) {
      self.className = className
      self.key = key
      super.init(message)
    }

    public func getKey() -> String { return self.key }
    public func getClassName() -> String { return self.className }
  }
}
```

> **AI hint:** When porting a Java exception class, look up its supertype in the Java API docs and map it to the corresponding JavApi4Swift type. Do not use Swift's `Error` protocol directly — always subclass `RuntimeException` or `Exception` from JavApi4Swift. Do not collapse multiple exception classes into one file.

#### final

First let `let` the replacement be for `final`. For functions / method parameters the semantic of Java and Swift are "different". In Java you can be declare a parameter as not changeable with `final`. In todays Swift versions all parameteres are final by default, you can use `inout` but the semantic is little different. 

> **AI hint:** Translate Java `final` local variables and fields to Swift `let`. For `final` method parameters simply drop the keyword — Swift parameters are immutable by default. Do not add `inout` as a substitute for `final`; `inout` has call-site copy-in/copy-out semantics that do not match Java's `final`.

#### Generic Variance, Wildcards, and Collection Semantics
Java and Swift use fundamentally different generic systems.
Java relies on type erasure, wildcard variance (? extends / ? super), and reference-based mutable collections. Swift relies on compile-time generics, protocol constraints, existential types (any), opaque types (some), and value-based collections.
There is no direct 1:1 mapping between Java wildcard variance and Swift generics. Therefore, automated translation must prioritize semantic equivalence and test correctness over Swift idioms.

##### Translation Priority (Mandatory)
All automated translations must follow this order:
1. Preserve Java semantics (type relationships, mutability, aliasing).
2. Produce compilable Swift code using JavApi4Swift abstractions.
3. Preserve behavioral equivalence (tests must pass).
4. Only then apply Swift idiomatic refactoring (optional Phase 2).
Semantic correctness always overrides stylistic improvements.

##### Core Collection Mapping

| **Java Construct** | **Default Translation Strategy** |
|---|---|
| java.util.List<T> | java.util.List<T> |
| java.util.Set<T> | java.util.Set<T> |
| java.util.Map<K,V> | java.util.Map<K,V> |
| java.util.Collection<T> | java.util.JavaCollection<T> |
| Native Swift Array/Set/Dictionary | Only in Phase 2 (safe optimization) |

##### Wildcard Decision Rules (Quick Reference)

| **Java Pattern** | **Safe Translation Strategy** |
|---|---|
| java.util.List<T> | java.util.List<T> |
| java.util.List<? extends T> | <E: T> generic constraint (if safe) |
| java.util.List<? super T> | Preserve via java.util.List<T> abstraction |
| Complex wildcard expressions | Preserve + mark for review |

##### Upper-Bounded Wildcards (? extends T) – Producer

```Java
double total(List<? extends MonetaryAmount> amounts)
```

Recommended translation:
```Swift
public static func total<E: MonetaryAmount>(_ amounts: JavaList<E>) -> Double
```

Rationale
* ? extends T = producer (read-only intent)
* Swift generic constraints preserve type relationships better than any
* Avoid some T as a default mapping (may break cross-parameter type coupling)

❌ Do not translate blindly to:

```Swift
  java.util.List<any MonetaryAmount> [some MonetaryAmount]
```

Use Swift existentials or some only after semantic validation.

##### Lower-Bounded Wildcards (? super T) – Consumer

```Java
void addEuro(List<? super EuroAmount> target)
```

Swift has no equivalent of lower-bounded variance.
Recommended strategy (in order of preference):

1. Preserve Java abstraction (preferred):
  ```Swift
    public static func addEuro(_ target: JavaList<MonetaryAmount>) {
      target.add(EuroAmount(10.0))
  }
  ```
2. Use JavaList<Any> only if no shared base type exists
3. Introduce wrapper type only if required by API design

Do NOT:
* ❌ use inout to simulate reference semantics
* ❌ use any as a variance substitute
* ❌ attempt to encode lower bounds via Swift generics

##### Collection Semantics (Critical Rule)

Java collections are **mutable reference objects**. Shared references are part of the language model.

**Translation rules:**

* Always prefer JavaList, JavaSet, JavaMap when mutability or sharing exists.
* Do NOT replace Java collections with Swift value types (Array, Set, Dictionary) during Phase 1.
* Do NOT use inout as a substitute for Java reference behavior.
* Preserve aliasing: multiple references must observe shared mutations.

**Phase 2 Translation rules exception:**

Swift native collections may be introduced only if:

* no shared references exist
* no wildcard variance is involved
* all behavioral tests pass unchanged

**AI Translation Rules (Mandatory for AST Translators)**

1. Preserve JavApi4Swift abstractions whenever variance is present.
2. Prefer <E: Protocol> over any Protocol.
3. Treat some as an optimization, not a default mapping.
4. Never assume `? super T` maps to a fixed base type — preserve the Java abstraction instead.

#### hashCode method

Java provides a `hashCode` method on each object. Swift realize same with the `Swift.Hashable` protocol. To implement a Java like hashcode methode use something like this:

```Swift
class MyTypeNeedToBe : Hashable {

  // the Java method
  public func hashCode () -> Int {
    return hashValue // delegate work to Swift function
  }

  // a property for hash value but without calculate this
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher) // delegate the calculate into the hash function
    return hasher.finalize()
  }

  // calculate the hash
  public func hash(into hasher: inout Hasher) {
    hasher.combine(System.identityHashCode(self)) // put a system identical hash code part for this object
    // add more specific hash information over add some lines with
    // hasher.combine(...)
  }

}
```

> **AI hint:** When a Java class overrides `hashCode()`, translate it by implementing `hash(into:)` and combining the same fields. Use `System.identityHashCode(self)` only as a fallback when no domain-specific fields are available. Always pair `hashCode` with `equals` — if one is translated the other must be too.

#### instanceof

The Swift keyword is `is`. If it is only a check before casting use `as?` to optional cast.

> **AI hint:** Translate `obj instanceof Foo` to `obj is Foo`. When immediately followed by a cast, collapse both into `if let f = obj as? Foo { ... }` instead of emitting separate `is` + `as!`.

#### integer literals and 32-bit platforms (Android, WASM)

On 64-bit Apple platforms `Int` is 64 bits wide, so hex literals like `0xFF000000` fit without issues. On 32-bit targets such as Android and WebAssembly `Int` is only 32 bits, and the same literal overflows:

```swift
// error on 32-bit: integer literal '4278190080' overflows when stored into 'Int'
let alphaMask: Int = 0xFF000000
```

**Solution** — use `Int(bitPattern:)` to reinterpret the bit pattern as a signed integer:

```swift
let alphaMask: Int = Int(bitPattern: 0xFF000000)  // -16777216 on 32-bit, same bits
```

This compiles on all platforms and preserves the exact bit pattern needed for bitmask operations.

> **AI hint:** Any Java hex literal used as a bitmask (e.g. `0xFF000000`, `0x80000000`) must be wrapped in `Int(bitPattern:)` when targeting 32-bit platforms (Android, WASM). Apply this unconditionally to all hex literals that set the MSB of a 32-bit value.

#### interface

Java interfaces are mapped with Swift protocols. With created package like structure (see package section) a typealias is declerated in this enum with reference of protocol implementation outside the enum. In the protocol implementation a associatedtype is declerated to the typealias name in the structure. This is f.e. needed to declerated function the result type of interface. Default methods need to declerated in a extendsion of protocol like normal Swift protocols.

For example:

```swift
extension myrootpackage.mysubpackage {
  public typealias JavaInterfaceName = JavApi.JavaInterfaceName
  }

  public protocol JavaInterfaceName {
  associatedtype JavaInterfaceName: myrootpackage.mysubpackage.JavaInterfaceName

  func toDo (_ with : Int) -> myrootpackage.mysubpackage.JavaInterfaceName
}

extension JavaInterfaceName {
  func toDo (_ with : Int) -> myrootpackage.mysubpackage.JavaInterfaceName {
    return self
  }
}
```

> **AI hint:** For each Java interface, generate: (1) a `typealias` inside the package enum, (2) a `protocol` with an `associatedtype` bound to that typealias, (3) a separate `extension` for default methods. Never place default method bodies directly inside the `protocol` body.

#### constants — access via concrete class, not via protocol

Java interface constants are ported to Swift protocols (see *interfaces with constants* below). However, Swift **does not allow calling static properties directly on a protocol type** — only on conforming concrete types.

**Rule:** Always access constants through a concrete class or struct, never through the protocol.

```swift
// ✅ correct — access via concrete type
let orientation = JToolBar.HORIZONTAL
let placement   = JTabbedPane.TOP
let sep         = JSeparator.VERTICAL

// ❌ wrong — protocols cannot be used as types for static member access
let orientation = SwingConstants.HORIZONTAL   // compiler error or wrong constant
```

**Why this matters for AI code generation:**  
A **self-referential stored constant** is a silent, dangerous bug. Writing
`public static let HORIZONTAL: Int = JSeparator.HORIZONTAL` inside `JSeparator.swift`
does **not** "refer to the protocol value" — the stored `static let` *shadows* the
protocol's computed property, so the right-hand side refers to the property being
declared. The initialiser reads its own (not-yet-initialised) storage and resolves
to `0` for **every** such constant. If both `HORIZONTAL` and `VERTICAL` are written
this way they both become `0`, so orientation checks like
`_orientation == VERTICAL` are always true — e.g. a horizontal scroll bar gets
painted with vertical geometry. **Never write a self-referential stored constant.**

```swift
// ❌ wrong — self-reference, resolves to 0 for BOTH constants (silent bug)
public static let HORIZONTAL: Int = JSeparator.HORIZONTAL
public static let VERTICAL:   Int = JSeparator.VERTICAL
```

> **AI hint:** When generating or reviewing constant declarations inside a Swing component class, never use `SwingConstants.HORIZONTAL` / `SwingConstants.VERTICAL` (the global `enum SwingConstants`) on the right-hand side, and never write a self-referential stored constant (`X = ClassName.X`). At call sites (outside the defining class), always use the concrete class: `JToolBar.HORIZONTAL`, `JSeparator.VERTICAL`, `JTabbedPane.TOP`, etc.

**Special case — classes inside `javax.swing` that expose `SwingConstants` values:** Inside the `javax.swing` namespace, the name `SwingConstants` resolves to the *protocol* `javax.swing.SwingConstants`, not to the global `enum SwingConstants`. A plain `public static let HORIZONTAL: Int = SwingConstants.HORIZONTAL` therefore causes a compiler error.

The correct solution is to **declare conformance to `javax.swing.SwingConstants`** on the class and **not re-declare the constants at all**. The protocol's extension supplies the values, and `ClassName.HORIZONTAL` resolves to those extension-provided values directly — no stored property, no self-reference, no literal:

```swift
// ✅ correct — conformance alone lets the protocol extension supply the values.
//    Do NOT re-declare HORIZONTAL / VERTICAL here; a stored static let would
//    shadow the protocol value and (via self-reference) resolve to 0.
open class JScrollBar: javax.swing.JComponent, javax.swing.SwingConstants {
  // JScrollBar.HORIZONTAL == 0 and JScrollBar.VERTICAL == 1 come from the
  // SwingConstants protocol extension automatically.
}
```

This mirrors the Java idiom where a class *implements* `SwingConstants` to inherit its constants.

> **AI hint:** Whenever a Swing component inside `javax.swing` needs `SwingConstants` values as its own constants, add `, javax.swing.SwingConstants` to the class declaration and **rely on the inherited values** — do not re-declare them. If a value genuinely must be re-declared, use the integer literal (`public static let HORIZONTAL: Int = 0`), never `ClassName.HORIZONTAL` (self-reference) and never the bare `SwingConstants.CONSTANT` (protocol).

#### interfaces with constants

To implements constants in protocols take computed properties and an extensions.

```swift
  public protocol WithConstants {
    static var name : Type {get} // value of contants not here 
  }
  
  extension WithConstants {
    static var name : Type {contant_value} // like: static var magicNumber : Int { 42 }
  }
```

> **AI hint:** Java interface constants (`static final TYPE NAME = value`) become computed `static var` properties in a protocol `extension`. Do not use stored properties — protocols cannot have stored static properties. The value lives in the extension, not in the protocol declaration.

#### java.lang types

All types in package java.lang doesn't need to import in Java. One solution is to set the full package name before. In result of Java-Swift name overlap it seems better to implement these types outside the java.lang enum structure (see package section).

Also if default Swing type exists it is extended instead Java implementation is ported, see String type as example.

> **AI hint:** Do not wrap `java.lang` types inside the `java.lang` enum namespace. Types like `String`, `Integer`, `Boolean` are implemented as extensions on their native Swift equivalents (e.g. Swift `String`). When you encounter a `java.lang.X` reference, check whether JavApi4Swift already provides it as a Swift extension before generating a new type.

#### keyword masking

The best way is to rename variables and types in Java before collision with Swift keywords. But you can also variable names mask with backtick like:

```swift
let ``in`` : Int
```

But best, rename it before switch to swift.

> **AI hint:** Before translating, scan the Java source for identifiers that collide with Swift keywords: `in`, `repeat`, `operator`, `where`, `some`, `any`, `actor`, `async`, `await`. Rename them in the Java source first (e.g. `in` → `inputStream`). Use backtick escaping only as a last resort.

#### loops

##### for

The for loop in Swift takes one after one element from a sorted collection. A Range is not much more than a type of sorted collection in this moment. C, Java an some other programming language accepts also a counting loop. 

** How to count in a for loop? **

```java
for (int i = 0; i < 100; i++) {}
```

```swift
for i in 0..<100 {}
```

** How to count reverse in a for loop? **

```swift
for i in (0...99).reversed() {}
```

or

```swift
for i in stride (from: 99, to: -1, by: -1){}
```

** How to add more termination condidtion in loop header? **

```swift
for i in 0...99 where i % 2 != 0 && i % 3 != 0 {}
```

> **AI hint:** Translate Java `for (int i = start; i < end; i++)` to `for i in start..<end`. For step values other than 1 use `stride(from:to:by:)`. For reverse iteration use `.reversed()`. Extract any compound condition from the loop header into the body or a `where` clause — never emit a Swift `for` loop with logic in a fake initialiser.

##### while

Swift don't like composite statements. Not only in loops split in single statements is never a bad idea. For example let the loop header only check the termination condition.

```java
var count = 0
while ((count = inputStreamInstance.read(data)) != -1) {
  try dest.write(data, 0, count);
}
```

```swift
var count = try tis.read(&data)
while (count != -1) {
  try dest.write(data, 0, count)
  count = try tis.read(&data)
}
```

> **AI hint:** Never translate a Java `while` with a side-effectful condition (e.g. `while ((n = stream.read(buf)) != -1)`) directly. Extract the call before the loop and repeat it at the end of the loop body.

#### Map

Java Map is similar to dictionary type in Swift

```java
java.util.Map<String, Double> variable;
```
to    
```swift
var variable : [String: Double]
```

> **AI hint:** In Phase 1, keep `java.util.Map<K,V>` as `java.util.Map<K,V>` (JavApi4Swift abstraction) when the map is passed between methods or shared. Only replace with Swift `[K: V]` dictionary in Phase 2 after confirming no aliasing or reference sharing. See the Generic Variance section for collection semantics rules.

#### method

Java methods in classes can be mapped as function of struct or classes. Java method define

```java
visible returnType name (parameterType parameterName = defaultParameterValue, ...) throws namedException {}
```

Swift mapping is

```swift
visible name (_ parameterName : parameterType = defaultParameterValue, ...) throws {}
```

Swift prefered named parameter call of function instead of Java nameless function call. The underline adress this, but you need to add extra code in Swift (version 5.9) if parameterType is modifyable. In Swift you add a var modifier to parameter, but it doesn't work with underline. The target to make call of **public** functions do not make different, the var keyword need to be manual converted.

For example normal Swift code:

```swift 
public func toDo (var with : Int) -> Int64 {
  if with < 5 {
    with = 5
  }
  return Int64 (with)
}  
```

For example to translate Java code:

```java
public long toDo (int with) {
  if (with < 5) {
    with = 5;
  }
  return with;
}
```

For example Swift translated Java code:

```swift
public func toDo (_ _with : Int) -> Int64 {
  var with = _with

  if with < 5 {
    with = 5
  }
  return Int64(with)
}
```

I assume there is more than one call to a function, so the call is the same for a single line change/add. The other solution is to set the parameter with (var with : Int). Then all calls must be changed, including calls from other developers. Therefore, the underline solution is preferred. 

The translation has a Optional problem because Java reference types are implicite nullable instead of Swift with explicite nilable. In result it exists not the only one way. Take a closer look to the method implementation and the documentation (for black box reimplementation). One way is to declerated some methods with (all) optional and non-optional variants of method. See System.arraycopy as example in the source files.  

> **AI hint:** For each Java method parameter of reference type, decide explicitly: translate to Swift non-optional only if the Java code never passes `null` for that parameter; otherwise translate to optional (`Type?`). When unsure, generate both an optional and a non-optional overload. For mutable parameters use the `_ _paramName: Type` / `var paramName = _paramName` pattern — do not use `inout` as a substitute.

##### default methods

Default methods are implemented in a extension, because the mapping of Java interfaces in a Java package like structures need a bit more code. 

##### toString() method

If special toString() implemetation is in Java, first let your Swift type be conform to the *CustomStringConvertible*. Next implement the property *description*. For example

```swift
public func toString () -> String {
  return "My name is Bond, James Bond"
}

public var description: String {
  get {
    return self.toString()
  }
}
```

#### nested classes

Nested classes in Swift can not access to enclosing type variables. Give the nested class the needed variables as (weak) parameters.

> **AI hint:** When a Java nested (inner) class accesses `OuterClass.this.field`, translate it as a constructor parameter `weak var outer: OuterClass?` on the Swift nested class. For static nested classes no reference to the enclosing type is needed.

#### new instance

We do not need the `new` keyword to create an instance of type.

> **AI hint:** Strip `new` from all constructor calls: `new Foo(args)` → `Foo(args)`. For anonymous class instantiations there is no direct Swift equivalent — translate to a local `struct` or closure that conforms to the relevant protocol.

#### integer overflow

Java integer arithmetic (`int`, `long`, `short`, `byte`) always wraps silently on overflow — it uses two's complement with no exception. Swift's standard operators (`+`, `-`, `*`) trap (crash) on overflow in debug and release builds.

When implementing wrapper types like `Integer`, `Long`, `Short`, or `Byte`, always use Swift's overflow operators `&+`, `&-`, `&*` inside the operator implementations. This is also marginally faster because Swift emits no overflow-check instructions for `&+`/`&-`/`&*`.

```swift
// correct — matches Java overflow semantics and is faster
public static func + (lhs: Integer, rhs: Integer) -> Self {
  return .init(integerLiteral: lhs.value &+ rhs.value)
}

// wrong — crashes at runtime on overflow, unlike Java
public static func + (lhs: Integer, rhs: Integer) -> Self {
  return .init(integerLiteral: lhs.value + rhs.value)
}
```

> **AI hint:** When porting Java *arithmetic expressions* in application code, do **not** replace every `+`/`-`/`*` with `&+`/`&-`/`&*` — that would require rewriting all ported Java code and is out of scope. The overflow operators are only used inside the JavApi4Swift wrapper-class implementations of `Integer`, `Long`, `Short`, and `Byte`. Ported Java application code uses the normal Swift operators on the wrapped primitive types (`Int`, `Int64`, `Int16`, `Int8`), where overflow behaviour matches Java as long as the types are the same width.

#### operator >>>

The operator >>> is implemented. Composite operator like >>>= need to separated.

> **AI hint:** `x >>> n` is available from JavApi4Swift. Translate `x >>>= n` by splitting: `x = x >>> n`. Do not attempt to define `>>>=` as a new Swift operator.

#### operators

In Swift not exists Java operators are implemented in java.lang

Composite operators must be separated before they can be used. Also operator statements in loops must be separated. The spaced must be placed. Unknown operators need to be translated. Assignment with = operator need to be separated.

Examples:

    i++            translated to    i += 1   /// unknown operator
    i--            translated to    i -= 1   /// unknown operator
    i+=1           translated to    i += 1   /// spaces placed, same for other operators
    int i, j = 1   translated to    var i = 1; var j = 1;   /// separation of assignment operator
    int i, j = 1   translated to    var i : Int = 1; var j : Int = 1;   /// alternative solution

Other example:
    result = (first + second++)    to    result = (first + second); second += 1

In loops operator position are relevant. The operator before the variable name tells first do the operator statement and than test. The operator after the variable name tells test first and then do the operator statement.

For example:

    while (++i < 5) {}   translated to   i += 1; while (i < 5) {i += 1}       /// 1234
    while (i++ < 5) {}   translated to   i += 1; while (i < 5 + 1) {i += 1}   /// 12345
    while (--i > 0) {}   translated to   i -= 1; while (i > 5) {i -= 1}       /// 4321
    while (i-- > 0) {}   translated to   i -= 1; while (i > 5 + 1) {i -= 1}   /// 43210

Of course this are the easiest variants.

> **AI hint:** Process operators in this order: (1) split composite assignments (`i+=1` → `i += 1`), (2) replace `++`/`--` with `+= 1`/`-= 1`, (3) move pre/post-increment out of expressions into separate statements before or after. For pre-increment in a loop header (`++i`) add the increment before the loop AND at the end of the loop body. For post-increment in a loop header (`i++`) adjust the termination condition by +1.

#### one class per file

In Java each public class must reside in its own file of the same name. JavApi4Swift follows the same rule for all `open` and `public` types — including exception classes, resource bundles, and any other top-level types.

**Rules:**
- Every `open class`, `public class`, and `public struct` lives in its own `.swift` file named exactly after the type (e.g. `ListResourceBundle.swift`).
- Only `internal`, `private`, or `fileprivate` helper types may share a file with their primary type.
- Place the file in the directory that corresponds to the Java package (e.g. `Sources/JavApi/util/`).

> **AI hint:** When porting a Java file that contains only one public class, create exactly one Swift file with the same name. When porting a Java file that contains a public class and package-private helpers, the helpers may stay in the same file only if they are declared `internal` or `private`. Never place two `open` or `public` classes in the same `.swift` file, even if they belong to the same Java package.

#### package

Java packages can be mapped as enum hierachy. Take a look to the CryptoKit, for example MD5 is placed in the enum Insecure and must called with Insecure.MD5
Too add a new _package_ create an enum with same name. Subpackages can be add directly in the enum or maybe better as extension of these enum.

> **AI hint:** Map Java package `com.example.foo.bar` to nested Swift enums `com.example.foo.bar {}` (all empty, no cases). Declare top-level enums in their own file; add sub-packages via `extension`. Never use `struct` or `class` as a namespace — only `enum` prevents instantiation.

#### shortcuts

Java shortcuts for types need to be translated like

    1d    to    1.0         // double shortcut
    1l    to    Int64(1)    // long shortcut

> **AI hint:** Scan every numeric literal for Java type suffixes: `d`/`D` → Swift `Double` literal (e.g. `1.0`), `l`/`L` → `Int64(...)`, `f`/`F` → `Float(...)`. Remove the suffix and wrap or annotate as needed. Hex literals with `L` suffix: `0xFFFFFFFFL` → `Int64(bitPattern: 0xFFFFFFFF)`.

#### static block

Solution to do something:

```java
static {
  // only run once after class is loading
}
```

```swift
static _init : Void = {
  // only run once during class is loading
}()
```

Solution to init something:

```java
static Something[] staticArray;
static {
  staticArray = new Something [100];
  for (int i = 0; i < staticArray.length(); i++) {
    staticArray[i] = Something();
  }
  // do more
}
```

```swift
static staticArray : [Something] = {
  var _staticArray = Array.repeating (Something(), 100)
  //do more
  return _staticArray
}()
```

> **AI hint:** Translate Java `static { ... }` blocks to a Swift `static let _init: Void = { ... }()` property. For static array/collection initialisation use a self-executing closure assigned to a `static let`. Do not use `lazy` here — the initialisation must be eager, matching Java class-loading semantics.

#### static variables and Swift 6 concurrency

Java `static` fields are shared mutable state — any thread can read or write them. Swift 6 strict concurrency rejects this pattern unless the variable is explicitly declared safe.

**The problem**

A direct port of a Java static field:

```java
// Java
class URLConnection {
    private static ContentHandlerFactory factory = null;
}
```

```swift
// Swift 6 — compiler error
private static var factory: (any ContentHandlerFactory)? = nil
// error: static property 'factory' is not concurrency-safe because
// it is not either conforming to 'Sendable' or isolated to a global actor
```

**Solution 1 — `nonisolated(unsafe)`**

Use `nonisolated(unsafe)` when the Java semantics already guarantee safety and you take responsibility for correctness:

```swift
nonisolated(unsafe) private static var factory: (any ContentHandlerFactory)? = nil
```

This is appropriate when:
- The variable is **written once** and then only read (e.g. a factory registered at startup)
- Access is **manually synchronized** (e.g. protected by a lock or a DispatchSemaphore)
- The variable is captured in a `sending` closure that runs after the current task yields (semaphore pattern)

**Solution 2 — `actor`**

For mutable shared state that is accessed from multiple threads, use a Swift `actor` instead. See `ThreadGroup` as an example — it replaces Java's `synchronized` methods with actor isolation.

**Solution 3 — `@MainActor` or global actor**

If the variable is only accessed on the main thread (e.g. UI state), annotate it with `@MainActor`.

**Which to choose?**

| Java pattern | Swift 6 solution |
|---|---|
| Write-once static (factory, singleton) | `nonisolated(unsafe)` |
| Mutable shared state | `actor` |
| Closure capturing a local `var` across task boundary | `nonisolated(unsafe) var` |
| UI-only state | `@MainActor` |

> **Important:** `nonisolated(unsafe)` silences the compiler but does **not** add synchronisation. Only use it when you can reason that no data race is possible — the same way you would use `synchronized` in Java to assert thread safety without the compiler's help.

> **AI hint:** For every Java `static` field, determine the access pattern: write-once → `nonisolated(unsafe) static let/var`; multi-threaded mutable → `actor`; main-thread only → `@MainActor static var`. Never emit a bare `static var` without one of these annotations in Swift 6 mode — it will not compile.

#### String.format

Replace `String.format` with Swift placeholders like from

```java
String.format("Text %d, more text %s", intValue, stringValue)
```

to

```swift
"Text \(intValue), more text \(stringValue)"
```

> **AI hint:** Replace `String.format(fmt, args...)` with Swift string interpolation `"\(arg)"`. For format specifiers: `%d`/`%i` → `\(intVal)`, `%s` → `\(strVal)`, `%f` → `\(floatVal)` or `String(format: "%.2f", floatVal)` when precision matters. `%n` (newline) → `\n`.

#### Swiftify

Swiftify is a JavApi extension. It make additional implementations of Java methods with syntax more like Swift code. It can also implements additional Swift type to use the Java ported code like Swift in other real Swift code.

> **AI hint:** After completing a Phase 1 port, check whether JavApi4Swift already provides a Swiftify extension for the translated type. If so, do not re-implement methods that Swiftify already covers. Swiftify additions are in files suffixed `+Swiftify.swift`.

#### switch

Java cases `fallthrough` by default and need explicite `break` if not. But Java need no `default`. Also newer Java can use `->` instead of `:`.

If you use enum values in switch, you need a dot before the value name in case.

```java
switch (enumType){
case ENUM_NAME: break;
default: break;
}
```


```swift
switch (enumType){
case .ENUM_NAME: break;
default: break;
}
```

> **AI hint:** Java `switch` falls through by default — check every `case` for a missing `break`. If fall-through is intentional translate it with Swift `fallthrough`. Add `default:` only if Java has one or if Swift requires exhaustiveness. Prepend `.` to enum case names in Swift `case` labels.

#### Service Provider Interface (SPI)

Java's `java.util.ServiceLoader` loads implementations at runtime via reflection and `META-INF/services` descriptor files. Swift has no runtime reflection and no classpath, so the entire mechanism must be replaced.

**Solution: Static Registry**

Instead of dynamic loading, use a static registry that third parties call explicitly to register their implementation. This is semantically equivalent — the difference is that registration is explicit (a method call) rather than implicit (classpath scanning).

```swift
extension java.sql {
  public enum DriverManager {

    // Registry replaces META-INF/services/java.sql.Driver
    nonisolated(unsafe) private static var registeredDrivers: [any java.sql.Driver] = []

    // Third-party registers its driver (replaces Class.forName side-effect)
    public static func registerDriver(_ driver: any java.sql.Driver) throws {
      registeredDrivers.append(driver)
    }

    // Consumers use the registry exactly as in Java
    public static func getConnection(_ url: String) throws -> any java.sql.Connection {
      for driver in registeredDrivers {
        if let conn = try driver.connect(url) { return conn }
      }
      throw java.sql.SQLException("No suitable driver found for \(url)")
    }
  }
}
```

**Usage by a third-party driver:**

```swift
// Once at app startup — replaces the implicit Class.forName("org.example.Driver") call
try java.sql.DriverManager.registerDriver(MyDriver())
```

**General Pattern for all Java SPIs**

This registry pattern applies to every Java SPI, not just JDBC. The mapping is always the same:

| Java SPI mechanism | Swift equivalent |
|---|---|
| `META-INF/services/<InterfaceName>` | `XyzRegistry.register(impl)` |
| `ServiceLoader.load(Xyz.class)` | `XyzRegistry.all()` |
| `Class.forName(...)` static initializer | explicit `register()` call at startup |

Apply this pattern consistently whenever porting a Java API that uses `ServiceLoader`:

- `java.sql.Driver` → `DriverManager` registry  
- `java.nio.charset.CharsetProvider` → `CharsetRegistry`  
- `java.util.logging.Handler` → `LogManager` registry  
- `javax.imageio.ImageReaderSpi` → `ImageIO` registry  
- `java.security.Provider` → `Security` registry  

**Why this is better than Java's approach**

Java's `Class.forName` trick was always fragile — the wrong classpath entry silently skips registration with no error. The Swift registry makes the contract explicit: if `register()` is never called, `getConnection()` throws a clear error. This is a case where the Java→Swift port improves on the original.

> **AI hint:** Whenever a Java API uses `ServiceLoader`, do not attempt to replicate runtime reflection. Instead, create a static registry (`nonisolated(unsafe) private static var providers: [any ProviderProtocol] = []`) with a `register(_ provider:)` method and a lookup method. Mark the registry storage `nonisolated(unsafe)` because it is write-once at startup and then read-only — matching Java's typical SPI registration lifecycle.

#### Swing Look & Feel registration (SPI variant)

Swing's `UIManager` / `LookAndFeel` system is another SPI that is replaced by the static-registry pattern described above. There are two additional rules specific to Swing:

**1. `UIDefaults` must be complete.**  
Every `ComponentUI` key that a component can request must be present in `getDefaults()`. A missing entry (e.g. `RadioButtonMenuItemUI`) is silent at registration time but causes the component to fall back to hard-coded Basic UI at paint time — the wrong renderer silently wins. When adding a new `LookAndFeel`, cross-check `getDefaults()` against the full list in `BasicLookAndFeel`.

**2. `updateUI()` must delegate to `UIManager`, not hard-code a class.**  
Each `JComponent` subclass must implement `updateUI()` by calling `super.updateUI()` (which calls `UIManager.getUI(self)`), not by directly instantiating a specific UI class. Hard-coded calls like `BasicMenuItemUI.createUI(self)` bypass the active L&F entirely and cannot be switched at runtime.

```swift
// ✅ correct — honours the active L&F
override open func updateUI() {
  super.updateUI()
}

// ❌ wrong — always uses Basic regardless of L&F
override open func updateUI() {
  setUI(BasicMenuItemUI.createUI(self))
}
```

**3. `Component.visible` default semantics.**  
In Java, `java.awt.Component.visible` defaults to `true` for all non-window components. Only `Window` and its subclasses (`Frame`, `Dialog`, `JFrame`, …) start invisible. This is critical for `Window._allWindows` registration: `setVisible(true)` on a window only registers it on the *first* call (when `wasVisible` transitions from `false` → `true`). If `visible` starts as `true`, the window is never registered, and `UIManager.setLookAndFeel()` finds zero windows to update.

```swift
// Component.swift — correct default
public var visible: Bool = true   // non-window components start visible

// Window.swift — override in init() for Window subclasses
public override init() {
  super.init()
  self.visible = false            // windows start invisible, like Java
}
```

> **AI hint:** When porting any `java.awt.Window` subclass, always add an `init()` that sets `self.visible = false`. Do not change the `Component` default. Do not use `override var visible` — stored-property overrides are not allowed in Swift; use `init()` instead.

#### visibility

Swift visiblilities are:

1. private: like Java - symbol visible within the current declaration only. 
2. fileprivate: symbol visible within the current file.
3. internal: like .net - symbol visible within the current module or default access modifier.
4. public: for classes is not identical with Java - symbol visible outside the current module.
5. open: like public in Java - for class or function to be subclassed or overridden outside the current module.

In result of these Java ported classes are by default `open` except they are final then `public`.

> **AI hint:** Map Java `public class` → Swift `open class`. Map Java `public final class` → Swift `public final class`. Map Java `protected` → Swift `open` (no direct equivalent; use `open` to allow subclassing). Map Java package-private (no modifier) → Swift `internal`. Map Java `private` → Swift `private`.


----
