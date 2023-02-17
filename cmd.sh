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
    echo "[1] install"
    echo "[2] run tests"
    echo "[3] run simulator locally"
    echo "[4] exit"
    read x
    case $x in
    1)
        cd bin
        python3 install.py
        cd ..
        ;;
    2)
        cd lib
        ./test.sh
        cd ..
        ;;
    3)
        cd bin
        python3 sim.py
        cd ..
        ;;
    *)
        echo ".. bye!"
        exit 0
        ;;
    esac
done
