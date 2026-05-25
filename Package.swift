// swift-tools-version: 5.9
// PUBLIC GitHub manifest — binary FlagsIOS only (built from private Adobe flags-ios).
// External clients resolve this repo; they never fetch Adobe Git.
//
// Before first release: run Scripts/publish-binary-release.sh (see ARCHITECTURE.md).
// Local dev with private source: cp Package.path.local.swift Package.swift
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
            url: "https://github.com/pandey-vivek/flags-ios-spm/releases/download/0.1.0/FlagsIOS.xcframework.zip",
            checksum: "1aff13f9476485009de9a59fd8ef1244be0e71cecd677760afa474cba3255700"
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
