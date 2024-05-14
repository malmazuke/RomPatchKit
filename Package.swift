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
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19"),
    ],
    targets: [
        .target(
            name: "RomPatchKit",
            dependencies: [
                .product(name: "AblyDeltaCodec", package: "delta-codec-cocoa"),
                .product(name: "ZIPFoundation", package: "zipfoundation"),
            ]
        ),
        .testTarget(
            name: "RomPatchKitTests",
            dependencies: ["RomPatchKit"],
            resources: [
                .copy("Resources/test.rom"),
                .copy("Resources/expected.rom"),
                .copy("Resources/expected-large.rom"),
                .copy("Resources/IPS/patch.ips"),
                .copy("Resources/BPS/patch.bps"),
                .copy("Resources/UPS/patch.ups"),
                .copy("Resources/xDelta/patch.xdelta"),
                .copy("Resources/IPS/patch-large.ips"),
                .copy("Resources/UPS/patch-large.ups"),
            ]
        ),
    ]
)
