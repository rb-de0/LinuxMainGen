// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LinuxMainGen",
    dependencies: [
        .package(url: "https://github.com/kareman/Moderator.git", .upToNextMajor(from: "0.4.3")),
        .package(url: "https://github.com/kareman/FileSmith.git", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMajor(from: "0.19.1"))
    ],
    targets: [
        .target(name: "LinuxMainGen", dependencies: ["Moderator", "FileSmith", "SourceKittenFramework"])
    ]
)
