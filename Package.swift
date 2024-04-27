// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RomPatcher",
    products: [
        .library(
            name: "RomPatcher",
            targets: ["RomPatcher"]),
        .library(name: "forestLib", targets: ["forestLib"])
    ],
    targets: [
        .target(
            name: "RomPatcher",
            dependencies: ["forestLib"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "forestLib",
            path: "Sources/forestLib",  // Adjusted path to reflect the correct location
            publicHeadersPath: ".",  // Specify the location of the public headers
            cxxSettings: [
                .headerSearchPath(".")  // Adjust to reflect the correct relative path for header files
            ]
        ),
        .testTarget(
            name: "RomPatcherTests",
            dependencies: ["RomPatcher"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
