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
while true
do
    echo "mathe:buddy CLI. Choose option and press [ENTER]"
    echo "[1] build website"
    echo "[2] build documentation"
    echo "[3] build flutter web app"
    echo "[4] run website at http://localhost:8314"
    echo "[5] run tests"
    echo "[6] exit"
    read x
    case $x in
    1)
        cd docs
        ./build.sh
        cd ..
        ;;
    2)
        cd doc
        python3 build.py
        cd ..
        ;;
    3)
        cd app/mathebuddy
        ./build-web.sh
        cd ../..
        ;;
    4)
        cd docs
        python3 -m http.server 8314
        cd ..
        ;;
    5)
        cd lib
        ./test.sh
        cd ..
        ;;
    *)
        echo ".. bye!"
        exit 0
        ;;
    esac
done
