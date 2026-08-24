// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnlagenVolumenCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AnlagenVolumenCore", targets: ["AnlagenVolumenCore"])
    ],
    targets: [
        .target(name: "AnlagenVolumenCore", path: "AnlagenVolumen/Core"),
        .testTarget(name: "AnlagenVolumenCoreTests", dependencies: ["AnlagenVolumenCore"], path: "AnlagenVolumenTests")
    ]
)
