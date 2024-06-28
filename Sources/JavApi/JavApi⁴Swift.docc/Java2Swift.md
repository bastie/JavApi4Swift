# Java2Swift

How to translate Java to Swift.

## Overview

Most modern programming language can be easy translate between. But the detail mechanism are different. This article describe problems and some solutions if you want translate Java source code to Swift. Be aware sometime a implementation from the scratch are better. 

### How to translate Java source code to Swift

This bullet point list is an overview over methods. Look into source code for more informations.

#### abstract classes

Abstract classes are implemented as interface with default methods.

#### arrays

The Java length property of an array is mapped over a readonly computed Swift property with result of Swift count property. If available use Swift `count` directly.

#### assert

Instead of `assert` use the `guard` with function `fatalError`.

#### blocks of statements

In Java blocks are between curly braces {}. Swift need the `do` keyword before the open brace.

#### byte type

Swift use `UInt8` instead `byte` but typealias are exported.

#### casting

To cast in Swift use `as!` keyword. If in Java is first check with `instanceof` you should use `as?`.

#### char

Not often but here Swift need explicite declaration and double quotes, for example

```swift
let chars : [Character] : "a string to char array".toCharArray()
let char : Character = "c"
```

In extension you can compare Character with Int value with `==`. If you need the Int value of character use `asDigit()` function.    

#### do while loop

Instead of `do` use keyword `repeat`.

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

#### final

First let `let` the replacement be for `final`. For functions / method parameters the semantic of Java and Swift are "different". In Java you can be declare a parameter as not changeable with `final`. In todays Swift versions all parameteres are final by default, you can use `inout` but the semantic is little different. 

#### instanceof

The Swift keyword is `is`. If it is only a check before casting use `as?` to optional cast.

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

#### java.lang types

All types in package java.lang doesn't need to import in Java. One solution is to set the full package name before. In result of Java-Swift name overlap it seems better to implement these types outside the java.lang enum structure (see package section).

Also if default Swing type exists it is extended instead Java implementation is ported, see String type as example.

#### keyword masking

The best way is to rename variables and types in Java before collision with Swift keywords. But you can also variable names mask with backtick like:

```swift
let ``in`` : Int
```

#### Map

Java Map is similar to dictionary type in Swift

```java
java.util.Map<String, Double> variable;
```
to    
```swift
var variable : [String: Double]
```

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

##### default methods

Default methods are implemented in a extension, because the mapping of Java interfaces in a Java package like structures need a bit more code. 

#### nested classes

Nested classes in Swift can not access to enclosing type variables. Give the nested class the needed variables as (weak) parameters.

#### new instance

We do not need the `new` keyword to create an instance of type.

#### operator >>>

The operator >>> is implemented. Composite operator like >>>= need to separated

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

#### package

Java packages can be mapped as enum hierachy. Take a look to the CryptoKit, for example MD5 is placed in the enum Insecure and must called with Insecure.MD5
Too add a new _package_ create an enum with same name. Subpackages can be add directly in the enum or maybe better as extension of these enum.

#### shortcuts

Java shortcuts for types need to be translated like

    1d    to    1.0         // double shortcut
    1l    to    Int64(1)    // long shortcut

#### String.format

Replace `String.format` with Swift placeholders like from

```java
String.format("Text %d, more text %s", intValue, stringValue)
```

to

```swift
"Text \(intValue), more text \(stringValue)"
```

#### Swiftify

Swiftify is a JavApi extension. It make additional implementations of Java methods with syntax more like Swift code. It can also implements additional Swift type to use the Java ported code like Swift in other real Swift code.

#### switch

Java cases `fallthrough` by default and need explicite `break` if not. But Java need no `default`. Also newer Java can use `->` instead of `:`.

#### visibility

Swift visiblilities are:

1. private: like Java - symbol visible within the current declaration only. 
2. fileprivate: symbol visible within the current file.
3. internal: like .net - symbol visible within the current module or default access modifier.
4. public: for classes is not identical with Java - symbol visible outside the current module.
5. open: like public in Java - for class or function to be subclassed or overridden outside the current module.

In result of these Java ported classes are by default `open` except they are final then `public`.


----
