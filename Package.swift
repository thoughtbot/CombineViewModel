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
    .target(name: "CombineViewModel", dependencies: ["CombineViewModelObjC"]),
    .target(name: "CombineViewModelObjC"),
    .testTarget(name: "CombineViewModelTests", dependencies: ["CombineViewModel"]),
  ]
)
