// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RomPatcher",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RomPatcher",
            targets: ["RomPatcher"]),
        .library(
            name: "flips",
            targets: ["flips"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "RomPatcher",
            dependencies: ["flips"],
            swiftSettings: [.interoperabilityMode(.Cxx)],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
        ),
        .target(
            name: "flips",
            path: "Sources/flips",
            sources: [
                "flips.cpp"
            ],
            publicHeadersPath: ".",
            cxxSettings: [.headerSearchPath(".")]
        ),
        .testTarget(
            name: "RomPatcherTests",
            dependencies: ["RomPatcher"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
