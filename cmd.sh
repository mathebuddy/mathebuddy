#!/bin/bash

# MatheBuddy - a gamified learning-app for higher math
# (c) 2022-2024 by TH Koeln
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
    echo "MatheBuddy CLI. Choose option and press [ENTER]"
    echo "[0]  update Dart dependencies"
    echo "[1]  build website"
    echo "[2]  build documentation"
    echo "[3]  build flutter web app"
    echo "[4a] build android app"
    echo "[4b] build iOS app"
    echo "[4c] build macOS app and update simulator in private-courses"
    echo "[5a] run website at http://localhost:8314"
    echo "[5b] run web app at http://localhost:8315"
    echo "[6] run tests"
    #echo "[7]  update testdata from mathebuddy-public-courses repo"
    echo "[8]  update grammar.txt in lib/*"
    echo "[9]  update file system files (_fs.txt) files in docs/demo/"
    echo "[10] show empty directories recursively"
    echo "[11] update bundle-debug"
    echo "[12] update bundle-alpha"
    echo "[13] update bundle-smoke"
    echo "[14] update bundle-websim"
    echo "[15] update bundle-bochum"
    echo "[20] update https://github.com/mathebuddy/alpha (must build web app + create bundle first)"
    echo "[21] update https://github.com/mathebuddy/smoke (must build web app + create bundle first)"
    echo "[22] update https://github.com/mathebuddy/bochum (must build web app + create bundle first)"
    echo "[99] exit"
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
        cd docs/doc
        python3 build.py
        cd ../..
        ;;
    3)
        # [3] build flutter web app
        cd app
        ./build-web.sh
        cd ..
        ;;
    4a)
        # [4a] build flutter android app
        cd app
        ./build-android.sh
        rm ../../alpha/android/*.apk
        rm ../../alpha/android/*.sha1
        cp build/app/outputs/flutter-apk/app-arm* ../../alpha/android/
        cd ..
        ;;
    4b)
        # [4b] build flutter iOS app
        cd app
        ./build-ios.sh
        cd ..
        ;;
    4c)
        # [4c] build flutter macOS app and update simulator in private-courses
        cd app
        ./build-macos.sh
        cd ..
        cd bin/bundler
        #  !!! TODO: using x64-Dart compiler to support both Intel and Apple Silicon
        #     https://dart.dev/get-dart/archive -> stable release macOS x64
        #       version MUST match    dart --version
        /Users/andi/Downloads/dart-sdk/bin/dart compile exe src/bundler.dart -o bundler
        cd ../..
        rm -rf ../mathebuddy-private-courses/tools/mathebuddy.app
        cp -R app/build/macos/Build/Products/Release/mathebuddy.app ../mathebuddy-private-courses/tools
        mv bin/bundler/bundler ../mathebuddy-private-courses/tools/
        ;;
    5a)
        # [5a] run website at http://localhost:8314
        cd docs
        python3 -m http.server 8314
        cd ..
        ;;
    5b)
        # [5b] run web app at http://localhost:8315
        cd app/build/web
        python3 -m http.server 8315
        cd ../../..
        ;;
    6)
        # [6] run tests
        cd lib
        ./test.sh
        cd ..
        ;;
    7)
        # [7] update testdata from mathebuddy-public-courses repo
        #cd lib/compiler/test/
        #./update-testdata.sh
        #cd ../../..
        #cd lib/smpl/test/
        #./update-testdata.sh
        #cd ../../..
        ;;
    8)  
        # [8] update grammar.txt in lib/*
        cd lib/
        ./build.sh
        cd ..
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
        # [11] create bundle-debug
        cd bin
        dart bundler/src/bundler.dart bundle-debug.txt ../app/assets/bundle-debug.json
        cd ..
        ;;
    12)
        # [12] create bundle-alpha
        cd bin
        dart bundler/src/bundler.dart bundle-alpha.txt ../app/assets/bundle-alpha.json
        cd ..
        ;;
    13)
        # [13] create bundle-smoke
        cd bin
        dart bundler/src/bundler.dart bundle-smoke.txt ../app/assets/bundle-smoke.json
        cd ..
        ;;
    14)
        # [14] create bundle-websim
        cd bin
        dart bundler/src/bundler.dart bundle-websim.txt ../app/assets/bundle-websim.json
        cd ..
        ;;
    15)
        # [15] create bundle-bochum
        cd bin
        dart bundler/src/bundler.dart bundle-bochum.txt ../app/assets/bundle-bochum.json
        cd ..
        ;;
    20)
        # [20] update https://github.com/mathebuddy/alpha
        DIR="../alpha/"
        if [ -d "$DIR" ]; then
            rm -rf ../alpha/docs/
            mkdir -p ../alpha/docs/
            cp -r app/build/web/* ../alpha/docs/
            sed -i.bak 's/<base href="\/" \/>/<base href="\/alpha\/" \/>/g' ../alpha/docs/index.html
            #sed -i.bak 's/bundle-test.json/bundle-complex.json/g' ../alpha/docs/index.html
        else
            echo "ERROR: alpha-repository must be placed next to mathebuddy repo"
        fi
        ;;
    21)
        # [21] update https://github.com/mathebuddy/smoke
        DIR="../smoke/"
        if [ -d "$DIR" ]; then
            rm -rf ../smoke/docs/
            mkdir -p ../smoke/docs/
            cp -r app/build/web/* ../smoke/docs/
            sed -i.bak 's/<base href="\/" \/>/<base href="\/smoke\/" \/>/g' ../smoke/docs/index.html
        else
            echo "ERROR: smoke-repository must be placed next to mathebuddy repo"
        fi
        ;;
    22)
        # [22] update https://github.com/mathebuddy/bochum
        DIR="../bochum/"
        if [ -d "$DIR" ]; then
            rm -rf ../bochum/docs/
            mkdir -p ../bochum/docs/
            cp -r app/build/web/* ../bochum/docs/
            sed -i.bak 's/<base href="\/" \/>/<base href="\/bochum\/" \/>/g' ../bochum/docs/index.html
        else
            echo "ERROR: smoke-repository must be placed next to mathebuddy repo"
        fi
        ;;
    *)
        # [*] exit
        echo ".. bye!"
        exit 0
        ;;
    esac
done
