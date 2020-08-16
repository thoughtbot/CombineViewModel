// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "CombineViewModel",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "CombineViewModel", targets: ["CombineViewModel"]),
  ],
  targets: [
    .target(name: "CombineViewModel"),
    .target(name: "ObjCTestSupport", path: "Tests/ObjCTestSupport"),
    .testTarget(name: "CombineViewModelTests", dependencies: ["CombineViewModel", "ObjCTestSupport"]),
  ]
)
