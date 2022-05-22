// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "MZRealmSwiftExtension",
    
    platforms: [.iOS(.v11)],
    
    products: [
        .library(
            name: "MZRealmSwiftExtension",
            targets: ["MZRealmSwiftExtension"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", from: "10.0.0")
    ],
    
    targets: [
        .target(
            name: "MZRealmSwiftExtension",
            dependencies: [.product(name: "RealmSwift", package: "realm-swift")]
        ),
        
        .testTarget(
            name: "MZRealmSwiftExtensionTests",
            dependencies: ["MZRealmSwiftExtension"]
        ),
    ]
)
