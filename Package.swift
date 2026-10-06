// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "Basement"
let targetName = packageName

let package = Package(
    name: packageName,
    platforms: [.iOS(.v11), .macOS(.v11), .tvOS(.v11), .watchOS(.v2)],
    products: [
        .library(
            name: packageName,
            targets: [targetName]),
    ],
    dependencies: [
        .package(url: "https://github.com/bradleyandrew/realm-swift.git", branch: "release/10.54.8")
    ],
    targets: [
        .target(
            name: targetName,
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift")
            ]
        ),
        .testTarget(
            name: "BasementTests",
            dependencies: ["Basement"]),
    ]
)
