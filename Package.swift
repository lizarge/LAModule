// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/*let package = Package(
    name: "DeckOfPlayingCards",
    products: [
        .library(name: "DeckOfPlayingCards", targets: ["DeckOfPlayingCards"]),
    ],
    dependencies: [
        .package(name: "PlayingCard",
                 url: "https://github.com/apple/example-package-playingcard.git",
                 from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "DeckOfPlayingCards",
            dependencies: [
                .byName(name: "PlayingCard")
            ]),
        .testTarget(
            name: "DeckOfPlayingCardsTests",
            dependencies: [
                .target(name: "DeckOfPlayingCards")
            ]),
    ]
)*/

let package = Package(
    name: "LAModule",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LAModule",
            targets: ["LAModule"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/lizarge/OneSignal-iOS-SDK_RKModule.git",
            branch: "master"),
        .package(
            url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", from: "6.9.0"),
        .package(
            url: "https://github.com/facebook/facebook-ios-sdk.git", from: "9.0.0"),
        .package(
            url: "https://github.com/qasim/TikTokOpenSDK.git", from: "5.0.0"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.6.0"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LAModule",
            dependencies: [
              
                .product(name: "OneSignal", package: "OneSignal-iOS-SDK_RKModule"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .byName(name: "TikTokOpenSDK"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")  
            ])
    ]
)

