// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RomPatchKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RomPatchKit",
            targets: ["RomPatchKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ably/delta-codec-cocoa.git", branch: "main"),
        .package(url: "https://github.com/tayloraswift/swift-hash.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "RomPatchKit",
            dependencies: [
                .product(name: "AblyDeltaCodec", package: "delta-codec-cocoa"),
                .product(name: "CRC", package: "swift-hash"),
            ]
        ),
        .testTarget(
            name: "RomPatchKitTests",
            dependencies: ["RomPatchKit"],
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
