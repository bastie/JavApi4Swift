# Apple Platforms

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Platform notes for macOS, iOS, tvOS, watchOS and visionOS.

## Minimum versions

| Platform | Minimum |
|----------|---------|
| macOS | 26 |
| iOS | 18 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |

## CryptoKit

`CryptoKit` is available on all Apple platforms meeting the minimum version requirements. JavApi⁴Swift's checksum classes (`Adler32`, `CRC32`, `CRC32C`) are available as typealiases under `Insecure.*` when `CryptoKit` can be imported.

## Networking

All `java.net` classes are fully supported. `URLConnection` uses `Foundation.URLSession` internally. Raw socket classes (`Socket`, `ServerSocket`, `DatagramSocket`) use POSIX APIs available on all Apple platforms.

## App Store / sandbox

On iOS, tvOS, watchOS and visionOS, outbound network connections require the `com.apple.security.network.client` entitlement. Inbound connections (i.e. `ServerSocket`) require `com.apple.security.network.server`. Both are standard App Store entitlements.

## `java.lang.Process`

`Foundation.Process` (used by `java.lang.Runtime.exec`) is only available on macOS. On iOS, tvOS, watchOS and visionOS, calling `Runtime.exec` throws `UnsupportedOperationException` at runtime.

## SwiftUI integration

`java.awt` components have experimental SwiftUI wrappers (`AWTComponentView`, `AWTWindowHost`) in the `SwiftExtensions/SwiftUI` directory. These are macOS-only.
