// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RomPatcher",
    products: [
        .library(
            name: "RomPatcher",
            targets: ["RomPatcher"]),
        .library(
            name: "flips",
            targets: ["flips"]),
    ],
    targets: [
        .target(
            name: "RomPatcher",
            dependencies: ["flips"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
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
