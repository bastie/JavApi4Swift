// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JavApi⁴Swift",
    platforms: [.macOS(.v13),.visionOS(.v1),.iOS(.v16),.tvOS(.v16),.watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JavApi",
            targets: ["JavApi"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JavApi",
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]),
        .testTarget(
            name: "JavApiTests",
            dependencies: ["JavApi"]),
    ]
)
