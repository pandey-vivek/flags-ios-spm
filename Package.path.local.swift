// swift-tools-version: 5.9
// Local-only: copy over Package.swift when both repos are siblings (no GitHub fetch of flags-ios).
//   cp Package.path.local.swift Package.swift
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
