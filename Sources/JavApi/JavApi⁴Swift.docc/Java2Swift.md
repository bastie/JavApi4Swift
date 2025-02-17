# Java2Swift

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


#### final

First let `let` the replacement be for `final`. For functions / method parameters the semantic of Java and Swift are "different". In Java you can be declare a parameter as not changeable with `final`. In todays Swift versions all parameteres are final by default, you can use `inout` but the semantic is little different. 

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

But best, rename it before switch to swift.

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

#### visibility

Swift visiblilities are:

1. private: like Java - symbol visible within the current declaration only. 
2. fileprivate: symbol visible within the current file.
3. internal: like .net - symbol visible within the current module or default access modifier.
4. public: for classes is not identical with Java - symbol visible outside the current module.
5. open: like public in Java - for class or function to be subclassed or overridden outside the current module.

In result of these Java ported classes are by default `open` except they are final then `public`.


----
