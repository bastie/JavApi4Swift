# JavApi⁴Swift

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbastie%2FJavApi4Swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/bastie/JavApi4Swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbastie%2FJavApi4Swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/bastie/JavApi4Swift)

This project provides a Java like API in 100%-pure Swift instead bridging to Java virtual machine. In result you do not need a Java virtual machine. On the otherside you can port Java code to Swift without Big-Bang step by step.

This project use [MinD](https://sword-lang.org/sword-entwicklungsrichtlinien.html) pattern to reduce dependency and eat other great resources.

## License

This project use only business friendly **permissive licenses**.

<p><figure>
<a title="David A. Wheeler, et al., CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Floss-license-slide-image.svg"><img width="1024" alt="Floss-license-slide-image" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Floss-license-slide-image.svg/512px-Floss-license-slide-image.svg.png"></a>
<figcaption style="text-align: right;display: inline-block">Image: David A. Wheeler, et al., CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons</figcaption>
</figure></p>


Parts of source code use the BSD Licenses and the Public Domain / The Unlicense.
By default I use the MIT License.
Parts of source code use the Apache 2.0 license.

## Similar projects

0. [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
   * **pro**: it is JavApi⁴Swift 😎
   * **pro**: still active
   * **pro**: no Java Runtime needed
   * **pro**: stable
   * **pro**: sample ported Java projects are provided
   * **contra**: less developer
   * **contra**: at the moment not all of Java API supported
   * **contra**: Java code need to port to Swift

1. [Swift Java Interoperability Tools and Libraries](https://github.com/swiftlang/swift-java)
   * **pro**: subrepository of Apple Swiftlang github home
   * **pro**: seems active
   * **pro**: lot of developer
   * **pro**: all of installed Java Runtime is supported
   * **pro**: no rewrite of running Java code needed (it 's like let COBOL code run forever 😜)
   * **contra**: need installed Java Runtime
   * **contra**: not stable  
   
2. [java_swift](https://github.com/SwiftJava/java_swift) - forks and similat projects of SwiftJava user.
   * **pro**: all of installed Java Runtime is supported
   * **contra**: seams still inactive
   * **contra**: need installed Java Runtime

Some other projects port parts of Java functionally to Swift. I do not say one project are better than other. 

## thanks

Special thanks to contributors of

* [JZLib implementation](https://github.com/kohsuke/jzlib) and original [JZLib implementation](https://github.com/ymnk/jzlib)
* [AnyDate implementation](https://github.com/kawoou/AnyDate)
* [Base64 implementation](https://github.com/drichardson/SwiftyBase64) with alphabet separation
* Apache Harmony team
* [jTar implementation](https://github.com/xiaoxindada/jtar) and original [jTar implementation](https://github.com/kamranzafar/jtar)



## Usage

When working with XCode add dependency

    https://github.com/bastie/JavApi4Swift.git
    
When working with SwiftPM add dependency

    .package(url: "https://github.com/bastie/JavApi4Swift.git", from: "0.19.1")

or

    .Package(url: "https://github.com/bastie/JavApi4Swift.git", .upToNextMajor(from: "0.19.1"))

## Ports

I'm implementing some porting projects to check JavApi⁴Swift releases and look for the next missing features. The use could start from version 0.4.2.
Check out these projects and learn how to use JavApi⁴Swift.

### 0.4.2

* [ASCII-Data](https://github.com/bastie/ASCII-Data2JavApi.git) is a library to display tables and graphs on command line as ASCII or ANSI.

### 0.7.4

* [LStXML2Code](https://github.com/bastie/LStXML2Code) is a library and CLI to generate source code for German income tax calculation based on Federal Ministry of Finance provided XML Pseudocode.

### 0.8.0

* [iban4j](https://github.com/bastie/iban4j2JavApi) is a library for generation and validation of the International Bank Account Numbers (IBAN ISO_13616) and Business Identifier Codes (BIC ISO_9362).

### 0.12.0

* [ShrinkItArchive](https://github.com/bastie/ShrinkItArchive) is a library for managing Apple ][ ShrinkIt / NuFX archives.

### 0.19.1

*  [STar](https://github.com/bastie/STar) is a simple Swift Tar library, that provides an easy way to create and read tar files using.

## Development

### include other projects

To honor the work of the developer of other project let the history come inside.

To include other project with compatible license do

    # Example for some types from a jzlib clone
    #
    # clone the other project local, jzlib clone are here https://github.com/kohsuke/jzlib.git
     
    git clone https://github.com/kohsuke/jzlib.git otherProject
    
    # go into project directory and remove the origin
    cd otherProject
    git remote rm origin
    
    # filter project to remove all unwanted data and commit it
    git filter-branch --subdirectory-filter src/main/java/com/jcraft/jzlib -- --all
    git rm Deflat*.java GZIP*.java Inf*.java Z*.java Tree.java StaticTree.java JZl*.java
    git commit -m "ready to import"
    
    # go to JavApi project directory
    cd ../JavApi4Swift
    
    # add (temporary) the local other project as remote source and pull wanted data with history
    git remote add importSource ../otherProject
    git pull importSource master --no-rebase --allow-unrelated-histories
    git remote rm importSource
    
    # work on conflicts f.e. in .gitignore
    
    # optional take a look into history
    git log
    

### JavApi style guide

1. The ported Java source code should not to modify more than needed. 
1. I like short lines and so indent is 2 spaces. 
1. Types are in same name files like Java with the exception of java.lang types.
1. The opend curly braces are in the same line.
1. _packages_ are mapped over enums in files named as java.basepackagename.packagename.swift in result of compiler problems with more than one identical files names. 
1. Exported parameters of Java translated, non-private function parameter are marked with underline.
1. Exceptions are mapped over extension of Error enumeration.
1. Default methods are in extensions implemented.
1. Swiftify code are implemented in extensions.
1. All previous points are non-binding recommendations with no binding effect.


### [How to translate Java source code to Swift](./Sources/JavApi/JavApi⁴Swift.docc/Java2Swift.md)
