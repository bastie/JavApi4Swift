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
  .target(
    name: "JavApi",
    linkerSettings: [
      // OLE/COM functions (RegisterDragDrop, DoDragDrop, OleInitialize, …)
      // are in ole32.lib which the WinSDK overlay does not auto-link.
      .linkedLibrary("ole32", .when(platforms: [.windows])),
      // GradientFill (used by Graphics2D+GDI.swift for GradientPaint
      // rendering) is in msimg32.lib, not auto-linked by the WinSDK overlay.
      //
      // TODO(msimg32): currently statically linked. Consider switching to
      // dynamic loading (LoadLibraryA("msimg32.dll") + GetProcAddress) —
      // the same dlopen/dlsym-based pattern already used for Xlib symbols
      // in Sources/JavApi/awt/toolkit/x11/_X11Graphics.swift.
      //
      // Why this might matter later:
      // - Removes the static link dependency entirely, so this
      //   .linkedLibrary(...) entry (and any linker-level requirement on
      //   msimg32.lib being present at build time) could be dropped.
      // - Consistency: every other native-symbol dependency in this
      //   project (Xlib on X11) is already resolved dynamically at
      //   runtime rather than linked statically; GDI is currently the
      //   only backend still using compile-time linking for a non-core
      //   API. Aligning GDI with that pattern would make cross-compiling
      //   (e.g. building the Windows target from a non-Windows host,
      //   or toolchains where msimg32.lib isn't readily available in the
      //   SDK path used) more robust.
      // - Optional-at-runtime behaviour: dynamic resolution lets
      //   GradientFill fail gracefully (nil function pointer → fall back
      //   to solid fill) instead of a hard link-time failure, matching
      //   how _X11Graphics already tolerates missing optional Xlib
      //   extensions (e.g. Xft).
      //
      // Why we're NOT doing this now:
      // - msimg32.dll has shipped with every Windows release since
      //   Windows 2000 (incl. Server Core), so the real-world risk of it
      //   being absent at runtime is effectively zero — static linking is
      //   simpler and has no meaningful downside today.
      // - Revisit only if a concrete cross-compilation or SDK-availability
      //   problem with msimg32.lib actually shows up.
      .linkedLibrary("msimg32", .when(platforms: [.windows])),
    ]
  ),
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
