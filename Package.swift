// swift-tools-version: 6.0
/**
    @file Package.swift
    @brief The Objective-C language pack, for its tests.
    @details
    `swift test` runs the pack's tests against AemberLanguageKit.xcframework,
    which this folder needs a copy of (download it from AemberLanguageKit's
    releases, or build it with that repository's
    Scripts/build-xcframework.sh). The .aemberpack itself is built by
    AemberLanguageKit's Scripts/build-pack.sh, which compiles the same
    sources with the pack's entry point.

    Once Scripts/vendor-grammar.py has put a grammar in Grammar/, its
    C is a target here too, TreeSitterGrammar, which the pack's Swift
    imports when it is built by SwiftPM:

        #if canImport(TreeSitterGrammar)
        import TreeSitterGrammar
        #endif

    (build-pack.sh gives the Swift the grammar through the bridging
    header instead).
*/

import Foundation
import PackageDescription

let folder = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path

/// The grammar's C files, if the pack has a grammar: parser.c and
/// scanner.c in Grammar/src, as vendor-grammar.py copies them
let grammarSources = ["src/parser.c", "src/scanner.c"].filter { FileManager.default.fileExists(atPath: "\(folder)/Grammar/\($0)") }
let hasGrammar = !grammarSources.isEmpty

let package = Package(
    name: "ObjectiveCPack",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .binaryTarget(
            name: "AemberLanguageKit",
            path: "AemberLanguageKit.xcframework"
        ),
        .target(
            name: "ObjectiveCPack",
            dependencies: ["AemberLanguageKit"] + (hasGrammar ? ["TreeSitterGrammar"] : []),
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "ObjectiveCPackTests",
            dependencies: ["ObjectiveCPack", "AemberLanguageKit"],
            path: "Tests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ] + (hasGrammar ? [
        .target(
            name: "TreeSitterGrammar",
            path: "Grammar",
            exclude: ["LICENSE", "SOURCE"].filter { FileManager.default.fileExists(atPath: "\(folder)/Grammar/\($0)") },
            sources: grammarSources,
            publicHeadersPath: "include",
            cSettings: [.headerSearchPath("src"), .unsafeFlags(["-Wno-unused-parameter"])]
        ),
    ] : [])
)
