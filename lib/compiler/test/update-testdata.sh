#!/bin/bash
rm -rf data/
git clone https://github.com/mathebuddy/mathebuddy-public-courses.git data
rm -rf data/.git*
rm -rf data/.vscode
rm data/LICENSE
rm data/README.md
rm data/server.py
