# Service Provider Interface (SPI)

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Discovering and loading pluggable implementations at runtime using `java.util.ServiceLoader`.

## Overview

Java's *Service Provider Interface* (SPI) is a design pattern that decouples a
service definition from its implementation. A *service* is an interface or
abstract class. A *provider* is a concrete implementation that lives in a
separate library and is discovered at runtime — the consuming code never
references the provider class directly.

Classic Java uses `META-INF/services/` files on the classpath. Swift has no
classpath, so JavApi⁴Swift uses a different but equivalent mechanism:

1. A `.properties` file describes where to find the provider library and which
   C factory function to call.
2. `ServiceLoader` reads that file, calls `dlopen` (POSIX) or `LoadLibrary`
   (Windows) to load the library, resolves the factory symbol with `dlsym` /
   `GetProcAddress`, and calls it.
3. The factory returns a pointer to a *vtable* struct — a C struct holding
   function pointers for every operation the service defines.

This vtable pattern is the same strategy used by the Java Native Interface
(JNI) and by every major plugin system that works across language boundaries.

## Concepts

### The service

A *service* is an interface (Swift: a struct holding function pointers — a
vtable). Every provider fills in the same vtable so callers can treat all
providers identically.

### The provider

A *provider* is a shared library (`.so`, `.dylib`, or `.dll`) that exports a
single C factory function. That function allocates the vtable on the heap,
fills in all function pointers, and returns a raw pointer to it. The factory is
the only symbol the loader needs to know about.

### The loader

`java.util.ServiceLoader` connects the two sides. It finds the `.properties`
file for a named service, extracts the library path and factory symbol, loads
the library, calls the factory, and returns a typed pointer to the vtable. You
iterate over the loader just like a Java `ServiceLoader`.

## Step 1 — Define the vtable

Define a C struct that describes every operation your service exposes. Use
`@convention(c)` on every function pointer so Swift knows to use the C calling
convention.

```swift
import JavApi

/// The vtable for a hypothetical greeting service.
public struct GreetingServiceVTable {
    /// Returns a greeting string for the given name.
    /// The returned pointer is valid until the next call.
    public let greet: @convention(c) (UnsafePointer<CChar>) -> UnsafePointer<CChar>

    /// Frees any resources held by this provider.
    public let destroy: @convention(c) () -> Void
}
```

Give the vtable a stable name. The name does not have to match a Java class —
it is purely a Swift/C type.

## Step 2 — Write the provider library

The provider is a separate Swift (or C) library. It fills in the vtable and
exports one C factory function.

In Swift 6.3 use the `@c` attribute to export the factory with a stable C
symbol name:

```swift
// GreetingProvider/GreetingProvider.swift
import Foundation

// The vtable struct must match the consumer's definition exactly.
private struct GreetingServiceVTable {
    let greet: @convention(c) (UnsafePointer<CChar>) -> UnsafePointer<CChar>
    let destroy: @convention(c) () -> Void
}

// Storage for the greeting string between calls.
private var lastGreeting: [CChar] = []

private func doGreet(_ name: UnsafePointer<CChar>) -> UnsafePointer<CChar> {
    let swift = "Hello, \(String(cString: name))! (from GreetingProvider)"
    lastGreeting = Array(swift.utf8CString)
    return lastGreeting.withUnsafeBufferPointer { $0.baseAddress! }
}

private func doDestroy() {}

// The factory — one heap-allocated vtable returned as a raw pointer.
@c(GreetingService_create)
public func greetingServiceCreate() -> UnsafeMutableRawPointer? {
    let vtable = UnsafeMutablePointer<GreetingServiceVTable>.allocate(capacity: 1)
    vtable.initialize(to: GreetingServiceVTable(
        greet: doGreet,
        destroy: doDestroy
    ))
    return UnsafeMutableRawPointer(vtable)
}
```

> **Note:** If you are building the provider in C instead of Swift, declare
> the factory as `void* GreetingService_create(void)` and fill in a matching
> struct. The loader does not care which language the provider is written in.

Build the provider as a dynamic library:

```
# Linux
swiftc -emit-library GreetingProvider.swift -o libGreetingProvider.so

# macOS
swiftc -emit-library GreetingProvider.swift -o libGreetingProvider.dylib

# Windows
swiftc -emit-library GreetingProvider.swift -o GreetingProvider.dll
```

## Step 3 — Write the properties file

Create a `services/` directory next to your application binary (or point
`JAVAPI_SERVICES_PATH` to any directory). Inside `services/`, create one
`.properties` file per service. The file name is the fully-qualified service
name you will pass to `ServiceLoader`.

**`services/com.example.GreetingService.properties`**

```properties
# Which shared library contains the provider?
# Bare names are expanded automatically:
#   Linux:   libGreetingProvider.so
#   macOS:   libGreetingProvider.dylib
#   Windows: GreetingProvider.dll
library = GreetingProvider

# Platform-specific overrides (optional — take precedence over 'library')
library.linux   = libGreetingProvider.so
library.macos   = libGreetingProvider.dylib
library.windows = GreetingProvider.dll

# Which C symbol is the factory function?
provider = GreetingService_create
```

### Properties file format

| Key | Required | Description |
|-----|----------|-------------|
| `library` | Yes | Base library name or absolute path. Bare names are expanded to `lib<name>.so` / `lib<name>.dylib` / `<name>.dll`. |
| `library.linux` | No | Platform override for Linux (and Android, FreeBSD). |
| `library.macos` | No | Platform override for macOS, iOS, tvOS, watchOS, visionOS. |
| `library.windows` | No | Platform override for Windows. |
| `provider` | Yes | The C symbol name of the factory function. |
| `#` or `!` | — | Line comment. |

## Step 4 — Load the provider in your application

```swift
import JavApi

// Create a loader for your service.
let loader = java.util.ServiceLoader<GreetingServiceVTable>(
    serviceName: "com.example.GreetingService"
)

// Iterate over all providers found in the search path.
for vtablePtr in loader {
    // Call the greet function through the vtable.
    let nameC = "Sebastian"
    let result = nameC.withCString { ptr in
        vtablePtr.pointee.greet(ptr)
    }
    print(String(cString: result))
    // Output: Hello, Sebastian! (from GreetingProvider)

    // Clean up when done.
    vtablePtr.pointee.destroy()
}
```

If no `.properties` file is found, or the library cannot be loaded, the loader
silently returns zero providers — exactly as Java's `ServiceLoader` behaves
when no provider is registered on the classpath.

## Search path

`ServiceLoader` searches for `.properties` files in this order:

1. Every directory listed in the `JAVAPI_SERVICES_PATH` environment variable
   (colon-separated on POSIX, semicolon-separated on Windows).
2. A `services/` subdirectory next to the running executable.
3. `/usr/share/javapi/services/` (Linux and macOS).
4. `%APPDATA%\JavApi\services\` (Windows).

You can override the search path at runtime:

```swift
java.util.ServiceLoader<GreetingServiceVTable>.setSearchPaths([
    "/opt/myapp/plugins",
    "/usr/local/share/myapp/services"
])
```

Call `setSearchPaths` once during application startup, before the first
`ServiceLoader` is created.

## Reloading providers

If a provider library is updated while the application is running, call
`reload()` on the loader. The next iteration will re-read the `.properties`
file and re-open the library.

```swift
loader.reload()
for vtablePtr in loader {
    // now using the freshly loaded provider
}
```

> **Warning:** Reloading does not automatically destroy the old provider. Call
> `vtablePtr.pointee.destroy()` on every old pointer before calling `reload()`.

## Comparison with Java SPI

| | Java | JavApi⁴Swift |
|---|---|---|
| Service discovery | `META-INF/services/<name>` on classpath | `services/<name>.properties` in search path |
| Provider registration | Jar on classpath | Shared library (`dlopen`) |
| Factory mechanism | `Class.newInstance()` via reflection | C factory function (`dlsym`) |
| Provider type | Java class implementing interface | C vtable struct |
| Iteration | `for (S s : ServiceLoader.load(S.class))` | `for vtablePtr in loader` |
| Failure behaviour | Empty iterator | Empty iterator |

The user-facing iteration pattern is intentionally identical to Java. The
underlying mechanism is different because Swift and Java use different runtime
models, but the result — pluggable implementations discovered without a
compile-time dependency — is the same.

## Implementing multiple providers

You can ship more than one provider for the same service by listing multiple
entries. The current implementation loads one provider per `.properties` file.
To register multiple providers for the same service name, place each one in its
own `.properties` file in a different directory and include all directories in
the search path:

```
/opt/app/plugins/premium/com.example.GreetingService.properties   # premium
/opt/app/plugins/free/com.example.GreetingService.properties      # free
```

```swift
java.util.ServiceLoader<GreetingServiceVTable>.setSearchPaths([
    "/opt/app/plugins/premium",
    "/opt/app/plugins/free"
])
```

The loader returns one vtable pointer per file found, in search-path order.

## Memory management

The factory function allocates the vtable with `UnsafeMutablePointer.allocate`.
The caller is responsible for deallocating it when it is no longer needed:

```swift
for vtablePtr in loader {
    // use the provider …
    vtablePtr.pointee.destroy()         // provider-level cleanup
    vtablePtr.deallocate()              // free the vtable itself
}
```

If your vtable `destroy` function already frees everything, you still need to
call `vtablePtr.deallocate()` to free the vtable struct itself — those are two
separate allocations.

## What You Have Learned

- Java SPI decouples service definitions from implementations; JavApi⁴Swift
  replicates this with `.properties` files and `dlopen`/`LoadLibrary`.
- Define the service as a C vtable struct with `@convention(c)` function
  pointers.
- Export the factory from the provider library using Swift 6.3's `@c` attribute.
- Create a `.properties` file in the search path with `library` and `provider`
  keys.
- Iterate with `for vtablePtr in loader` — an empty iterator means no provider
  was found.
- Call `destroy()` and `deallocate()` when you are done with a provider.

## Next Steps

- Read <doc:Networking> to see how `java.net.URLConnection` uses a similar
  factory pattern internally to select the right protocol handler.
- Read <doc:ImplementingAToolkit> to see how the AWT toolkit backend is loaded
  with the same `dlopen` mechanism.
