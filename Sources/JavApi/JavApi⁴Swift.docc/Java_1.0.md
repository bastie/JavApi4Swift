# Java 1.0

<!--
* SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

1995-05-23 the first appeared of Java also called Java birthday.

## Overview


### Compiler directives (expermimental)

By default the lates Java behavior is implemented but checked at runtime against other wishes (over explicit method parameter extension and / or system property). Another way is to set compiler directives to build special Java like version.

- term: Java10Compiler activates static compiling like Java 1.0 behavior
- term: JavaOtherCompiler activates static compiling other than explicit defined Java version (see Java10Compiler)

## Java Documentation

_ based on JDK Documentation at [https://javaalmanac.io](https://javaalmanac.io/jdk/1.0/api/) _

Java 1.0 splits his packages in two parts.

1. **Core Packages**
- term java.lang: the Java language package
- term java.io: the Java input/output package
- term java.net: the Java network specific input/output package 
- term java.util: the Java utilities and data structures package
2. **UI Packages**
- term java.applet: the UI in the browser package
- term java.awt: the native Abstract Window Toolkit UI package 
- term java.awt.image: the Image package for AWT
- term java.awt.peer: the peer package for AWT

### How to read?

- Header type name (count of fields or methods/ count of implemted of them / count of test implemented for them)
- ✔️ yes, is implemented or test is success 😅
- 🪄 no test needed 😜
- ⭕️ implementation or test is missing 😭

> **Note:** Package-private members (default access in Java) are **not** part of the public API and are therefore not ported. Only `public` and `protected` members are in scope for this implementation.

### Java Core packages

#### java.lang

<!-- 11+24+8+5+5+22+23+23+23+32+4+11+7+16+32+48+31+16+41+23+7=412 -->

##### java.lang.VirtualMachineError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | VirtualMachineError() | 


##### java.lang.VerifyError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | VerifyError()  | 


##### java.lang.UnsatisfiedLinkError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | UnsatisfiedLinkError() | 


##### java.lang.UnknownError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | UnknownError() | 


##### java.lang.ThreadDeath (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ThreadDeath()  |


##### java.lang.StringIndexOutOfBoundsException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | StringIndexOutOfBoundsException() | 


##### java.lang.StackOverflowError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | StackOverflowError() | 


##### java.lang.SecurityException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | SecurityException() | 


##### java.lang.RuntimeException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | RuntimeException() | 


##### java.lang.Runnable (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | run()          | () — implemented as Swift `protocol` requirement


##### java.lang.OutOfMemoryError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | OutOfMemoryError() | 


##### java.lang.NumberFormatException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NumberFormatException() | 


##### java.lang.NullPointerException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NullPointerException() | 


##### java.lang.NoSuchMethodException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NoSuchMethodException() | 


##### java.lang.NoSuchMethodError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NoSuchMethodError() | 


##### java.lang.NoSuchFieldError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NoSuchFieldError() | 


##### java.lang.NoClassDefFoundError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NoClassDefFoundError() | 


##### java.lang.NegativeArraySizeException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NegativeArraySizeException() | 


##### java.lang.LinkageError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | LinkageError() | 


##### java.lang.InterruptedException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InterruptedException() | 


##### java.lang.InternalError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InternalError() | 


##### java.lang.InstantiationException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InstantiationException() | 


##### java.lang.InstantiationError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InstantiationError() | 


##### java.lang.IndexOutOfBoundsException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IndexOutOfBoundsException() | 


##### java.lang.IncompatibleClassChangeError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IncompatibleClassChangeError() | 


##### java.lang.IllegalThreadStateException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IllegalThreadStateException() | 


##### java.lang.IllegalMonitorStateException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IllegalMonitorStateException() | 


##### java.lang.IllegalArgumentException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IllegalArgumentException() | 


##### java.lang.IllegalAccessException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IllegalAccessException() | 


##### java.lang.IllegalAccessError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IllegalAccessError() | 


##### java.lang.Exception (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Exception()    |
1.0.2   | ✔️          | ⭕️       | constructor   | Exception(String) |
1.0.2   | ✔️          | ⭕️       | constructor   | Exception(String, Throwable) |
1.0.2   | ✔️          | ⭕️       | constructor   | Exception(Throwable) |


##### java.lang.Error (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Error()        | implemented as `JError` (avoids clash with Swift's `Error` protocol)
1.0.2   | ✔️          | ⭕️       | constructor   | Error(String)  |
1.0.2   | ✔️          | ⭕️       | constructor   | Error(String, Throwable) |
1.0.2   | ✔️          | ⭕️       | constructor   | Error(Throwable) |


##### java.lang.Cloneable (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | interface     | Cloneable      | implemented as Swift `protocol`


##### java.lang.CloneNotSupportedException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | CloneNotSupportedException() | 


##### java.lang.ClassNotFoundException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ClassNotFoundException() | 


##### java.lang.ClassFormatError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ClassFormatError() | 


##### java.lang.ClassCircularityError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ClassCircularityError() | 


##### java.lang.ClassCastException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ClassCastException() | 


##### java.lang.ArrayStoreException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ArrayStoreException() | 


##### java.lang.ArrayIndexOutOfBoundsException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ArrayIndexOutOfBoundsException() | 


##### java.lang.ArithmeticException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ArithmeticException() | 


##### java.lang.AbstractMethodError (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | AbstractMethodError() | 


##### java.lang.Boolean (8/8/⭕️)

<!-- 11 methods+fields, 11 full implemented, 1 test implemented -->

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | Class         | Boolean        | typealias and extension of `Bool`
1.0.2   | ✔️          | ⭕️       | method        | booleanValue() | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | static method | getBoolean()   | (String)->boolean, in result since Java 1.1 it is case insensitive the Java 1.0 case sensitive behavior must be explicit activated
1.1     | ✔️          | ⭕️       | static method | getBoolean()   | (String)->boolean
1.0.2   | ✔️          | ⭕️       | method        | hashcode()     | ()->int
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String
1.0.2   | ✔️          | ⭕️       | static method | valueOf()      | (String)->Boolean

##### java.lang.Character (28/28/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | Class         | Boolean        | typealias and extension of `char`
1.0.2   | ✔️          | ⭕️       | final field   | MAX_RADIX      | 
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | 
1.0.2   | ✔️          | ⭕️       | final field   | MIN_RADIX      | 
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | 
1.0.2   | ✔️          | ⭕️       | method        | charValue()    | ()->Character
1.0.2   | ✔️          | ⭕️       | static method | digit()        | (char,int)->int
1.0.2   | ✔️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | static method | forDigit()     | (char,int)->int
1.1     | ✔️          | ⭕️       | static method | getNumericValue()        | (char)->int
1.0.2   | ✔️          | ⭕️       | method        | hashCode()     | ()->int
1.0.2   | ✔️          | ⭕️       | static method | isDefined()    | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isDigit()      | (char)->boolean
5       | ✔️          | ⭕️       | static method | isDigit()      | (int)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isJavaLetter()           | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isJavaLetterOrDigit()    | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isLetter()               | (char)->boolean
5       | ✔️          | ⭕️       | static method | isLetter()               | (int)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isLetterOrDigit()        | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isLowerCase()            | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isSpace()                | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isTitleCase()            | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isUpperCase()            | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | toLowerCase()            | (char)->char
1.0.2   | ✔️          | ⭕️       | static method | toString()               | ()->String
1.0.2   | ✔️          | ⭕️       | static method | toTitelCase()            | (char)->char
1.0.2   | ✔️          | ⭕️       | static method | toUpperCase()            | (char)->char
1.1     | ✔️          | ⭕️       | static method | isWhiteSpace()           | (char)->boolean


##### java.lang.Class (8/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | static method | forName()      | (String)->Class
1.0.2   | ⭕️          | ⭕️       | method        | getClassLoader()      | ()->ClassLoader
1.0.2   | ⭕️          | ⭕️       | method        | getInterfaces()      | ()->Class[]
1.0.2   | ✔️          | ✔️       | method        | getName()      | ()->String
1.0.2   | ⭕️          | ⭕️       | method        | getSuperclass()      | ()->Class
1.0.2   | ⭕️          | ⭕️       | method        | isInterface()      | ()->boolean
1.0.2   | ⭕️          | ⭕️       | method        | newInstance()      | ()->Object
1.0.2   | ⭕️          | ⭕️       | method        | toString()     | ()->String


##### java.lang.ClassLoader (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | constructor   | ClassLoader()  | no class-loader concept in Swift; not portierbar


##### java.lang.Compiler (6/6/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | static method | initialize()   | () — no-op (deprecated Java 9, removed Java 17)
1.0.2   | ✔️          | ⭕️       | static method | compileClass() | (Class)->boolean
1.0.2   | ✔️          | ⭕️       | static method | compileClasses() | (String)->boolean
1.0.2   | ✔️          | ⭕️       | static method | command()      | (Object)->Object
1.0.2   | ✔️          | ⭕️       | static method | enable()       | ()
1.0.2   | ✔️          | ⭕️       | static method | disable()      | ()


##### java.lang.Double (8/8/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | POSITIVE_INFINITY | double
1.0.2   | ✔️          | ⭕️       | final field   | NEGATIVE_INFINITY | double
1.0.2   | ✔️          | ⭕️       | final field   | NaN            | double
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | double
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | double
1.0.2   | ✔️          | ⭕️       | static method | toString()     | (double)->String
1.0.2   | ✔️          | ⭕️       | static method | valueOf()      | (String)->Double
1.0.2   | ✔️          | ⭕️       | static method | isNaN()        | (double)->boolean


##### java.lang.Float (8/8/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | POSITIVE_INFINITY | float
1.0.2   | ✔️          | ⭕️       | final field   | NEGATIVE_INFINITY | float
1.0.2   | ✔️          | ⭕️       | final field   | NaN            | float
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | float
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | float
1.0.2   | ✔️          | ⭕️       | static method | toString()     | (float)->String
1.0.2   | ✔️          | ⭕️       | static method | valueOf()      | (String)->Float
1.0.2   | ✔️          | ⭕️       | static method | isNaN()        | (float)->boolean


##### java.lang.Integer (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | int
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | int
1.0.2   | ✔️          | ⭕️       | static method | toString()     | (int,int)->String


##### java.lang.Long (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | long
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | long
1.0.2   | ✔️          | ⭕️       | static method | toString()     | (long,int)->String


##### java.lang.Math (17/17/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | PI             | double
1.0.2   | ✔️          | ⭕️       | static method | sin()          | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | cos()          | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | tan()          | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | asin()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | acos()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | atan()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | exp()          | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | log()          | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | sqrt()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | IEEEremainder() | (double,double)->double
1.0.2   | ✔️          | ⭕️       | static method | ceil()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | floor()        | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | rint()         | (double)->double
1.0.2   | ✔️          | ⭕️       | static method | atan2()        | (double,double)->double
1.0.2   | ✔️          | ⭕️       | static method | pow()          | (double,double)->double
1.0.2   | ✔️          | ⭕️       | static method | round()        | (float)->int


##### java.lang.Number (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | intValue()     | ()->int
1.0.2   | ✔️          | ⭕️       | method        | longValue()    | ()->long
1.0.2   | ✔️          | ⭕️       | method        | floatValue()   | ()->float
1.0.2   | ✔️          | ⭕️       | method        | doubleValue()  | ()->double


##### java.lang.Object (3/3/🪄)

Swift has no common `Object` base class. The three Java `Object` methods are handled as follows:

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | method        | getClass()     | ()->Class — Swift's `type(of: self)` is the idiomatic equivalent; a `getClass()` extension on `AnyObject` is possible but not implemented (no use case yet)
1.0.2   | ✔️          | 🪄       | method        | hashCode()     | ()->int — implemented per type (String, Character, Boolean, Long, …) via Swift's `Hashable`
1.0.2   | ✔️          | 🪄       | method        | equals()       | (Object)->boolean — implemented per type; Swift's `Equatable` (`==`) is the idiomatic equivalent


##### java.lang.Process (6/6/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getInputStream()  | ()->InputStream
1.0.2   | ✔️          | ⭕️       | method        | getOutputStream() | ()->OutputStream
1.0.2   | ✔️          | ⭕️       | method        | getErrorStream()  | ()->InputStream
1.0.2   | ✔️          | ⭕️       | method        | waitFor()         | ()->int
1.0.2   | ✔️          | ⭕️       | method        | exitValue()       | ()->int
1.0.2   | ✔️          | ⭕️       | method        | destroy()         | ()


##### java.lang.Runtime (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | static method | getRuntime()   | ()->Runtime


##### java.lang.SecurityManager (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getInCheck()   | ()->boolean


##### java.lang.String (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
| note: Swift's native `String` covers the Java String API; no separate port needed


##### java.lang.StringBuffer (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | StringBuffer() | 


##### java.lang.System (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | static method | setSecurityManager() | (SecurityManager)


##### java.lang.Thread (8/8/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | MIN_PRIORITY   | int
1.0.2   | ✔️          | ⭕️       | final field   | NORM_PRIORITY  | int
1.0.2   | ✔️          | ⭕️       | final field   | MAX_PRIORITY   | int
1.0.2   | ✔️          | ⭕️       | static method | nextThreadNum() | ()->int
1.0.2   | ✔️          | ⭕️       | static method | currentThread() | ()->Thread
1.0.2   | ✔️          | ⭕️       | static method | yield()        | ()
1.0.2   | ✔️          | ⭕️       | static method | sleep()        | (long)
1.0.2   | ✔️          | ⭕️       | static method | sleep()        | (long,int)


##### java.lang.ThreadGroup (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ThreadGroup()  | String


##### java.lang.Throwable (7/7/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Throwable()    |
1.0.2   | ✔️          | ⭕️       | constructor   | Throwable(String) |
1.0.2   | ✔️          | ⭕️       | constructor   | Throwable(String, Throwable) |
1.0.2   | ✔️          | ⭕️       | constructor   | Throwable(Throwable) |
1.0.2   | ✔️          | ⭕️       | method        | getMessage()   | ()->String
1.0.2   | ✔️          | ⭕️       | method        | getLocalizedMessage() | ()->String
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String


#### java.io

##### java.io.UTFDataFormatException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | UTFDataFormatException() | 


##### java.io.StringBufferInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | StringBufferInputStream() | String


##### java.io.StreamTokenizer (10/10/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | lineno()       | ()->int — replaces LINENO field (Java uses method, not field)
1.0.2   | ✔️          | ⭕️       | final field   | CT_WHITESPACE  | byte — public static
1.0.2   | ✔️          | ⭕️       | final field   | CT_ALPHA       | byte — public static
1.0.2   | ✔️          | ⭕️       | final field   | CT_QUOTE       | byte — public static
1.0.2   | ✔️          | ⭕️       | final field   | CT_COMMENT     | byte — public static
1.0.2   | ✔️          | ⭕️       | final field   | TT_EOF         | int
1.0.2   | ✔️          | ⭕️       | final field   | TT_EOL         | int
1.0.2   | ✔️          | ⭕️       | final field   | TT_NUMBER      | int
1.0.2   | ✔️          | ⭕️       | final field   | TT_WORD        | int
1.0.2   | ✔️          | ⭕️       | constructor   | StreamTokenizer() | InputStream


##### java.io.SequenceInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | SequenceInputStream() | Enumeration


##### java.io.RandomAccessFile (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | RandomAccessFile() | String,String


##### java.io.PushbackInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | PushbackInputStream() | InputStream


##### java.io.PrintStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | PrintStream()  | OutputStream


##### java.io.PipedOutputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | PipedOutputStream() | PipedInputStream


##### java.io.PipedInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | PipedInputStream() | PipedOutputStream


##### java.io.OutputStream (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte)


##### java.io.LineNumberInputStream (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | lineNumber     | int
1.0.2   | ✔️          | ⭕️       | field         | markLineNumber | int
1.0.2   | ✔️          | ⭕️       | constructor   | LineNumberInputStream() | InputStream


##### java.io.InterruptedIOException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InterruptedIOException() | 


##### java.io.InputStream (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | read()         | ()->int
1.0.2   | ✔️          | ⭕️       | method        | read()         | (byte)->int
1.0.2   | ✔️          | ⭕️       | method        | read()         | (b,0,b.length)->return


##### java.io.IOException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | IOException()  | 


##### java.io.FilterInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FilterInputStream() | InputStream


##### java.io.FilenameFilter (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | accept()       | (File,String)->boolean


##### java.io.FileNotFoundException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FileNotFoundException() | 


##### java.io.FileInputStream (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FileInputStream() | (File)
1.0.2   | ✔️          | ⭕️       | constructor   | FileInputStream() | (String)
1.0.2   | ✔️          | ⭕️       | method        | read()         | ()->int
1.0.2   | ✔️          | ⭕️       | method        | read()         | (byte[])->int
1.0.2   | ✔️          | ⭕️       | method        | read()         | (byte[],int,int)->int
1.0.2   | ✔️          | ⭕️       | method        | skip()         | (int)->int
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()


##### java.io.File (18/18/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | static field  | separator      | String
1.0.2   | ✔️          | ⭕️       | static field  | separatorChar  | char
1.0.2   | ✔️          | ⭕️       | static field  | pathSeparator  | String
1.0.2   | ✔️          | ⭕️       | static field  | pathSeparatorChar | char
1.0.2   | ✔️          | ⭕️       | constructor   | File()         | (String)
1.0.2   | ✔️          | ⭕️       | constructor   | File()         | (File,String)
1.0.2   | ✔️          | ⭕️       | method        | canExecute()   | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | canRead()      | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | canWrite()     | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | delete()       | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | exists()       | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | getAbsolutePath() | ()->String
1.0.2   | ✔️          | ⭕️       | method        | getName()      | ()->String
1.0.2   | ✔️          | ⭕️       | method        | getPath()      | ()->String
1.0.2   | ✔️          | ⭕️       | method        | isDirectory()  | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | isFile()       | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | isHidden()     | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | lastModified() | ()->long
1.0.2   | ✔️          | ⭕️       | method        | length()       | ()->long
1.0.2   | ✔️          | ⭕️       | method        | list()         | ()->String[]
1.0.2   | ✔️          | ⭕️       | method        | mkdir()        | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | mkdirs()       | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String


##### java.io.EOFException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | EOFException() | 


##### java.io.DataOutputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | DataOutputStream() | OutputStream


##### java.io.DataOutput (14/14/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte,int,int)
1.0.2   | ✔️          | ⭕️       | method        | writeBoolean() | (boolean)
1.0.2   | ✔️          | ⭕️       | method        | writeByte()    | (int)
1.0.2   | ✔️          | ⭕️       | method        | writeShort()   | (int)
1.0.2   | ✔️          | ⭕️       | method        | writeChar()    | (int)
1.0.2   | ✔️          | ⭕️       | method        | writeInt()     | (int)
1.0.2   | ✔️          | ⭕️       | method        | writeLong()    | (long)
1.0.2   | ✔️          | ⭕️       | method        | writeFloat()   | (float)
1.0.2   | ✔️          | ⭕️       | method        | writeDouble()  | (double)
1.0.2   | ✔️          | ⭕️       | method        | writeBytes()   | (String)
1.0.2   | ✔️          | ⭕️       | method        | writeChars()   | (String)
1.0.2   | ✔️          | ⭕️       | method        | writeUTF()     | (String)


##### java.io.DataInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | DataInputStream() | InputStream


##### java.io.ByteArrayOutputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ByteArrayOutputStream() | 


##### java.io.ByteArrayInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ByteArrayInputStream() | byte


##### java.io.BufferedInputStream (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | BufferedInputStream() | InputStream


##### java.io.BufferedOutputStream (5/5/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | BufferedOutputStream | (OutputStream)
1.0.2   | ✔️          | ⭕️       | constructor   | BufferedOutputStream | (OutputStream, Int)
1.0.2   | ✔️          | ⭕️       | method        | flush          | ()
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[],int,int)

##### java.io.DataInput (15/15/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | method        | readBoolean    | ()->boolean
1.0.2   | ✔️          | 🪄       | method        | readByte    | ()->byte
1.0.2   | ✔️          | 🪄       | method        | readChar    | ()->char
1.0.2   | ✔️          | 🪄       | method        | readDouble    | ()->double
1.0.2   | ✔️          | 🪄       | method        | readFloat    | ()->float
1.0.2   | ✔️          | 🪄       | method        | readFully    | (byte[])
1.0.2   | ✔️          | 🪄       | method        | readFully    | (byte[],Int,Int)
1.0.2   | ✔️          | 🪄       | method        | readInt    | ()->int
1.0.2   | ✔️          | 🪄       | method        | readLine    | ()->String
1.0.2   | ✔️          | 🪄       | method        | readLong    | ()->long
1.0.2   | ✔️          | 🪄       | method        | readShort    | ()->short
1.0.2   | ✔️          | 🪄       | method        | readUnsignedByte    | ()->Int
1.0.2   | ✔️          | 🪄       | method        | readUnsignedShort    | ()->Int
1.0.2   | ✔️          | 🪄       | method        | readUTF    | ()->String
1.0.2   | ✔️          | 🪄       | method        | skipBytes    | (Int)

##### java.io.FileDescriptor (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FileDescriptor | ()
1.0.2   | ✔️          | ⭕️       | method        | valid()        | ()->boolean

##### java.io.FileOutputStream (9/9/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FileOutputStream | (File)
1.0.2   | ✔️          | ⭕️       | constructor   | FileOutputStream | (FileDescriptor)
1.0.2   | ✔️          | ⭕️       | constructor   | FileOutputStream | (String)
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()
1.0.2   | ✔️          | ⭕️       | method        | finalize()     | () calls only close()
1.0.2   | ✔️          | ⭕️       | method        | getFD()        | ()->FileDescriptor
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[])
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[],int,int)

##### java.io.FilterOutputStream (6/6/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FilterOutputStream | (OutputStream)
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()
1.0.2   | ✔️          | ⭕️       | method        | flush          | ()
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[])
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[],int,int)


#### java.net

##### java.net.UnknownServiceException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | UnknownServiceException() | 


##### java.net.UnknownHostException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | UnknownHostException() | String


##### java.net.URLStreamHandlerFactory (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | createURLStreamHandler() | (String)->URLStreamHandler


##### java.net.URLStreamHandler (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | openConnection() | (URL)->URLConnection
1.0.2   | ✔️          | ⭕️       | method        | parseURL()     | (URL,String,int,int)


##### java.net.URLEncoder (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | static method | encode()       | (String)->String
1.1     | ✔️          | ⭕️       | static method | encode()       | (String,String)->String


##### java.net.URLConnection (17/17/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | doInput        | boolean — private mit getDoInput()/setDoInput()
1.0.2   | ✔️          | ⭕️       | field         | doOutput       | boolean — private mit getDoOutput()/setDoOutput()
1.0.2   | ✔️          | ⭕️       | static field  | defaultAllowUserInteraction | boolean
1.0.2   | ✔️          | ⭕️       | field         | allowUserInteraction | boolean
1.0.2   | ✔️          | ⭕️       | static field  | defaultUseCaches | boolean
1.0.2   | ✔️          | ⭕️       | field         | useCaches      | boolean — private mit getUseCaches()/setUseCaches()
1.0.2   | ✔️          | ⭕️       | field         | ifModifiedSince | long — wird als If-Modified-Since Header gesendet
1.0.2   | ✔️          | ⭕️       | constructor   | URLConnection() | URL
1.0.2   | ✔️          | ⭕️       | method        | connect()      | ()
1.0.2   | ✔️          | ⭕️       | method        | getAllowUserInteraction() | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | setAllowUserInteraction() | (boolean)
1.0.2   | ✔️          | ⭕️       | static method | getDefaultAllowUserInteraction() | ()->boolean
1.0.2   | ✔️          | ⭕️       | static method | setDefaultAllowUserInteraction() | (boolean)
1.0.2   | ✔️          | ⭕️       | static method | getDefaultUseCaches() | ()->boolean
1.0.2   | ✔️          | ⭕️       | static method | setDefaultUseCaches() | (boolean)
1.0.2   | ✔️          | ⭕️       | method        | getIfModifiedSince() | ()->long
1.0.2   | ✔️          | ⭕️       | method        | setIfModifiedSince() | (long)


##### java.net.URL (4/4/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | URL()          | (String) throws MalformedURLException
1.0.2   | ✔️          | ⭕️       | constructor   | URL()          | String,String,int,String
1.0.2   | ✔️          | ⭕️       | constructor   | URL()          | String,String,String
1.0.2   | ✔️          | ⭕️       | constructor   | URL()          | URL,String — relative URL


##### java.net.SocketOutputStream (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------


##### java.net.SocketInputStream (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------


##### java.net.SocketImplFactory (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | createSocketImpl() | ()->SocketImpl


##### java.net.SocketImpl (11/11/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | create()       | (boolean)
1.0.2   | ✔️          | ⭕️       | method        | connect()      | (String,int)
1.0.2   | ✔️          | ⭕️       | method        | connect()      | (InetAddress,int)
1.0.2   | ✔️          | ⭕️       | method        | bind()         | (InetAddress,int)
1.0.2   | ✔️          | ⭕️       | method        | listen()       | (int)
1.0.2   | ✔️          | ⭕️       | method        | accept()       | (SocketImpl)
1.0.2   | ✔️          | ⭕️       | method        | getInputStream() | ()->InputStream
1.0.2   | ✔️          | ⭕️       | method        | getOutputStream() | ()->OutputStream
1.0.2   | ✔️          | ⭕️       | method        | available()    | ()->int
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()
1.0.2   | ✔️          | ⭕️       | method        | getFileDescriptor() | ()->FileDescriptor


##### java.net.SocketException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | SocketException() | String


##### java.net.Socket (15/15/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Socket()       | ()
1.0.2   | ✔️          | ⭕️       | constructor   | Socket()       | (String,int)
1.0.2   | ✔️          | ⭕️       | constructor   | Socket()       | (InetAddress,int)
1.0.2   | ✔️          | ⭕️       | method        | getInputStream() | ()->InputStream
1.0.2   | ✔️          | ⭕️       | method        | getOutputStream() | ()->OutputStream
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()
1.0.2   | ✔️          | ⭕️       | method        | getInetAddress() | ()->InetAddress
1.0.2   | ✔️          | ⭕️       | method        | getPort()      | ()->int
1.0.2   | ✔️          | ⭕️       | method        | getLocalPort() | ()->int
1.0.2   | ✔️          | ⭕️       | method        | isClosed()     | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | isConnected()  | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | setSoTimeout() | (int)
1.0.2   | ✔️          | ⭕️       | method        | getSoTimeout() | ()->int
1.0.2   | ✔️          | ⭕️       | method        | setSoLinger()  | (boolean,int)
1.0.2   | ✔️          | ⭕️       | method        | getSoLinger()  | ()->int
1.0.2   | ✔️          | ⭕️       | method        | setTcpNoDelay() | (boolean)
1.0.2   | ✔️          | ⭕️       | method        | getTcpNoDelay() | ()->boolean


##### java.net.ServerSocket (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ServerSocket() | ()
1.0.2   | ✔️          | ⭕️       | constructor   | ServerSocket() | int
1.0.2   | ✔️          | ⭕️       | constructor   | ServerSocket() | int,int


##### java.net.ProtocolException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | ProtocolException() | String


##### java.net.PlainSocketImpl (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------


##### java.net.MalformedURLException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | MalformedURLException() | 


##### java.net.InetAddress (9/9/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | InetAddress()  | 
1.0.2   | ✔️          | ⭕️       | constructor   | InetAddress()  | String,byte
1.0.2   | ✔️          | ⭕️       | static method | getByName()    | (String)->InetAddress
1.0.2   | ✔️          | ⭕️       | static method | getAllByName()  | (String)->InetAddress[]
1.0.2   | ✔️          | ⭕️       | static method | getLocalHost() | ()->InetAddress
1.0.2   | ✔️          | ⭕️       | method        | getHostName()  | ()->String
1.0.2   | ✔️          | ⭕️       | method        | getHostAddress() | ()->String
1.0.2   | ✔️          | ⭕️       | method        | getAddress()   | ()->byte[]
1.0.2   | ✔️          | ⭕️       | method        | equals()       | (Object)->boolean


##### java.net.DatagramSocket (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | DatagramSocket() |
1.0.2   | ✔️          | ⭕️       | constructor   | DatagramSocket(int) |
1.0.2   | ✔️          | ⭕️       | constructor   | DatagramSocket(int, InetAddress) |


##### java.net.DatagramPacket (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | DatagramPacket() | byte,int


##### java.net.ContentHandlerFactory (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | createContentHandler() | (String)->ContentHandler — als Swift protocol


##### java.net.ContentHandler (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getContent()   | (URLConnection)->Object


#### java.util

<!-- 11+27+7+2+14+9+2+8+10+5+6+23=124 -->

##### java.util.NoSuchElementException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | NoSuchElementException() | 


##### java.util.EmptyStackException (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | EmptyStackException() | 


##### java.util.BitSet (13/13/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | BitSet()       | ()
1.0.2   | ✔️          | ⭕️       | constructor   | BitSet()       | (int)
1.0.2   | ✔️          | ⭕️       | method        | and()          | (BitSet)
1.0.2   | ✔️          | ⭕️       | method        | clear()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | clone()        | ()->BitSet
1.0.2   | ✔️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | get()          | (int)->boolean
1.0.2   | ✔️          | ⭕️       | method        | hashCode()     | ()->int
1.0.2   | ✔️          | ⭕️       | method        | or()           | (BitSet)
1.0.2   | ✔️          | ⭕️       | method        | set()          | (int)
1.0.2   | ✔️          | ⭕️       | method        | size()         | ()->int
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String
1.0.2   | ✔️          | ⭕️       | method        | xor()          | (BitSet)

##### java.util.Date (27/27/⭕️)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | after()             | (Date)->boolean
1.0.2   | ✔️          | ⭕️       | method        | before()            | (Date)->boolean
1.0.2   | ✔️          | ⭕️       | method        | clone()             | ()->Date
1.0.2   | ✔️          | ⭕️       | method        | compareTo()         | (Date)->int
1.0.2   | ✔️          | ⭕️       | method        | equals()            | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | getDate()           | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getDay()            | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getHours()          | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getMinutes()        | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getMonth()          | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getSeconds()        | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getTime()           | ()->long
1.0.2   | ✔️          | ⭕️       | method        | getTimezoneOffset() | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | getYear()           | ()->int — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | hashCode()          | ()->int
1.0.2   | ✔️          | ⭕️       | static method | parse()             | (String)->long — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setDate()           | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setHours()          | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setMinutes()        | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setMonth()          | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setSeconds()        | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | setTime()           | (long)
1.0.2   | ✔️          | ⭕️       | method        | setYear()           | (int) — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | toGMTString()       | ()->String — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | toLocaleString()    | ()->String — deprecated since 1.1
1.0.2   | ✔️          | ⭕️       | method        | toString()          | ()->String
1.0.2   | ✔️          | ⭕️       | static method | UTC()               | (int,int,int,int,int,int)->long — deprecated since 1.1

##### java.util.Dictionary (7/7/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | elements()     | ()->Enumeration — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | get()          | (Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | isEmpty()      | ()->boolean — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | keys()         | ()->Enumeration — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | put()          | (Object,Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | remove()       | (Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | size()         | ()->int — extension on Swift Dictionary

##### java.util.Enumeration (2/2/⭕️)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ✔️       | method        | hasMoreElements() | ()->boolean
1.0.2   | ✔️          | ✔️       | method        | nextElement()     | ()->Object

##### java.util.Hashtable (12/12/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | clear()        | ()
1.0.2   | ✔️          | ⭕️       | method        | clone()        | ()->Hashtable
1.0.2   | ✔️          | ⭕️       | method        | contains()     | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | containsKey()  | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | elements()     | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | get()          | (Object)->Object
1.0.2   | ✔️          | ⭕️       | method        | isEmpty()      | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | keys()         | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | put()          | (Object,Object)->Object
1.0.2   | ✔️          | ⭕️       | method        | remove()       | (Object)->Object
1.0.2   | ✔️          | ⭕️       | method        | size()         | ()->int
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String

##### java.util.Observable (9/9/⭕️)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | addObserver()     | (Observer)
1.0.2   | ✔️          | ⭕️       | method        | clearChanged()    | ()
1.0.2   | ✔️          | ⭕️       | method        | countObservers()  | ()->int
1.0.2   | ✔️          | ⭕️       | method        | deleteObserver()  | (Observer)
1.0.2   | ✔️          | ⭕️       | method        | deleteObservers() | ()
1.0.2   | ✔️          | ⭕️       | method        | hasChanged()      | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | notifyObservers() | ()
1.0.2   | ✔️          | ⭕️       | method        | notifyObservers() | (Object)
1.0.2   | ✔️          | ⭕️       | method        | setChanged()      | ()

##### java.util.Observer (2/2/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | update()       | (Observable,Object)
1.0.2   | ✔️          | 🪄       | method        | hashCode()     | ()->int — default via ObjectIdentifier for class types

##### java.util.Properties (7/7/⭕️)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getProperty()     | (String)->String
1.0.2   | ✔️          | ⭕️       | method        | getProperty()     | (String,String)->String
1.0.2   | ✔️          | ⭕️       | method        | list()            | (PrintStream)
1.0.2   | ✔️          | ⭕️       | method        | load()            | (InputStream)
1.0.2   | ✔️          | ⭕️       | method        | propertyNames()   | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | save()            | (OutputStream,String) — deprecated since 1.2, use store()
1.0.2   | ✔️          | ⭕️       | method        | setProperty()     | (String,String)->Object

##### java.util.Random (9/9/⭕️)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ✔️       | method        | nextBoolean()     | ()->boolean
1.0.2   | ✔️          | ✔️       | method        | nextBytes()       | (byte[])
1.0.2   | ✔️          | ✔️       | method        | nextDouble()      | ()->double
1.0.2   | ✔️          | ✔️       | method        | nextFloat()       | ()->float
1.0.2   | ✔️          | ✔️       | method        | nextGaussian()    | ()->double
1.0.2   | ✔️          | ✔️       | method        | nextInt()         | ()->int
1.0.2   | ✔️          | ✔️       | method        | nextInt()         | (int)->int
1.0.2   | ✔️          | ✔️       | method        | nextLong()        | ()->long
1.0.2   | ✔️          | ✔️       | method        | setSeed()         | (long)

##### java.util.Stack (5/5/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | empty()        | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | peek()         | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | pop()          | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | push()         | (Object)->Object
1.0.2   | ✔️          | ✔️       | method        | search()       | (Object)->int

##### java.util.StringTokenizer (9/9/⭕️)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | StringTokenizer() | (String)
1.0.2   | ✔️          | ⭕️       | constructor   | StringTokenizer() | (String,String)
1.0.2   | ✔️          | ⭕️       | constructor   | StringTokenizer() | (String,String,boolean)
1.0.2   | ✔️          | ⭕️       | method        | countTokens()     | ()->int
1.0.2   | ✔️          | ⭕️       | method        | hasMoreElements() | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | hasMoreTokens()   | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | nextElement()     | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | nextToken()       | ()->String
1.0.2   | ✔️          | ⭕️       | method        | nextToken()       | (String)->String

##### java.util.Vector (23/23/⭕️)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | addElement()        | (Object)
1.0.2   | ✔️          | ⭕️       | method        | capacity()          | ()->int
1.0.2   | ✔️          | ⭕️       | method        | contains()          | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | copyInto()          | (Object[])
1.0.2   | ✔️          | ⭕️       | method        | elementAt()         | (int)->Object
1.0.2   | ✔️          | ⭕️       | method        | elements()          | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | ensureCapacity()    | (int)
1.0.2   | ✔️          | ⭕️       | method        | firstElement()      | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | indexOf()           | (Object)->int
1.0.2   | ✔️          | ⭕️       | method        | indexOf()           | (Object,int)->int
1.0.2   | ✔️          | ⭕️       | method        | insertElementAt()   | (Object,int)
1.0.2   | ✔️          | ⭕️       | method        | isEmpty()           | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | lastElement()       | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | lastIndexOf()       | (Object)->int
1.0.2   | ✔️          | ⭕️       | method        | lastIndexOf()       | (Object,int)->int
1.0.2   | ✔️          | ⭕️       | method        | removeAllElements() | ()
1.0.2   | ✔️          | ⭕️       | method        | removeElement()     | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | method        | removeElementAt()   | (int)
1.0.2   | ✔️          | ⭕️       | method        | setElementAt()      | (Object,int)
1.0.2   | ✔️          | ⭕️       | method        | setSize()           | (int)
1.0.2   | ✔️          | ⭕️       | method        | size()              | ()->int
1.0.2   | ✔️          | ⭕️       | method        | toString()          | ()->String
1.0.2   | ✔️          | ⭕️       | method        | trimToSize()        | ()

#### java.applet


##### java.applet.AudioClip (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | play()         | ()
1.0.2   | ✔️          | ⭕️       | method        | loop()         | ()
1.0.2   | ✔️          | ⭕️       | method        | stop()         | ()


##### java.applet.AppletStub (6/6/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | isActive()     | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | getDocumentBase() | ()->URL
1.0.2   | ✔️          | ⭕️       | method        | getCodeBase()  | ()->URL
1.0.2   | ✔️          | ⭕️       | method        | getParameter() | (String)->String
1.0.2   | ✔️          | ⭕️       | method        | getAppletContext() | ()->AppletContext
1.0.2   | ✔️          | ⭕️       | method        | appletResize() | (int,int)


##### java.applet.AppletContext (7/7/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getAudioClip() | (URL)->AudioClip
1.0.2   | ✔️          | ⭕️       | method        | getImage()     | (URL)->Image
1.0.2   | ✔️          | ⭕️       | method        | getApplet()    | (String)->Applet
1.0.2   | ✔️          | ⭕️       | method        | getApplets()   | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | showDocument() | (URL)
1.0.2   | ✔️          | ⭕️       | method        | showDocument() | (URL,String)
1.0.2   | ✔️          | ⭕️       | method        | showStatus()   | (String)


##### java.applet.Applet (1/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | setStub()      | (AppletStub)

#### java.awt


##### java.awt.Window (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Window         | implemented as Container subclass with setVisible, dispose, pack, toFront, toBack


##### java.awt.Toolkit (7/1/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | getScreenSize() | ()->Dimension
1.0.2   | ⭕️          | ⭕️       | method        | getScreenResolution() | ()->int
1.0.2   | ⭕️          | ⭕️       | method        | getColorModel() | ()->ColorModel
1.0.2   | ⭕️          | ⭕️       | method        | getFontList()  | ()->String[]
1.0.2   | ⭕️          | ⭕️       | method        | getFontMetrics() | (Font)->FontMetrics
1.0.2   | ⭕️          | ⭕️       | method        | sync()         | ()
1.0.2   | ✔️          | ⭕️       | static method | getDefaultToolkit() | ()->Toolkit


##### java.awt.TextField (2/2/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | echoChar       | char
1.0.2   | ✔️          | ⭕️       | constructor   | TextField()    | 


##### java.awt.TextComponent (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | TextComponent() | String


##### java.awt.TextArea (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | TextArea()     | 


##### java.awt.Scrollbar (2/2/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | HORIZONTAL     | int
1.0.2   | ✔️          | ⭕️       | final field   | VERTICAL       | int


##### java.awt.Rectangle (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Rectangle      | implemented with x,y,width,height fields, constructors, contains, intersects, union, etc.


##### java.awt.Polygon (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Polygon        | implemented with npoints, xpoints, ypoints, addPoint, contains, getBoundingBox


##### java.awt.Point (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Point          | implemented with x,y fields, constructors, distance, equals, translate


##### java.awt.Panel (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Panel          | implemented as Container subclass


##### java.awt.MenuItem (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | MenuItem()     | String


##### java.awt.MenuContainer (3/2/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getFont()      | ()->Font
1.0.2   | ⭕️          | ⭕️       | method        | postEvent()    | (Event)->boolean
1.0.2   | ✔️          | ⭕️       | method        | remove()       | (MenuComponent)


##### java.awt.MenuComponent (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getParent()    | ()->MenuContainer — via open class MenuComponent


##### java.awt.MenuBar (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | MenuBar()      | 


##### java.awt.Menu (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | tearOff        | boolean


##### java.awt.MediaTracker (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | constructor   | MediaTracker() | Component — headless: images always COMPLETE
1.0.2   | ✔️          | 🪄       | static field  | LOADING        | int
1.0.2   | ✔️          | 🪄       | static field  | ABORTED        | int
1.0.2   | ✔️          | 🪄       | static field  | ERRORED        | int
1.0.2   | ✔️          | 🪄       | static field  | COMPLETE       | int
1.0.2   | ✔️          | 🪄       | method        | addImage()     | (Image,int)
1.0.2   | ✔️          | 🪄       | method        | addImage()     | (Image,int,int,int)
1.0.2   | ✔️          | 🪄       | method        | checkAll()     | ()->boolean
1.0.2   | ✔️          | 🪄       | method        | checkID()      | (int)->boolean
1.0.2   | ✔️          | 🪄       | method        | statusAll()    | (boolean)->int
1.0.2   | ✔️          | 🪄       | method        | statusID()     | (int,boolean)->int
1.0.2   | ✔️          | 🪄       | method        | waitForAll()   | ()
1.0.2   | ✔️          | 🪄       | method        | waitForAll()   | (long)->boolean
1.0.2   | ✔️          | 🪄       | method        | waitForID()    | (int)
1.0.2   | ✔️          | 🪄       | method        | waitForID()    | (int,long)->boolean
1.0.2   | ✔️          | 🪄       | method        | getErrorsAny() | ()->Object[]
1.0.2   | ✔️          | 🪄       | method        | getErrorsID()  | (int)->Object[]
1.0.2   | ✔️          | 🪄       | method        | isErrorAny()   | ()->boolean
1.0.2   | ✔️          | 🪄       | method        | isErrorID()    | (int)->boolean


##### java.awt.List (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | List           | implemented as Component subclass with add, select, getSelectedItem, ItemListener, ActionListener


##### java.awt.LayoutManager (5/5/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | addLayoutComponent() | (String,Component)
1.0.2   | ✔️          | ⭕️       | method        | removeLayoutComponent() | (Component)
1.0.2   | ✔️          | ⭕️       | method        | preferredLayoutSize() | (Container)->Dimension
1.0.2   | ✔️          | ⭕️       | method        | minimumLayoutSize() | (Container)->Dimension
1.0.2   | ✔️          | ⭕️       | method        | layoutContainer() | (Container)


##### java.awt.Label (3/3/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | LEFT           | int
1.0.2   | ✔️          | ⭕️       | final field   | CENTER         | int
1.0.2   | ✔️          | ⭕️       | final field   | RIGHT          | int


##### java.awt.Insets (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Insets         | implemented with top,left,bottom,right fields, constructors, clone, equals


##### java.awt.Image (6/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getWidth()     | (ImageObserver)->int
1.0.2   | ✔️          | ⭕️       | method        | getHeight()    | (ImageObserver)->int
1.0.2   | ⭕️          | ⭕️       | method        | getSource()    | ()->ImageProducer
1.0.2   | ⭕️          | ⭕️       | method        | getGraphics()  | ()->Graphics
1.0.2   | ⭕️          | ⭕️       | method        | getProperty()  | (String,ImageObserver)->Object
1.0.2   | ✔️          | ⭕️       | method        | flush()        | ()


##### java.awt.GridLayout (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | GridLayout()   | int,int


##### java.awt.GridBagLayout (4/4/✔️)

See Java_1.1.md for full implementation notes (Step 1 complete).

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | final field   | MAXGRIDSIZE    | int
1.0.2   | ✔️          | 🪄       | final field   | MINSIZE        | int
1.0.2   | ✔️          | 🪄       | final field   | PREFERREDSIZE  | int
1.0.2   | ✔️          | ⭕️       | constructor   | GridBagLayout() | 


##### java.awt.GridBagConstraints (15/15/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | final field   | RELATIVE       | int
1.0.2   | ✔️          | 🪄       | final field   | REMAINDER      | int
1.0.2   | ✔️          | 🪄       | final field   | NONE           | int
1.0.2   | ✔️          | 🪄       | final field   | BOTH           | int
1.0.2   | ✔️          | 🪄       | final field   | HORIZONTAL     | int
1.0.2   | ✔️          | 🪄       | final field   | VERTICAL       | int
1.0.2   | ✔️          | 🪄       | final field   | CENTER         | int
1.0.2   | ✔️          | 🪄       | final field   | NORTH          | int
1.0.2   | ✔️          | 🪄       | final field   | NORTHEAST      | int
1.0.2   | ✔️          | 🪄       | final field   | EAST           | int
1.0.2   | ✔️          | 🪄       | final field   | SOUTHEAST      | int
1.0.2   | ✔️          | 🪄       | final field   | SOUTH          | int
1.0.2   | ✔️          | 🪄       | final field   | SOUTHWEST      | int
1.0.2   | ✔️          | 🪄       | final field   | WEST           | int
1.0.2   | ✔️          | 🪄       | final field   | NORTHWEST      | int


##### java.awt.Graphics (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Graphics       | implemented mapped to CGContext (canImport(CoreGraphics))


##### java.awt.Frame (14/14/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | DEFAULT_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | CROSSHAIR_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | TEXT_CURSOR    | int
1.0.2   | ✔️          | ⭕️       | final field   | WAIT_CURSOR    | int
1.0.2   | ✔️          | ⭕️       | final field   | SW_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | SE_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | NW_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | NE_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | N_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | S_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | W_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | E_RESIZE_CURSOR | int
1.0.2   | ✔️          | ⭕️       | final field   | HAND_CURSOR    | int
1.0.2   | ✔️          | ⭕️       | final field   | MOVE_CURSOR    | int


##### java.awt.FontMetrics (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | FontMetrics()  | Font


##### java.awt.Font (3/3/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | PLAIN          | int
1.0.2   | ✔️          | ⭕️       | final field   | BOLD           | int
1.0.2   | ✔️          | ⭕️       | final field   | ITALIC         | int


##### java.awt.FlowLayout (3/3/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | LEFT           | int
1.0.2   | ✔️          | ⭕️       | final field   | CENTER         | int
1.0.2   | ✔️          | ⭕️       | final field   | RIGHT          | int


##### java.awt.FileDialog (3/3/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | LOAD           | int
1.0.2   | ✔️          | ⭕️       | final field   | SAVE           | int
1.0.2   | ✔️          | ⭕️       | constructor   | FileDialog()   | Frame,String


##### java.awt.Event (58/52/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | final field   | SHIFT_MASK     | int
1.0.2   | ✔️          | ⭕️       | final field   | CTRL_MASK      | int
1.0.2   | ✔️          | ⭕️       | final field   | META_MASK      | int
1.0.2   | ✔️          | ⭕️       | final field   | ALT_MASK       | int
1.0.2   | ✔️          | ⭕️       | final field   | HOME           | int
1.0.2   | ✔️          | ⭕️       | final field   | END            | int
1.0.2   | ✔️          | ⭕️       | final field   | PGUP           | int
1.0.2   | ✔️          | ⭕️       | final field   | PGDN           | int
1.0.2   | ✔️          | ⭕️       | final field   | UP             | int
1.0.2   | ✔️          | ⭕️       | final field   | DOWN           | int
1.0.2   | ✔️          | ⭕️       | final field   | LEFT           | int
1.0.2   | ✔️          | ⭕️       | final field   | RIGHT          | int
1.0.2   | ✔️          | ⭕️       | final field   | F1             | int
1.0.2   | ✔️          | ⭕️       | final field   | F2             | int
1.0.2   | ✔️          | ⭕️       | final field   | F3             | int
1.0.2   | ✔️          | ⭕️       | final field   | F4             | int
1.0.2   | ✔️          | ⭕️       | final field   | F5             | int
1.0.2   | ✔️          | ⭕️       | final field   | F6             | int
1.0.2   | ✔️          | ⭕️       | final field   | F7             | int
1.0.2   | ✔️          | ⭕️       | final field   | F8             | int
1.0.2   | ✔️          | ⭕️       | final field   | F9             | int
1.0.2   | ✔️          | ⭕️       | final field   | F10            | int
1.0.2   | ✔️          | ⭕️       | final field   | F11            | int
1.0.2   | ✔️          | ⭕️       | final field   | F12            | int
1.0.2   | ⭕️          | ⭕️       | final field   | WINDOW_EVENT   | int
1.0.2   | ✔️          | ⭕️       | final field   | WINDOW_DESTROY | int
1.0.2   | ✔️          | ⭕️       | final field   | WINDOW_EXPOSE  | int
1.0.2   | ✔️          | ⭕️       | final field   | WINDOW_ICONIFY | int
1.0.2   | ✔️          | ⭕️       | final field   | WINDOW_DEICONIFY | int
1.0.2   | ✔️          | ⭕️       | final field   | WINDOW_MOVED   | int
1.0.2   | ⭕️          | ⭕️       | final field   | KEY_EVENT      | int
1.0.2   | ✔️          | ⭕️       | final field   | KEY_PRESS      | int
1.0.2   | ✔️          | ⭕️       | final field   | KEY_RELEASE    | int
1.0.2   | ✔️          | ⭕️       | final field   | KEY_ACTION     | int
1.0.2   | ✔️          | ⭕️       | final field   | KEY_ACTION_RELEASE | int
1.0.2   | ⭕️          | ⭕️       | final field   | MOUSE_EVENT    | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_DOWN     | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_UP       | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_MOVE     | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_ENTER    | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_EXIT     | int
1.0.2   | ✔️          | ⭕️       | final field   | MOUSE_DRAG     | int
1.0.2   | ⭕️          | ⭕️       | final field   | SCROLL_EVENT   | int
1.0.2   | ✔️          | ⭕️       | final field   | SCROLL_LINE_UP | int
1.0.2   | ✔️          | ⭕️       | final field   | SCROLL_LINE_DOWN | int
1.0.2   | ✔️          | ⭕️       | final field   | SCROLL_PAGE_UP | int
1.0.2   | ✔️          | ⭕️       | final field   | SCROLL_PAGE_DOWN | int
1.0.2   | ✔️          | ⭕️       | final field   | SCROLL_ABSOLUTE | int
1.0.2   | ⭕️          | ⭕️       | final field   | LIST_EVENT     | int
1.0.2   | ✔️          | ⭕️       | final field   | LIST_SELECT    | int
1.0.2   | ✔️          | ⭕️       | final field   | LIST_DESELECT  | int
1.0.2   | ⭕️          | ⭕️       | final field   | MISC_EVENT     | int
1.0.2   | ✔️          | ⭕️       | final field   | ACTION_EVENT   | int
1.0.2   | ✔️          | ⭕️       | final field   | LOAD_FILE      | int
1.0.2   | ✔️          | ⭕️       | final field   | SAVE_FILE      | int
1.0.2   | ✔️          | ⭕️       | final field   | GOT_FOCUS      | int
1.0.2   | ✔️          | ⭕️       | final field   | LOST_FOCUS     | int
1.0.2   | ✔️          | ⭕️       | field         | clickCount     | int


##### java.awt.Dimension (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Dimension      | implemented with width,height fields, constructors, equals, getSize, setSize, toString


##### java.awt.Dialog (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Dialog         | implemented as Window subclass with modal support


##### java.awt.Container (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | countComponents() | ()->int — via children.count


##### java.awt.Cursor (15/15/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.1     | ✔️          | ⭕️       | final field   | DEFAULT_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | CROSSHAIR_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | TEXT_CURSOR    | int
1.1     | ✔️          | ⭕️       | final field   | WAIT_CURSOR    | int
1.1     | ✔️          | ⭕️       | final field   | SW_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | SE_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | NW_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | NE_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | N_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | S_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | W_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | E_RESIZE_CURSOR | int
1.1     | ✔️          | ⭕️       | final field   | HAND_CURSOR    | int
1.1     | ✔️          | ⭕️       | final field   | MOVE_CURSOR    | int
1.1     | ✔️          | ⭕️       | static method | getPredefinedCursor() | (int)->Cursor
1.1     | ✔️          | ⭕️       | static method | getDefaultCursor() | ()->Cursor
1.1     | ✔️          | ⭕️       | constructor   | Cursor()       | int
1.1     | ✔️          | ⭕️       | method        | getName()      | ()->String


##### java.awt.Component (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | getParent()    | ()->Container


##### java.awt.Color (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Color          | implemented with RGB constants, constructors, getRGB, brighter, darker


##### java.awt.Choice (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Choice         | implemented as Component subclass with add, select, getSelectedItem, getItemCount


##### java.awt.CheckboxMenuItem (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | CheckboxMenuItem() | String


##### java.awt.CheckboxGroup (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | CheckboxGroup() | 


##### java.awt.Checkbox (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Checkbox       | implemented as Component subclass with label, state, CheckboxGroup, ItemListener


##### java.awt.CardLayout (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | CardLayout()   | 


##### java.awt.Canvas (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Canvas         | implemented as Component subclass with paint()


##### java.awt.Button (0/0/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | class         | Button         | implemented as Component subclass with label, ActionListener, actionCommand


##### java.awt.BorderLayout (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | BorderLayout() | 


##### java.awt.AWTException (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | AWTException() | String


##### java.awt.AWTError (1/1/✔️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | AWTError()     | String

#### java.awt.image


##### java.awt.image.RGBImageFilter (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | canFilterIndexColorModel | boolean
1.0.2   | ⭕️          | ⭕️       | method        | setColorModel() | (ColorModel)


##### java.awt.image.PixelGrabber (12/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | dstX           | int
1.0.2   | ⭕️          | ⭕️       | field         | dstY           | int
1.0.2   | ⭕️          | ⭕️       | field         | dstW           | int
1.0.2   | ⭕️          | ⭕️       | field         | dstH           | int
1.0.2   | ⭕️          | ⭕️       | field         | dstOff         | int
1.0.2   | ⭕️          | ⭕️       | field         | dstScan        | int
1.0.2   | ⭕️          | ⭕️       | field         | GRABBEDBITS    | int
1.0.2   | ⭕️          | ⭕️       | field         | DONEBITS       | int
1.0.2   | ⭕️          | ⭕️       | field         | h,             | int
1.0.2   | ⭕️          | ⭕️       | field         | h,             | int
1.0.2   | ⭕️          | ⭕️       | method        | grabPixels()   | ()->boolean
1.0.2   | ⭕️          | ⭕️       | method        | grabPixels()   | (0)->return


##### java.awt.image.MemoryImageSource (6/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | cm,            | int
1.0.2   | ⭕️          | ⭕️       | field         | cm,            | int
1.0.2   | ⭕️          | ⭕️       | field         | cm,            | int
1.0.2   | ⭕️          | ⭕️       | field         | cm,            | int
1.0.2   | ⭕️          | ⭕️       | field         | cm,            | void
1.0.2   | ⭕️          | ⭕️       | constructor   | MemoryImageSource() | int,int,int,int,int


##### java.awt.image.IndexColorModel (8/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | map_size       | int
1.0.2   | ⭕️          | ⭕️       | field         | transparent_index | int
1.0.2   | ⭕️          | ⭕️       | field         | size,          | int
1.0.2   | ⭕️          | ⭕️       | field         | size,          | int
1.0.2   | ⭕️          | ⭕️       | field         | size,          | int
1.0.2   | ⭕️          | ⭕️       | field         | start,         | int
1.0.2   | ⭕️          | ⭕️       | field         | start,         | int
1.0.2   | ⭕️          | ⭕️       | method        | getMapSize()   | ()->int


##### java.awt.image.ImageProducer (5/5/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | addConsumer()  | (ImageConsumer)
1.0.2   | ✔️          | ⭕️       | method        | isConsumer()   | (ImageConsumer)->boolean
1.0.2   | ✔️          | ⭕️       | method        | removeConsumer() | (ImageConsumer)
1.0.2   | ✔️          | ⭕️       | method        | startProduction() | (ImageConsumer)
1.0.2   | ✔️          | ⭕️       | method        | requestTopDownLeftRightResend() | (ImageConsumer)


##### java.awt.image.ImageObserver (9/8/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | infoflags,     | boolean
1.0.2   | ✔️          | ⭕️       | final field   | WIDTH          | int
1.0.2   | ✔️          | ⭕️       | final field   | HEIGHT         | int
1.0.2   | ✔️          | ⭕️       | final field   | PROPERTIES     | int
1.0.2   | ✔️          | ⭕️       | final field   | SOMEBITS       | int
1.0.2   | ✔️          | ⭕️       | final field   | FRAMEBITS      | int
1.0.2   | ✔️          | ⭕️       | final field   | ALLBITS        | int
1.0.2   | ✔️          | ⭕️       | final field   | ERROR          | int
1.0.2   | ✔️          | ⭕️       | final field   | ABORT          | int


##### java.awt.image.ImageFilter (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | getFilterInstance() | (ImageConsumer)->ImageFilter


##### java.awt.image.ImageConsumer (18/18/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | 🪄       | field         | RANDOMPIXELORDER | int
1.0.2   | ✔️          | 🪄       | field         | TOPDOWNLEFTRIGHT | int
1.0.2   | ✔️          | 🪄       | field         | COMPLETESCANLINES | int
1.0.2   | ✔️          | 🪄       | field         | SINGLEPASS     | int
1.0.2   | ✔️          | 🪄       | field         | SINGLEFRAME    | int
1.0.2   | ✔️          | 🪄       | method        | setPixels()    | (int,int,int,int,ColorModel,byte[],int,int)
1.0.2   | ✔️          | 🪄       | method        | setPixels()    | (int,int,int,int,ColorModel,int[],int,int)
1.0.2   | ✔️          | 🪄       | field         | IMAGEERROR     | int
1.0.2   | ✔️          | 🪄       | field         | SINGLEFRAMEDONE | int
1.0.2   | ✔️          | 🪄       | field         | STATICIMAGEDONE | int
1.0.2   | ✔️          | 🪄       | field         | IMAGEABORTED   | int
1.0.2   | ✔️          | ⭕️       | method        | setDimensions() | (int,int)
1.0.2   | ✔️          | ⭕️       | method        | setProperties() | (Hashtable)
1.0.2   | ✔️          | ⭕️       | method        | setColorModel() | (ColorModel)
1.0.2   | ✔️          | ⭕️       | method        | setHints()     | (int)
1.0.2   | ✔️          | ⭕️       | method        | imageComplete() | (int)


##### java.awt.image.FilteredImageSource (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | constructor   | FilteredImageSource() | ImageProducer,ImageFilter


##### java.awt.image.CropImageFilter (9/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | cropX          | int
1.0.2   | ⭕️          | ⭕️       | field         | cropY          | int
1.0.2   | ⭕️          | ⭕️       | field         | cropW          | int
1.0.2   | ⭕️          | ⭕️       | field         | cropH          | int
1.0.2   | ⭕️          | ⭕️       | field         | cropX          | 
1.0.2   | ⭕️          | ⭕️       | field         | cropY          | 
1.0.2   | ⭕️          | ⭕️       | field         | cropW          | 
1.0.2   | ⭕️          | ⭕️       | field         | cropH          | 
1.0.2   | ⭕️          | ⭕️       | constructor   | CropImageFilter() | int,int,int,int


##### java.awt.image.ColorModel (3/3/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | pixel_bits     | int
1.0.2   | ✔️          | ⭕️       | static field  | RGBdefault     | ColorModel
1.0.2   | ✔️          | ⭕️       | static method | getRGBdefault() | ()->ColorModel

##### java.awt.image.DirectColorModel (15/15/⭕️)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | red_mask       | int
1.0.2   | ✔️          | ⭕️       | field         | green_mask     | int
1.0.2   | ✔️          | ⭕️       | field         | blue_mask      | int
1.0.2   | ✔️          | ⭕️       | field         | alpha_mask     | int
1.0.2   | ✔️          | ⭕️       | field         | red_offset     | int
1.0.2   | ✔️          | ⭕️       | field         | green_offset   | int
1.0.2   | ✔️          | ⭕️       | field         | blue_offset    | int
1.0.2   | ✔️          | ⭕️       | field         | alpha_offset   | int
1.0.2   | ✔️          | ⭕️       | field         | red_bits       | int
1.0.2   | ✔️          | ⭕️       | field         | green_bits     | int
1.0.2   | ✔️          | ⭕️       | field         | blue_bits      | int
1.0.2   | ✔️          | ⭕️       | field         | alpha_bits     | int
1.0.2   | ✔️          | ⭕️       | constructor   | DirectColorModel() | (int,int,int,int)
1.0.2   | ✔️          | ⭕️       | constructor   | DirectColorModel() | (int,int,int,int,int)
1.0.2   | ✔️          | ⭕️       | method        | getRedMask()   | ()->int

#### java.awt.peer


##### java.awt.peer.WindowPeer (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | toFront()      | ()
1.0.2   | ⭕️          | ⭕️       | method        | toBack()       | ()


##### java.awt.peer.TextFieldPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setEchoCharacter() | (char)
1.0.2   | ⭕️          | ⭕️       | method        | preferredSize() | (int)->Dimension
1.0.2   | ⭕️          | ⭕️       | method        | minimumSize()  | (int)->Dimension


##### java.awt.peer.TextComponentPeer (6/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setEditable()  | (boolean)
1.0.2   | ⭕️          | ⭕️       | method        | getText()      | ()->String
1.0.2   | ⭕️          | ⭕️       | method        | setText()      | (String)
1.0.2   | ⭕️          | ⭕️       | method        | getSelectionStart() | ()->int
1.0.2   | ⭕️          | ⭕️       | method        | getSelectionEnd() | ()->int
1.0.2   | ⭕️          | ⭕️       | method        | select()       | (int,int)


##### java.awt.peer.TextAreaPeer (4/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | insertText()   | (String,int)
1.0.2   | ⭕️          | ⭕️       | method        | replaceText()  | (String,int,int)
1.0.2   | ⭕️          | ⭕️       | method        | preferredSize() | (int,int)->Dimension
1.0.2   | ⭕️          | ⭕️       | method        | minimumSize()  | (int,int)->Dimension


##### java.awt.peer.ScrollbarPeer (4/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setValue()     | (int)
1.0.2   | ⭕️          | ⭕️       | method        | setValues()    | (int,int,int,int)
1.0.2   | ⭕️          | ⭕️       | method        | setLineIncrement() | (int)
1.0.2   | ⭕️          | ⭕️       | method        | setPageIncrement() | (int)


##### java.awt.peer.PanelPeer (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------


##### java.awt.peer.MenuPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | addSeparator() | ()
1.0.2   | ⭕️          | ⭕️       | method        | addItem()      | (MenuItem)
1.0.2   | ⭕️          | ⭕️       | method        | delItem()      | (int)


##### java.awt.peer.MenuItemPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setLabel()     | (String)
1.0.2   | ⭕️          | ⭕️       | method        | enable()       | ()
1.0.2   | ⭕️          | ⭕️       | method        | disable()      | ()


##### java.awt.peer.MenuComponentPeer (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | dispose()      | ()


##### java.awt.peer.MenuBarPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | addMenu()      | (Menu)
1.0.2   | ⭕️          | ⭕️       | method        | delMenu()      | (int)
1.0.2   | ⭕️          | ⭕️       | method        | addHelpMenu()  | (Menu)


##### java.awt.peer.ListPeer (10/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | getSelectedIndexes() | ()->int[]
1.0.2   | ⭕️          | ⭕️       | method        | addItem()      | (String,int)
1.0.2   | ⭕️          | ⭕️       | method        | delItems()     | (int,int)
1.0.2   | ⭕️          | ⭕️       | method        | clear()        | ()
1.0.2   | ⭕️          | ⭕️       | method        | select()       | (int)
1.0.2   | ⭕️          | ⭕️       | method        | deselect()     | (int)
1.0.2   | ⭕️          | ⭕️       | method        | makeVisible()  | (int)
1.0.2   | ⭕️          | ⭕️       | method        | setMultipleSelections() | (boolean)
1.0.2   | ⭕️          | ⭕️       | method        | preferredSize() | (int)->Dimension
1.0.2   | ⭕️          | ⭕️       | method        | minimumSize()  | (int)->Dimension


##### java.awt.peer.LabelPeer (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setText()      | (String)
1.0.2   | ⭕️          | ⭕️       | method        | setAlignment() | (int)


##### java.awt.peer.FramePeer (5/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setTitle()     | (String)
1.0.2   | ⭕️          | ⭕️       | method        | setIconImage() | (Image)
1.0.2   | ⭕️          | ⭕️       | method        | setMenuBar()   | (MenuBar)
1.0.2   | ⭕️          | ⭕️       | method        | setResizable() | (boolean)
1.0.2   | ⭕️          | ⭕️       | method        | setCursor()    | (int)


##### java.awt.peer.FileDialogPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setFile()      | (String)
1.0.2   | ⭕️          | ⭕️       | method        | setDirectory() | (String)
1.0.2   | ⭕️          | ⭕️       | method        | setFilenameFilter() | (FilenameFilter)


##### java.awt.peer.DialogPeer (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setTitle()     | (String)
1.0.2   | ⭕️          | ⭕️       | method        | setResizable() | (boolean)


##### java.awt.peer.ContainerPeer (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | insets()       | ()->Insets


##### java.awt.peer.ComponentPeer (24/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | show()         | ()
1.0.2   | ⭕️          | ⭕️       | method        | hide()         | ()
1.0.2   | ⭕️          | ⭕️       | method        | enable()       | ()
1.0.2   | ⭕️          | ⭕️       | method        | disable()      | ()
1.0.2   | ⭕️          | ⭕️       | method        | paint()        | (Graphics)
1.0.2   | ⭕️          | ⭕️       | method        | repaint()      | (long,int,int,int,int)
1.0.2   | ⭕️          | ⭕️       | method        | print()        | (Graphics)
1.0.2   | ⭕️          | ⭕️       | method        | reshape()      | (int,int,int,int)
1.0.2   | ⭕️          | ⭕️       | method        | handleEvent()  | (Event)
1.0.2   | ⭕️          | ⭕️       | method        | minimumSize()  | ()
1.0.2   | ⭕️          | ⭕️       | method        | preferredSize() | ()
1.0.2   | ⭕️          | ⭕️       | method        | getColorModel() | ()
1.0.2   | ⭕️          | ⭕️       | method        | getGraphics()  | ()
1.0.2   | ⭕️          | ⭕️       | method        | getFontMetrics() | (Font)
1.0.2   | ⭕️          | ⭕️       | method        | dispose()      | ()
1.0.2   | ⭕️          | ⭕️       | method        | setForeground() | (Color)
1.0.2   | ⭕️          | ⭕️       | method        | setBackground() | (Color)
1.0.2   | ⭕️          | ⭕️       | method        | setFont()      | (Font)
1.0.2   | ⭕️          | ⭕️       | method        | requestFocus() | ()
1.0.2   | ⭕️          | ⭕️       | method        | nextFocus()    | ()
1.0.2   | ⭕️          | ⭕️       | method        | createImage()  | (ImageProducer)
1.0.2   | ⭕️          | ⭕️       | method        | createImage()  | (int,int)
1.0.2   | ⭕️          | ⭕️       | method        | prepareImage() | (Image,int,int,ImageObserver)
1.0.2   | ⭕️          | ⭕️       | method        | checkImage()   | (Image,int,int,ImageObserver)


##### java.awt.peer.ChoicePeer (2/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | addItem()      | (String,int)
1.0.2   | ⭕️          | ⭕️       | method        | select()       | (int)


##### java.awt.peer.CheckboxPeer (3/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setState()     | (boolean)
1.0.2   | ⭕️          | ⭕️       | method        | setCheckboxGroup() | (CheckboxGroup)
1.0.2   | ⭕️          | ⭕️       | method        | setLabel()     | (String)


##### java.awt.peer.CheckboxMenuItemPeer (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setState()     | (boolean)


##### java.awt.peer.CanvasPeer (0/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------


##### java.awt.peer.ButtonPeer (1/0/⭕️)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | method        | setLabel()     | (String)

