# Java 1.0

1995-05-23 the first appeared of Java also called Java birthday.

## Overview


### Compiler directives (expermimental)

By default the lates Java behavior is implemented but checked at runtime against other wishes (over explicit method parameter extension and / or system property). Another way is to set compiler directives to build special Java like version.

- term: Java10Compiler activates static compiling like Java 1.0 behavior
- term: JavaOtherCompiler activates static compiling other than explicit defined Java version (see Java10Compiler)

## Java Documentation

_based on JDK Documentation at [https://javaalmanac.io](https://javaalmanac.io/jdk/1.0/api/)_

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

### Java Core packages

#### java.lang

<!-- 11+24+8+5+5+22+23+23+23+32+4+11+7+16+32+48+31+16+41+23+7=412 -->

##### java.lang.Boolean (11/11/1)

<!-- 11 methods+fields, 11 full implemented, 1 test implemented -->

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | Class         | Boolean        | typealias and extension of `Bool`
1.0.2   | ✔️          | ⭕️       | final field   | Boolean.FALSE  | 
1.0.2   | ✔️          | ⭕️       | final field   | Boolean.TRUE   | 
1.0.2   | ✔️          | 🪄       | constructor   | Boolean()      | (boolean) buildin over typealias
1.0.2   | ✔️          | ⭕️       | constructor   | Boolean()      | (String?)
1.0.2   | ✔️          | ⭕️       | method        | booleanValue() | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | static method | getBoolean()   | (String)->boolean, in result since Java 1.1 it is case insensitive the Java 1.0 case sensitive behavior must be explicit activated
1.1     | ✔️          | ⭕️       | static method | getBoolean()   | (String)->boolean
1.0.2   | ✔️          | ⭕️       | method        | hashcode()     | ()->int
1.0.2   | ✔️          | ⭕️       | method        | toString()     | ()->String
1.0.2   | ✔️          | ⭕️       | static method | valueOf()      | (String)->Boolean

##### java.lang.Character (24/?/?)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | Class         | Boolean        | typealias and extension of `char`
1.0.2   | ⭕️          | ⭕️       | final field   | MAX_RADIX      | 
1.0.2   | ⭕️          | ⭕️       | final field   | MAX_VALUE      | 
1.0.2   | ⭕️          | ⭕️       | final field   | MIN_RADIX      | 
1.0.2   | ⭕️          | ⭕️       | final field   | MIN_VALUE      | 
1.0.2   | ✔️          | ⭕️       | constructor   | Character()    | (char)
1.0.2   | ✔️          | ⭕️       | method        | charValue()    | ()->Character
1.0.2   | ⭕️          | ⭕️       | static method | digit()        | (char,int)->int
1.0.2   | ⭕️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | forDigit()     | (char,int)->int
1.1     | ✔️          | ⭕️       | static method | getNumericValue()        | (char)->int
1.0.2   | ⭕️          | ⭕️       | method        | hashCode()     | ()->int
1.0.2   | ⭕️          | ⭕️       | static method | isDefined()    | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isDigit()      | (char)->boolean
5       | ✔️          | ⭕️       | static method | isDigit()      | (int)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isJavaLetter()           | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isJavaLetterOrDigit()    | (char)->boolean
1.0.2   | ✔️          | ⭕️       | static method | isLetter()               | (char)->boolean
5       | ✔️          | ⭕️       | static method | isLetter()               | (int)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isLetterOrDigit()        | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isLowerCase()            | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isSpace()                | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isTitleCase()            | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | isUpperCase()            | (char)->boolean
1.0.2   | ⭕️          | ⭕️       | static method | toLowerCase()            | (char)->char
1.0.2   | ⭕️          | ⭕️       | static method | toString()               | ()->String
1.0.2   | ⭕️          | ⭕️       | static method | toTitelCase()            | (char)->char
1.0.2   | ⭕️          | ⭕️       | static method | toUpperCase()            | (char)->char
1.1     | ✔️          | ⭕️       | static method | isWhiteSpace()           | (char)->boolean


##### java.lang.Class (8/?/?)

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


##### java.lang.ClassLoader (5/?/?)

##### java.lang.Compiler (5/?/?)

##### java.lang.Double (22/?/?)

##### java.lang.Float (23/?/?)

##### java.lang.Integer (23/?/?)

##### java.lang.Long (23/?/?)

##### java.lang.Math (32/?/?)

##### java.lang.Number (4/?/?)

##### java.lang.Object (11/?/?)

##### java.lang.Process (7/?/?)

##### java.lang.Runtime (16/?/?)

##### java.lang.SecurityManager (32/?/?)

##### java.lang.String (48/?/?)

##### java.lang.StringBuffer (31/?/?)

##### java.lang.System (16/?/?)

##### java.lang.Thread (41/?/?)

##### java.lang.ThreadGroup (23/?/?)

##### java.lang.Throwable (7/?/?)





#### java.io

##### java.io.BufferedOutputStream (7/7/-)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | buf            | byte[]
1.0.2   | ✔️          | ⭕️       | field         | count          | int contains the fill status of buffer
1.0.2   | ✔️          | ⭕️       | constructor   | BufferedOutputStream | (OutputStream)
1.0.2   | ✔️          | ⭕️       | constructor   | BufferedOutputStream | (OutputStream, Int)
1.0.2   | ✔️          | ⭕️       | method        | flush          | ()
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[],int,int)

##### java.io.DataInput (15/15/-)

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

##### java.io.FileDescriptor (5/2/-)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ⭕️          | ⭕️       | field         | err            | FileDescriptor
1.0.2   | ⭕️          | ⭕️       | field         | out            | FileDescriptor
1.0.2   | ⭕️          | ⭕️       | field         | in             | FileDescriptor
1.0.2   | ✔️          | ⭕️       | constructor   | FileDescriptor | ()
1.0.2   | ✔️          | ⭕️       | method        | valid()        | ()->boolean

##### java.io.FileOutputStream (9/9/-)

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

##### java.io.FilterOutputStream (7/7/-)

version | implemented | tested   | type          | name           | more informations     
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | out            | OutputStream
1.0.2   | ✔️          | ⭕️       | constructor   | FilterOutputStream | (OutputStream)
1.0.2   | ✔️          | ⭕️       | method        | close()        | ()
1.0.2   | ✔️          | ⭕️       | method        | flush          | ()
1.0.2   | ✔️          | ⭕️       | method        | write()        | (int)
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[])
1.0.2   | ✔️          | ⭕️       | method        | write()        | (byte[],int,int)


#### java.net

#### java.util

