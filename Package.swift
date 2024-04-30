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
    ],
    dependencies: [
        .package(url: "https://github.com/ably/delta-codec-cocoa.git", branch: "main"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "RomPatcher",
            dependencies: [
                .product(name: "AblyDeltaCodec", package: "delta-codec-cocoa")
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "RomPatcherTests",
            dependencies: ["RomPatcher"],
            resources: [
                .copy("Resources/test.rom"),
                .copy("Resources/expected.rom"),
                .copy("Resources/patch.ips"),
                .copy("Resources/patch.bps"),
                .copy("Resources/patch.ups"),
                .copy("Resources/patch.xdelta"),
            ]
        ),
    ]
)
