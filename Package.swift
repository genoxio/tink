// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tink",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Tink",
            targets: ["TinkPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "TinkPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/TinkPlugin"),
        .testTarget(
            name: "TinkPluginTests",
            dependencies: ["TinkPlugin"],
            path: "ios/Tests/TinkPluginTests")
    ]
)