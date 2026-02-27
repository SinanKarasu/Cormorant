// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cormorant",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Cormorant",
            targets: ["Cormorant"]
        ),
        .executable(
            name: "CormorantDemo",
            targets: ["CormorantDemo"]
        ),
    ],
    targets: [
        .target(
            name: "Cormorant",
            resources: [
                .copy("stdlib"),
            ]
        ),
        .executableTarget(
            name: "CormorantDemo",
            dependencies: ["Cormorant"]
        ),
        .testTarget(
            name: "CormorantTests",
            dependencies: ["Cormorant"],
            resources: [
                .copy("SupportingFiles"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
