/**
    @file tree_sitter_objc.h
    @brief The ObjectiveC grammar's entry point, for the pack's Swift code.
*/

#ifndef TREE_SITTER_OBJC_H
#define TREE_SITTER_OBJC_H

typedef struct TSLanguage TSLanguage;

/// The ObjectiveC grammar
const TSLanguage *tree_sitter_objc(void);

#endif
