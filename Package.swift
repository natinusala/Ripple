// swift-tools-version: 5.6

/*
    Copyright 2021 natinusala

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

import PackageDescription

/// Should debug features of Yoga be enabled?
let debugYoga = false

/// Should we link against the debug Skia build?
let debugSkia = false

let package = Package(
    name: "Ripple",
    products: [
        .executable(name: "RippleDemo", targets: ["RippleDemo"]),
        .library(name: "Ripple", targets: ["Ripple"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-backtrace.git", .upToNextMajor(from: "1.3.1")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0"),
        .package(url: "https://github.com/natinusala/Async.git", branch: "a20ccabfdaf740f14b42eadf46fa9baac882078f"),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "CYoga",
            path: "External/CYoga",
            exclude: [
                "java",
                "javascript",
                "testutil",
                "website",
                "android",
                "lib",
                "tests",
                "tools",
                "util",
                "gentest",
                "mode",
                "csharp",
                "gradle",
                "scripts",
                "benchmark",
                "YogaKit",
                "yogacore",
                "enums.py",
                "gradle.properties",
                "third-party(Yoga).xcconfig",
                "CONTRIBUTING.md",
                "YogaKit.podspec",
                "BUCK",
                "gradlew.bat",
                "gradlew",
                "build.gradle",
                "CMakeLists.txt",
                "settings.gradle",
                "LICENSE-examples",
                "LICENSE",
                "Yoga.podspec",
                "README.md",
                "CODE_OF_CONDUCT.md",
            ],
            sources: ["yoga"],
            publicHeadersPath: ".",
            cSettings: debugYoga ? [.define("DEBUG")] : []
        ),
        .target(name: "Yoga", dependencies: ["CYoga"], path: "External/Yoga"),
        .executableTarget(
            name: "RippleDemo",
            dependencies: ["Ripple"]
        ),
        .target(
            name: "RippleCore",
            dependencies: [
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
                "OpenCombine",
                "Async",
                "Rainbow",
            ],
            linkerSettings: [.linkedLibrary("pthread")] // XXX: Necessary for OpenCombine to link, why?
        ),
        .target(
            name: "CGlad",
            path: "External/CGlad"
        ),
        .target(
            name: "Glad",
            dependencies: ["CGlad"],
            path: "External/Glad"
        ),
        .systemLibrary(name: "GLFW", path: "External/GLFW", pkgConfig: "glfw3"),
        .systemLibrary(name: "Skia", path: "External/Skia", pkgConfig: debugSkia ? "skia_loftwing_debug" : "skia_loftwing"),
        .target(
            name: "CRippleUI",
            dependencies: ["CGlad"]
        ),
        .target(
            name: "RippleUI",
            dependencies: [
                .product(name: "Backtrace", package: "swift-backtrace"),
                "RippleCore",
                "Yoga",
                "CRippleUI",
                "GLFW",
                "Glad",
                "Skia",
            ]
        ),
        .target(
            name: "Ripple",
            dependencies: [
                "RippleCore",
                "RippleUI",
            ]
        ),
        .testTarget(
            name: "RippleCoreTests",
            dependencies: ["RippleCore"]
        ),
    ]
)
