// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Package Configuration

/// -----------------------------------------------------------------------
///
/// Configuration must be defined above of `let package` in the file
///
/// -----------------------------------------------------------------------

private let umbrellaPackageName = "UmbrellaPackage"
private let appModulePackageName = "AppModulesPackage"

private let appModulesPackage: Package.Dependency = {
    let packagesDirectory = "../"
    let path = "\(packagesDirectory)/\(appModulePackageName)"
    return .package(path: path)
}()

private func makeModule(name: String) -> Target.Dependency {
    .product(name: name, package: appModulePackageName)
}

private let appModuleTargets: [Target.Dependency] = [
    makeModule(name: "Utilities"),
    makeModule(name: "AppDesignSystem"),
    makeModule(name: "AppEntities"),
    makeModule(name: "AppBaseFlow"),
    makeModule(name: "AppServices"),
    makeModule(name: "WelcomeFlow"),
    makeModule(name: "SignInFlow"),
    makeModule(name: "HomeFlow"),
    makeModule(name: "AppDevTools")
]

// MARK: - Package

let package = Package(
    name: umbrellaPackageName,
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: umbrellaPackageName,
            targets: [umbrellaPackageName]
        )
    ],
    dependencies: [appModulesPackage],
    targets: [
        .target(
            name: umbrellaPackageName,
            dependencies: appModuleTargets,
            path: "Sources"
        )
    ]
)
