// swift-tools-version:5.4

import PackageDescription

let commonTestDependencies: [PackageDescription.Target.Dependency] = [
    "NSpry",
    "Nimble",
    "Quick"
]

let package = Package(
    name: "NRequest",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "NRequest", targets: ["NRequest"]),
        .library(name: "NRequestTestHelpers", targets: ["NRequestTestHelpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0")),
        .package(url: "git@github.com:NikSativa/NSpry.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "git@github.com:maxkazakov/NCallback.git", .branch("spm_dymanic_library")),
        .package(url: "git@github.com:maxkazakov/NQueue.git", .branch("spm_dymanic_library"))
    ],
    targets: [
        .target(name: "NRequest",
                dependencies: ["NQueue", "NCallback"],
                path: "Source"),
        .target(name: "NRequestTestHelpers",
                dependencies: [
                    "NRequest",
                    "NQueue",
                    .product(name: "NQueueTestHelpers", package: "NQueue"),
                    "Nimble",
                    "NSpry"
                ],
                path: "TestHelpers"),
        .testTarget(name: "NRequestTests",
                    dependencies: [
                        "NCallback",
                        .product(name: "NCallbackTestHelpers", package: "NCallback"),
                        "NRequest",
                        "NRequestTestHelpers",
                        "NQueue",
                        .product(name: "NQueueTestHelpers", package: "NQueue")
                    ] + commonTestDependencies,
                    path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
