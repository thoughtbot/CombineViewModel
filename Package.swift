// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "CombineViewModel",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "CombineViewModel", targets: ["CombineViewModel"]),
    .library(name: "Bindings", targets: ["Bindings"]),
    .library(name: "UIKitBindings", targets: ["UIKitBindings"]),
  ],
  targets: [
    .target(name: "CombineViewModel"),
    .target(name: "Bindings"),
    .target(name: "UIKitBindings", dependencies: ["Bindings"]),

    .testTarget(name: "CombineViewModelTests", dependencies: ["CombineViewModel", "ObjCTestSupport"]),
    .target(name: "ObjCTestSupport", path: "Tests/ObjCTestSupport"),
  ]
)
