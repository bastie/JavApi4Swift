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
    .library(
      // Example driver implemetation
      name: "SQLiteJDBC",
      targets: ["SQLiteJDBC"]
    ),
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
      dependencies: ["JavApi"]
    ),
    // Example AWT Showcase
    .executableTarget(
      name: "AWTShowcase",
      dependencies: ["JavApi"],
      path: "Sources/AWTShowcase",
      resources: [.process("Assets.xcassets")]
    ),
    // Example Swing Showcase
    .executableTarget(
      name: "SwingShowcase",
      dependencies: ["JavApi"],
      path: "Sources/SwingShowcase"
    ),
    // Example JDBC 1.x driver implementation backed by SQLite (macOS only — uses import SQLite3)
    .target(
      name: "SQLiteJDBC",
      dependencies: ["JavApi"],
      path: "Sources/SQLiteJDBC",
      linkerSettings: [.linkedLibrary("sqlite3")]
    ),
    .testTarget(
      name: "SQLiteJDBCTests",
      dependencies: ["JavApi", "SQLiteJDBC"],
      path: "Tests/SQLiteJDBCTests"
    ),
  ]
)

