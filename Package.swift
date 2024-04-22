// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RomPatcher",
    products: [
        .library(
            name: "RomPatcher",
            targets: ["RomPatcher"]),
    ],
    targets: [
        .target(
            name: "RomPatcher",
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "RomPatcherTests",
            dependencies: ["RomPatcher"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
