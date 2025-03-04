// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "navisub",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "navisub",
            targets: ["AppModule"],
            bundleIdentifier: "doublepi.navisub",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .locationAlwaysAndWhenInUse(purposeString: "Unknown Usage Description"),
                .locationWhenInUse(purposeString: "Unknown Usage Description"),
                .fileAccess(.userSelectedFiles, mode: .readOnly)
            ],
            appCategory: "public.app-category.navigation"
        )
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift", "0.15.3"..<"1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "SQLite", package: "sqlite.swift")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
