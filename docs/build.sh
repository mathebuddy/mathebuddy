#!/bin/bash
dart compile js src/index.dart -O4 -o index.min.js

cp ../lib/math-runtime/grammar.txt math-runtime-grammar.txt
cp ../lib/smpl/grammar.txt smpl-grammar.txt
cp ../lib/compiler/grammar.txt mbl-grammar.txt

python3 update.py
