#!/bin/bash
dart compile js src/index.dart -O4 -o js/index.min.js

cp ../lib/math-runtime/grammar.txt text/math-runtime-grammar.txt
cp ../lib/smpl/grammar.txt text/smpl-grammar.txt
cp ../lib/compiler/grammar.txt text/mbl-grammar.txt

python3 build.py
