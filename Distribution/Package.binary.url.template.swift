// swift-tools-version: 5.9
// Use when the zip is hosted at a **public HTTPS** URL (e.g. GitHub Release asset).
import PackageDescription

let package = Package(
    name: "FlagsIOS",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FlagsIOS", targets: ["FlagsIOS"]),
    ],
    targets: [
        .binaryTarget(
            name: "FlagsIOS",
            url: "https://github.com/YOUR_ORG/flags-ios-spm/releases/download/0.1.0/FlagsIOS.xcframework.zip",
            checksum: "RUN_swift_package_compute_checksum_ON_THE_ZIP"
        ),
    ]
)
