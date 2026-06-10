# Windows

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Platform notes for running JavApi⁴Swift on Windows.

## Overview

Swift on Windows is supported via the [Swift for Windows](https://www.swift.org/install/windows/) toolchain. JavApi⁴Swift targets Windows as an implicitly supported platform — no special Package.swift configuration is needed.

> Windows support is community-tested. If you encounter platform-specific issues, please open an issue on the JavApi⁴Swift repository.

## Networking

Windows uses Winsock2 instead of POSIX sockets. JavApi⁴Swift's socket classes (`Socket`, `ServerSocket`, `DatagramSocket`) use POSIX APIs via the Swift/Windows POSIX compatibility layer. This should work on Windows 10 and later, which ships with a POSIX socket compatibility layer.

## Foundation

`Foundation` on Windows is provided by swift-corelibs-foundation. Networking types require:

```swift
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
```

JavApi⁴Swift handles this internally.

## CryptoKit

`CryptoKit` is not available on Windows. JavApi⁴Swift's `MessageDigest` implementation does not depend on CryptoKit and works on all platforms.

## Image resources

SPM does **not** deploy `.xcassets` resource bundles on Windows — the `resources: [.process("Assets.xcassets")]` directive in `Package.swift` is silently ignored. To load bundled images at runtime:

1. Copy PNG files next to the compiled executable (e.g. `JavApi4Swift256.png`), or
2. Rely on the search-path fallback in `GDIToolkit.loadImage(named:)`, which looks for the file relative to the executable and also up the tree to `Sources/AWTShowcase/Assets.xcassets/AppIcon.appiconset/` — this works when running via `swift run` from the package root.

`GDIToolkit` uses `_PNGLoader` — a pure-Swift PNG decoder with its own DEFLATE implementation — to load images without any external dependency.

## Known limitations

- `java.lang.Process` (process spawning via `Runtime.exec`) may behave differently on Windows due to path and shell differences.
- File path separators: Java uses `/` internally; Windows uses `\`. `java.io.File` normalises separators, but be aware when porting path-heavy code.
