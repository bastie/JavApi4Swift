// swift-tools-version: 6.3
/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import PackageDescription

let package = Package(
  name: "JavApi⁴Swift",
  platforms: [.macOS(.v26),.visionOS(.v2),.iOS(.v18),.tvOS(.v18),.watchOS(.v11)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "JavApi",
      targets: ["JavApi"]
    ),
    .library(name: "notonlyjava", targets: ["NO"]),
  ],
  targets: [
    .target(
      name: "NO",
    ),
    .target(
      name: "JavApi",
    ),
    .testTarget(
      name: "JavApiTests",
      dependencies: ["JavApi"]),
    .executableTarget(
      name: "AWTShowcase",
      dependencies: ["JavApi"],
      path: "Sources/AWTShowcase",
      resources: [.process("Assets.xcassets")]
    ),
  ]
)

