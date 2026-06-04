# ``JavApi``⁴Swift

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

JavApi⁴Swift is a pure implementation of Java API in Swift under business friendly license.

## Overview

JavApi⁴Swift provides a Java like API in 100%-pure Swift instead bridging to Java virtual machine. In result you do not need a Java virtual machine. On the otherside you can port Java code to Swift without Big-Bang step by step but need some modification.

This project use [MinD](https://sword-lang.org/sword-entwicklungsrichtlinien.html) MinimizeDependencies pattern to reduce dependency and eat other great resources.

The primary target is to near as possible implemented like Java API and so look into [Java API documentation](https://docs.oracle.com/en/java/javase/index.html). In extension an Tutorial is provided (as test).

## License


![The World is our](Floss-license-slide-image.svg)
<br/><small>Image: David A. Wheeler, et al., CC BY-SA 3.0 , via [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Floss-license-slide-image.svg)</small>


## Topics

The primary target is to implement as close as possible to the Java API. For reference, see the [Java API documentation](https://docs.oracle.com/en/java/javase/index.html).

Java packages are provided as Swift enumerations — `java.util.ArrayList` becomes `java.util.ArrayList` in Swift as well, using nested enums as namespaces.

### Learning Trail

New to JavApi⁴Swift? Work through the tutorials in order.

- <doc:Tutorials>

### Migration Guide

Porting existing Java code to Swift? Read this first.

- <doc:Java2Swift>
