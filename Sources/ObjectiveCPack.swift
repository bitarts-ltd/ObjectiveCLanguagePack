/**
    @file ObjectiveCPack.swift
    @author Warren Mann
    @copyright
    Copyright © 2026 BitArts, Ltd (warren@bitarts.us). MIT License: see LICENSE.
    @brief Aember's Objective-C language pack.
    @details
    Objective-C (.m) files, read with tree-sitter-objc (Grammar/), whose
    highlights add to C's: Aember puts C's query first. The C Family
    pack, which comes with Aember, runs clangd for them (its clangd
    serves the objective-c language), and builds come from the build
    systems that already build Objective-C: Xcode projects (the Swift
    pack), CMake and Make (C Family). .mm files stay C++ in C Family,
    since no grammar reads Objective-C++ well.

    The code graph reads @interface as a class and @implementation as
    an extension of it, @protocol, methods by their selector's first
    part, properties by their declarator, blocks as anonymous
    functions, and #import and @import.
*/

import Foundation
import AemberLanguageKit
#if canImport(TreeSitterGrammar)
import TreeSitterGrammar
#endif

/// @brief The Objective-C pack
final class ObjectiveCPack: LanguagePack {

    let manifest = LanguagePackManifest(
        id: "objective-c",
        name: "Objective-C",
        version: LanguagePackVersion(1, 0, 0),
        summary: LocalizedText("Objective-C files, with clangd from the C Family pack", translations: [
            "de": "Objective-C-Dateien, mit clangd aus dem C-Family-Paket",
            "es": "Archivos de Objective-C, con clangd del paquete C Family",
            "fr": "Fichiers Objective-C, avec clangd du pack C Family",
            "it": "File Objective-C, con clangd dal pacchetto C Family",
            "ja": "Objective-C ファイル。clangd は C Family パックのものを使います",
            "ru": "Файлы Objective-C, с clangd из пакета C Family",
        ]),
        author: "BitArts",
        homepage: URL(string: "https://github.com/bitarts-ltd/ObjectiveCLanguagePack")
    )

    var languages: [LanguageDefinition] {
        [
            LanguageDefinition(
                id: "objc",
                displayName: "Objective-C",
                extensions: ["m"],
                lspLanguageID: "objective-c",
                lineComment: "//",
                blockComment: (start: "/*", end: "*/"),
                docComment: "/**",
                grammar: Grammar(tree_sitter_objc, abiVersion: 14),
                queries: PackQueries.queries,
                inheritsQueriesFrom: "c",
                codeGraph: Self.codeGraph
            ),
        ]
    }

    /// How the code graph reads Objective-C trees
    static let codeGraph = CodeGraphRules(
        symbols: [
            // Objective-C
            "class_interface": .classDeclaration,
            "class_implementation": .extensionDeclaration,
            "protocol_declaration": .protocolDeclaration,
            "method_declaration": .method,
            "method_definition": .method,
            "struct_declarator": .property,
            // C
            "function_definition": .function,
            "struct_specifier": .structDeclaration,
            "enum_specifier": .enumDeclaration,
            "enumerator": .enumCase,
            "field_declaration": .property,
        ],
        nameChildTypes: [
            // A method's first identifier child is its selector's first
            // part; its return type comes before it
            "method_declaration": "identifier",
            "method_definition": "identifier",
        ],
        imports: ["preproc_include", "module_import"],
        anonymousFunctions: ["block_literal"]
    )
}

#if !SWIFT_PACKAGE
/// @brief Hands Aember the pack. Left out of SwiftPM builds, where the
/// pack is a module its tests link.
/// @return The pack, retained
@_cdecl("aember_language_pack")
public func aemberLanguagePack() -> UnsafeMutableRawPointer {
    LanguagePackAPI.export(ObjectiveCPack())
}
#endif
