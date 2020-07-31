// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "CombineViewModel",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "CombineViewModel", targets: ["CombineViewModel"]),
  ],
  targets: [
    .target(name: "CombineViewModel"),
    .testTarget(name: "CombineViewModelTests", dependencies: ["CombineViewModel"]),
  ]
)
