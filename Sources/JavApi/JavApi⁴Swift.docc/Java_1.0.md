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
1.0.2   | ✔️          | ⭕️       | final field   | MAX_RADIX      | 
1.0.2   | ✔️          | ⭕️       | final field   | MAX_VALUE      | 
1.0.2   | ✔️          | ⭕️       | final field   | MIN_RADIX      | 
1.0.2   | ✔️          | ⭕️       | final field   | MIN_VALUE      | 
1.0.2   | ✔️          | ⭕️       | constructor   | Character()    | (char)
1.0.2   | ✔️          | ⭕️       | method        | charValue()    | ()->Character
1.0.2   | ✔️          | ⭕️       | static method | digit()        | (char,int)->int
1.0.2   | ⭕️          | ⭕️       | method        | equals()       | (Object)->boolean
1.0.2   | ✔️          | ⭕️       | static method | forDigit()     | (char,int)->int
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

<!-- 11+27+7+2+14+9+2+8+10+5+6+23=124 -->

##### java.util.BitSet (11/11/-)

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

##### java.util.Date (27/27/-)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Date()              | ()
1.0.2   | ✔️          | ⭕️       | constructor   | Date()              | (long)
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

##### java.util.Dictionary (7/7/-)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | elements()     | ()->Enumeration — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | get()          | (Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | isEmpty()      | ()->boolean — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | keys()         | ()->Enumeration — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | put()          | (Object,Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | remove()       | (Object)->Object — extension on Swift Dictionary
1.0.2   | ✔️          | ⭕️       | method        | size()         | ()->int — extension on Swift Dictionary

##### java.util.Enumeration (2/2/2)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ✔️       | method        | hasMoreElements() | ()->boolean
1.0.2   | ✔️          | ✔️       | method        | nextElement()     | ()->Object

##### java.util.Hashtable (14/14/-)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Hashtable()    | ()
1.0.2   | ✔️          | ⭕️       | constructor   | Hashtable()    | (int)
1.0.2   | ✔️          | ⭕️       | constructor   | Hashtable()    | (int,float)
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

##### java.util.Observable (9/9/-)

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

##### java.util.Observer (2/2/-)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | method        | update()       | (Observable,Object)
1.0.2   | ✔️          | 🪄       | method        | hashCode()     | ()->int — default via ObjectIdentifier for class types

##### java.util.Properties (8/8/-)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ⭕️       | field         | defaults          | Properties
1.0.2   | ✔️          | ⭕️       | constructor   | Properties()      | ()
1.0.2   | ✔️          | ⭕️       | constructor   | Properties()      | (Properties)
1.0.2   | ✔️          | ⭕️       | method        | getProperty()     | (String)->String
1.0.2   | ✔️          | ⭕️       | method        | getProperty()     | (String,String)->String
1.0.2   | ✔️          | ⭕️       | method        | list()            | (PrintStream)
1.0.2   | ✔️          | ⭕️       | method        | load()            | (InputStream)
1.0.2   | ✔️          | ⭕️       | method        | propertyNames()   | ()->Enumeration
1.0.2   | ✔️          | ⭕️       | method        | save()            | (OutputStream,String) — deprecated since 1.2, use store()
1.0.2   | ✔️          | ⭕️       | method        | setProperty()     | (String,String)->Object

##### java.util.Random (10/10/10)

version | implemented | tested   | type          | name              | more informations
------- | ----------- | -------- | ------------- | ----------------- | -----------------
1.0.2   | ✔️          | ✔️       | constructor   | Random()          | ()
1.0.2   | ✔️          | ✔️       | constructor   | Random()          | (long)
1.0.2   | ✔️          | ✔️       | method        | nextBoolean()     | ()->boolean
1.0.2   | ✔️          | ✔️       | method        | nextBytes()       | (byte[])
1.0.2   | ✔️          | ✔️       | method        | nextDouble()      | ()->double
1.0.2   | ✔️          | ✔️       | method        | nextFloat()       | ()->float
1.0.2   | ✔️          | ✔️       | method        | nextGaussian()    | ()->double
1.0.2   | ✔️          | ✔️       | method        | nextInt()         | ()->int
1.0.2   | ✔️          | ✔️       | method        | nextInt()         | (int)->int
1.0.2   | ✔️          | ✔️       | method        | nextLong()        | ()->long
1.0.2   | ✔️          | ✔️       | method        | setSeed()         | (long)

##### java.util.Stack (5/5/1)

version | implemented | tested   | type          | name           | more informations
------- | ----------- | -------- | ------------- | -------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Stack()        | () — extends Vector
1.0.2   | ✔️          | ⭕️       | method        | empty()        | ()->boolean
1.0.2   | ✔️          | ⭕️       | method        | peek()         | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | pop()          | ()->Object
1.0.2   | ✔️          | ⭕️       | method        | push()         | (Object)->Object
1.0.2   | ✔️          | ✔️       | method        | search()       | (Object)->int

##### java.util.StringTokenizer (6/6/-)

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

##### java.util.Vector (23/23/-)

version | implemented | tested   | type          | name                | more informations
------- | ----------- | -------- | ------------- | ------------------- | -----------------
1.0.2   | ✔️          | ⭕️       | constructor   | Vector()            | ()
1.0.2   | ✔️          | ⭕️       | constructor   | Vector()            | (int)
1.0.2   | ✔️          | ⭕️       | constructor   | Vector()            | (int,int)
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

