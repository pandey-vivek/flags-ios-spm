// swift-tools-version: 5.9
// Default mode: depend on **private** sibling package by path (no credentials).
// For “public binary only” (no source in this repo), see README and `Package.binary.local.swift`.
import PackageDescription

let package = Package(
    name: "FlagsPublicSPM",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    products: [
        .library(name: "FlagsConsumer", targets: ["FlagsConsumer"]),
    ],
    dependencies: [
        // Sibling checkout: ../flags-ios (private repo clone)
        .package(path: "../flags-ios"),
    ],
    targets: [
        .target(
            name: "FlagsConsumer",
            dependencies: [
                .product(name: "FlagsIOS", package: "flags-ios"),
            ],
            path: "Sources/FlagsConsumer"
        ),
        .testTarget(
            name: "FlagsConsumerTests",
            dependencies: ["FlagsConsumer"],
            path: "Tests/FlagsConsumerTests"
        ),
    ]
)
