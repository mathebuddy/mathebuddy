#!/bin/bash

# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

# --- CHECKS ---
if ! command -v python3 &> /dev/null
then
    echo "Error: python3 is NOT installed!"
    echo "[Linux] run command: sudo apt install python3"
    echo "[macOS] run command: brew install python3"
    exit 1
fi
cd bin
python3 check.py
cd ..

# --- REPL ---
# TODO: integrate "update grammar.txt in lib/*" to "build website"??
while true
do
    echo "mathe:buddy CLI. Choose option and press [ENTER]"
    echo "[0]  update Dart dependencies"
    echo "[1]  build website"
    echo "[2]  build documentation"
    echo "[3]  build flutter web app"
    echo "[4]  build android app"
    echo "[5]  run website at http://localhost:8314"
    echo "[6]  run tests"
    echo "[7]  update testdata from mathebuddy-public-courses repo"
    echo "[8]  update grammar.txt in lib/*"
    echo "[9]  update file system files (_fs.txt) files in docs/demo/"
    echo "[10] show empty directories recursively"
    echo "[11] create bundle of test courses"
    echo "[12] create bundle for alpha course"
    echo "[13] create bundle for complex numbers"
    echo "[14] update https://github.com/mathebuddy/alpha (must build web app + create bundle first)"
    echo "[15] exit"
    read x
    case $x in
    0)
        # [0] update Dart dependencies
        cd lib/compiler/
        dart pub get
        cd ../math-runtime/
        dart pub get
        cd ../smpl/
        dart pub get
        cd ../chat/
        dart pub get
        cd ../../app
        flutter pub get
        cd ..
        ;;
    1)
        # [1] build website
        cd docs
        ./build.sh
        cd ..
        ;;
    2)
        # [2] build documentation
        cd doc
        python3 build.py
        cd ..
        ;;
    3)
        # [3] build flutter web app
        cd app
        ./build-web.sh
        cd ..
        ;;
    4)
        # [4] build flutter android app
        cd app
        ./build-android.sh
        cd ..
        ;;
    5)
        # [5] run website at http://localhost:8314
        cd docs
        python3 -m http.server 8314
        cd ..
        ;;
    6)
        # [6] run tests
        cd lib
        ./test.sh
        cd ..
        ;;
    7)
        # [7] update testdata from mathebuddy-public-courses repo
        cd lib/compiler/test/
        ./update-testdata.sh
        cd ../../..
        cd lib/smpl/test/
        ./update-testdata.sh
        cd ../../..
        ;;
    8)  
        # [8] update grammar.txt in lib/*
        cd lib/
        ./build.sh
        ;;
    9)
        # [9] update file system files (_fs.txt) files in docs/demo/
        cd docs/demo/
        ./_makefs.sh
        cd ../..
        ;;
    10)
        # [10] show empty directories recursively
        find . -type d -empty -print
        ;;
    11)
        # [11] create bundle of test courses
        cd bin
        dart bundler/src/bundler.dart bundle-test.txt ../app/assets/bundle-test.json
        cd ..
        ;;
    12)
        # [12] create bundle for alpha course
        cd bin
        dart bundler/src/bundler.dart bundle-alpha.txt ../app/assets/bundle-alpha.json
        cd ..
        ;;
    13)
        # [13] create bundle for complex numbers
        cd bin
        dart bundler/src/bundler.dart bundle-complex.txt ../app/assets/bundle-complex.json
        cd ..
        ;;
    14)
        # [14] update https://github.com/mathebuddy/alpha
        DIR="../alpha/"
        if [ -d "$DIR" ]; then
            rm -rf ../alpha/docs/
            mkdir -p ../alpha/docs/
            cp -r app/build/web/* ../alpha/docs/
            sed -i.bak 's/<base href="\/" \/>/<base href="\/alpha\/" \/>/g' ../alpha/docs/index.html
            sed -i.bak 's/bundle-test.json/bundle-alpha.json/g' ../alpha/docs/index.html
        else
            echo "ERROR: alpha-repository must be placed next to mathebuddy repo"
        fi
        ;;
    *)
        # [*] exit
        echo ".. bye!"
        exit 0
        ;;
    esac
done
