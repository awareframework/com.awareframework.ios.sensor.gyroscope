// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.gyroscope",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.gyroscope",
            targets: [
                "com.awareframework.ios.sensor.gyroscope"
            ]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:awareframework/com.awareframework.ios.sensor.core.git", from: "0.7.7")
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.gyroscope",
            dependencies: [
                .product(name: "com.awareframework.ios.sensor.core", package: "com.awareframework.ios.sensor.core", condition: .when(platforms: [.iOS]))
            ],
            path: "com.awareframework.ios.sensor.gyroscope/Classes"
        )
    ],
    swiftLanguageModes: [.v5]
)
