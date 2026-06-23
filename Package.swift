// swift-tools-version: 6.3
/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import PackageDescription

// 1. Basis-Produkte definieren (für alle Plattformen)
var packageProducts: [PackageDescription.Product] = [
  .library(name: "JavApi", targets: ["JavApi"]),
  .library(name: "notonlyjava", targets: ["NO"]),
]

// 2. Basis-Targets definieren (für alle Plattformen)
var packageTargets: [PackageDescription.Target] = [
  .target(name: "NO"),
  .target(name: "JavApi"),
  .testTarget(name: "JavApiTests", dependencies: ["JavApi"]),
  
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
]

// 3. Nur unter macOS die SQLite-Sachen hinzufügen
#if os(macOS)
packageProducts.append(
  .library(name: "SQLiteJDBC", targets: ["SQLiteJDBC"])
)

packageTargets.append(contentsOf: [
  // Example JDBC 1.x driver implementation backed by SQLite
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
])
#endif

// 4. Das finale Package initialisieren
let package = Package(
  name: "JavApi⁴Swift",
  platforms: [.macOS(.v26), .visionOS(.v2), .iOS(.v18), .tvOS(.v18), .watchOS(.v11)],
  products: packageProducts,
  targets: packageTargets
)
