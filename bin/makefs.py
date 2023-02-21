# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

# This file builds a JSON output that represents a filesystem
# Usage: e.g. to update /docs/demo/fs.json in this repository

import glob
import json
import os
import sys

if len(sys.argv) < 2:
    print("ERROR: makefs.py expects a PATH argument (e.g. 'python3 makefs.py my-path/')")
    exit(-1)

input_path = sys.argv[1]
if not input_path.endswith('/'):
    input_path = input_path + '/'
dir = {}

prefix = ''
if len(sys.argv) == 3:
    prefix = sys.argv[2]


def renameDir(p):
    return prefix + p[len(input_path)-1:]


def build_dir(path):
    files = glob.glob(path + '*')
    for file in files:
        if renameDir(path) not in dir:
            dir[renameDir(path)] = []
        if os.path.isdir(file):
            dir[renameDir(path)].append(os.path.basename(file) + '/')
            build_dir(file + '/')
        else:
            dir[renameDir(path)].append(os.path.basename(file))


build_dir(input_path)
j = json.dumps(dir, indent=2)
print(str(j))
