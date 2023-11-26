// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let lsPurchases = "LSPurchases"
private let lsPurchasesTests = "LSPurchasesTests"

let package = Package(
    name: lsPurchases,
    platforms: [.iOS(.v13)],
    products: [
        .library(name: lsPurchases,
                 targets: [lsPurchases]),
    ],
    dependencies: [
        .package(url: "https://github.com/LudvigShtirner/CoreObjects.git",
                 branch: "main"),
        .package(url: "https://github.com/apphud/ApphudSDK.git",
                 (.init(3, 0, 0) ..< .init(4, 0, 0)))
    ],
    targets: [
        .target(name: lsPurchases,
                dependencies: ["CoreObjects", "ApphudSDK"]),
        .testTarget(name: lsPurchasesTests,
                    dependencies: [
                        .byName(name: lsPurchases)
                    ]),
    ]
)
