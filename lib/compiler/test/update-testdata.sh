#!/bin/bash
rm -rf data/
if [ -d "../../../../mathebuddy-public-courses" ]; then
    cp -r ../../../../mathebuddy-public-courses data
else
    git clone https://github.com/mathebuddy/mathebuddy-public-courses.git data
fi
rm -rf data/.git*
rm -rf data/.vscode
rm data/LICENSE
rm data/README.md
rm data/server.py
