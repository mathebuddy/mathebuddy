#!/bin/bash
dart compile js math-runtime-playground.dart -O4 -o math-runtime-playground.min.js

cp ../lib/math-runtime/grammar.txt math-runtime-grammar.txt
cp ../lib/smpl/grammar.txt smpl-grammar.txt

python3 update.py
