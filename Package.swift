// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSPurchases",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LSPurchases",
            targets: ["LSPurchases"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LudvigShtirner/CoreObjects.git",
                 branch: "main"),
        .package(url: "https://github.com/apphud/ApphudSDK.git",
                 (.init(3, 0, 0) ..< .init(4, 0, 0)))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LSPurchases",
            dependencies: ["CoreObjects", "ApphudSDK"]),
        .testTarget(
            name: "LSPurchasesTests",
            dependencies: ["LSPurchases"]),
    ]
)
