#!/bin/bash

# TODO: must create a release version + get THAT version here

mkdir -p src/
cd src/
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/src/lang.dart
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/src/lex.dart
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/src/state.dart
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/src/token.dart
cd ..
cd test/
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/test/example.dart
curl -O https://raw.githubusercontent.com/multila/multila-lexer/main/test/lex_TESTS.dart
