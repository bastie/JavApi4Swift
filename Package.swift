// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "JavApi⁴Swift",
  platforms: [.macOS(.v26),.visionOS(.v1),.iOS(.v16),.tvOS(.v16),.watchOS(.v9)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "JavApi",
      targets: ["JavApi"]
    ),
    .library(name: "DOM", targets: ["DOM"]),
    .library(name: "notonlyjava", targets: ["NO"]),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "NO",
    ),
    .target(
      name: "DOM",
    ),
    .target(
      name: "JavApi",
      dependencies: ["DOM"]
    ),
    .testTarget(
      name: "JavApiTests",
      dependencies: ["JavApi"]),
  ]
)

