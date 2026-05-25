// swift-tools-version: 5.9
// Rename to `Package.swift` after you run `Scripts/sync-binary-from-private.sh`
// (copies `FlagsIOS.xcframework` into `Artifacts/`). No private source in this repo.
import PackageDescription

let package = Package(
    name: "FlagsPublicSPM",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FlagsIOS", targets: ["FlagsIOS"]),
        .library(name: "FlagsConsumer", targets: ["FlagsConsumer"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "FlagsIOS",
            path: "Artifacts/FlagsIOS.xcframework"
        ),
        .target(
            name: "FlagsConsumer",
            dependencies: ["FlagsIOS"],
            path: "Sources/FlagsConsumer"
        ),
        .testTarget(
            name: "FlagsConsumerTests",
            dependencies: ["FlagsConsumer"],
            path: "Tests/FlagsConsumerTests"
        ),
    ]
)
