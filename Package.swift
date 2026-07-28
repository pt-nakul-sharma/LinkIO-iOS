// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "LinkIO",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LinkIO",
            targets: ["LinkIO"]),
    ],
    targets: [
        .target(
            name: "LinkIO",
            dependencies: [],
            path: "LinkIO/Classes")
    ],
    swiftLanguageModes: [.v5, .v6]
)
