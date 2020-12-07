// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSAnimator",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "LSAnimator", targets: ["LSAnimator"]),
        .library(name: "LSAnimatorCore", targets: ["LSAnimatorCore"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "LSAnimatorCore", path: "Sources/Core"),
        
        .target(name: "LSAnimator", dependencies: ["LSAnimatorCore"]),
        
        .testTarget(name: "LSAnimatorTests", dependencies: ["LSAnimator"]),
    ]
)
