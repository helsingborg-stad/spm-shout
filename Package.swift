// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shout",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "Shout",
            targets: ["Shout"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "Shout",
            dependencies: []),
        .testTarget(
            name: "ShoutTests",
            dependencies: ["Shout"])
    ]
)
