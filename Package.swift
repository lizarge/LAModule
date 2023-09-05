// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BAK",
    platforms: [
      .iOS(.v16)
    ],

    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BAK",
            type: .static,
            targets: ["BAK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        
        .package(url: "https://github.com/lizarge/fdg.git", revision: "49f8e70273049ab4972bf0dcbb6d147539e6c154"),
        
        .package(
            url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", from: "6.9.0"),
        .package(
            url: "https://github.com/facebook/facebook-ios-sdk.git", branch: "main"),
        .package(
            url: "https://github.com/qasim/TikTokOpenSDK.git", from: "5.0.0"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.6.0"),
        .package(url: "https://github.com/exyte/ExyteMediaPicker.git", from: "1.2.3")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BAK",
            dependencies: [
                .product(name: "OneSignal",package: "fdg"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .byName(name:  "TikTokOpenSDK"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "ExyteMediaPicker", package: "ExyteMediaPicker")
            ],
            resources: [.copy("nouser.png")])
    ]
)


