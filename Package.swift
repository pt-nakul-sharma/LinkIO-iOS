// swift-tools-version:5.5
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
    ]
)
