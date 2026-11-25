/**
    @file ObjectiveCPackTests.swift
    @author Warren Mann
    @copyright
    Copyright © 2026 BitArts, Ltd (warren@bitarts.us). MIT License: see LICENSE.
    @brief Tests for the Objective-C pack, run by `swift test`.
    @details
    The manifest against the embedded Info.plist, the language and its
    grammar, and that every node type the code-graph rules name is one
    tree-sitter-objc has (read from the vendored parser.c's symbol
    names), so a grammar update that renames one fails here. Loading the
    built pack is checked by AemberLanguageKit's Scripts/check-pack.sh.
*/

import Foundation
import Testing
import AemberLanguageKit
@testable import ObjectiveCPack

struct ObjectiveCPackTests {

    /// The repository's folder
    private let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()

    @Test func theManifestMatchesTheInfoPlist() throws {
        let plist = try #require(NSDictionary(contentsOf: root.appendingPathComponent("Info.plist")) as? [String: Any])
        let pack = ObjectiveCPack()
        #expect(pack.manifest.id == plist[LanguagePackInfoKey.identifier] as? String)
        #expect(pack.manifest.version.description == plist[LanguagePackInfoKey.version] as? String)
        #expect(pack.manifest.name.english == plist[LanguagePackInfoKey.name] as? String)
        let api = try #require(LanguagePackVersion(plist[LanguagePackInfoKey.apiVersion] as? String ?? ""))
        #expect(LanguagePackAPI.isCompatible(api))
    }

    @Test func objectiveCFilesWithTheirGrammar() throws {
        let language = try #require(ObjectiveCPack().languages.first)
        #expect(language.id == "objc")
        #expect(language.extensions == ["m"])
        #expect(language.lspLanguageID == "objective-c")
        #expect(language.inheritsQueriesFrom == "c")
        #expect(language.grammar?.language() != nil)
        #expect(language.queries.highlights?.contains("@keyword") == true)
    }

    @Test func theRulesNameTheGrammarsNodeTypes() throws {
        let parser = try String(contentsOf: root.appendingPathComponent("Grammar/src/parser.c"), encoding: .utf8)
        // The grammar's named node types: [sym_x] = "x" and aliases
        let pattern = try NSRegularExpression(pattern: #"\[(?:sym|alias_sym)_\w+\] = "([^"]+)""#)
        let names = Set(pattern.matches(in: parser, range: NSRange(parser.startIndex..., in: parser)).compactMap {
            Range($0.range(at: 1), in: parser).map { String(parser[$0]) }
        })
        let rules = ObjectiveCPack.codeGraph
        let named = Set(rules.symbols.keys).union(rules.imports).union(rules.anonymousFunctions).union(rules.nameChildTypes.keys).union(rules.nameChildTypes.values)
        #expect(named.subtracting(names).isEmpty, "not in tree-sitter-objc: \(named.subtracting(names).sorted())")
    }
}
