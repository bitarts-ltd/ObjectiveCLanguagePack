# Objective-C Language Pack

Objective-C for [Aember](https://aember.app): `.m` files highlighted
with [tree-sitter-objc](https://github.com/tree-sitter-grammars/tree-sitter-objc),
read by Aember's code graph, and served by clangd.

Aember doesn't include it: install it from Settings ▸ Languages, under
Available, or open a built `objective-c.aemberpack`.

- **Highlighting:** tree-sitter-objc's query, after C's (the grammar
  extends C's), with its captures renamed to the names Aember colours
  (see the top of `Queries/highlights.scm`).
- **Language server:** clangd, from the C Family pack that comes with
  Aember, which serves the `objective-c` language. Keep C Family
  enabled.
- **Builds:** Xcode projects (the Swift pack), CMake and Make (C
  Family) already build Objective-C.
- **Code graph:** `@interface` as a class, `@implementation` as an
  extension of it, `@protocol`, methods by their selector's first
  part, properties, blocks, C functions, structs and enums, `#import`
  and `@import`.
- `.mm` files stay C++ in C Family: no grammar reads Objective-C++
  well.

It is written with [AemberLanguageKit](https://github.com/bitarts-ltd/AemberLanguageKit),
whose README is the specification for language packs, and started
from its template.

## Building

You need AemberLanguageKit beside this repository (or its
`AemberLanguageKit.xcframework` copied here) and Xcode 16 or later.

```bash
../AemberLanguageKit/Scripts/build-xcframework.sh
```

```bash
cp -R ../AemberLanguageKit/build/AemberLanguageKit.xcframework .
```

```bash
swift test
```

```bash
../AemberLanguageKit/Scripts/build-pack.sh . --sign "Developer ID Application: BitArts Ltd (YMT43R5FT7)"
```

```bash
../AemberLanguageKit/Scripts/check-pack.sh build/objective-c.aemberpack
```

`build/objective-c.aemberpack` is the pack. Without BitArts' signing
identity, leave out `--sign`: Aember then asks before running it.

## Updating the grammar

`Grammar/` is tree-sitter-objc as it is upstream (`Grammar/SOURCE`
names the commit). With a newer checkout:

```bash
../AemberLanguageKit/Scripts/vendor-grammar.py "$PWD" ~/src/tree-sitter-objc tree_sitter_objc
```

That replaces `Queries/highlights.scm` only when it is missing, so
compare it with the checkout's `queries/highlights.scm` by hand, then:

```bash
../AemberLanguageKit/Scripts/embed-queries.py Queries Sources/PackQueries.swift
```

`swift test` checks that every node type the code-graph rules name is
still in the grammar.

## License

MIT (`LICENSE`). tree-sitter-objc is its authors', under its own MIT
license (`Grammar/LICENSE`).
