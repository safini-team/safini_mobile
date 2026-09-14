// swift-tools-version: 5.9
import PackageDescription

// Run the native budget/expiry tests on macOS with `swift test`.
let package = Package(
    name: "SafiniScreenTimePolicy",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "SafiniScreenTimePolicy", path: "ios/ScreenTimeShared",
                exclude: ["ScreenTimePolicy.swift"], sources: ["ScreenTimePolicyModel.swift"]),
        .testTarget(name: "SafiniScreenTimePolicyTests", dependencies: ["SafiniScreenTimePolicy"],
                    path: "test/native")
    ]
)
