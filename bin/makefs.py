# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

import sys
import os
import json
import glob

# This file recursively creates textfiles that describe the contests of a directory,
# staring from a argument given base path.
# For each sub-directory, a file named "_fs.txt" is created. It contains each file of that
# directory in a separate line. Directories are written with forward-slash at the end.

# Why? Many Webservers (e.g. github pages) do not allow directory listening for security reasons.

# Usage: "python3 makefs.py BASE_PATH"

if len(sys.argv) < 2:
    print("ERROR: makefs.py expects a PATH argument (e.g. 'python3 makefs.py my-path')")
    exit(-1)

input_path = sys.argv[1]
if not input_path.endswith('/'):
    input_path = input_path + '/'


def build_dir(path):
    fs = ''
    files = glob.glob(path + '*')
    for file in files:
        base = os.path.basename(file)
        if os.path.isdir(file):
            build_dir(file + '/')
            fs += base + '/\n'
        else:
            fs += base + '\n'
    f = open(path + '_fs.txt', "w")
    f.write(fs)
    f.close()


build_dir(input_path)

exit(0)

# ---------------- old src. TODO: remove? ----------

# This file builds a JSON output that represents a filesystem
# Usage: e.g. to update /docs/demo/fs.json in this repository


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
