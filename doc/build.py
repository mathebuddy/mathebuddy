# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

# This scripts compiles the documentation files from *.md to *.html

import shutil
import glob
from datetime import datetime
import os

# check dependencies
dependencies = [
    {"command": "pandoc", "package-macOS": "pandoc", "package-debian": "pandoc"}
]
for dep in dependencies:
    if shutil.which(dep["command"]) is None:
        print(dep["command"] + " is not installed")
        print("[Linux] run command: sudo apt install " + dep["package-macOS"])
        print("[macOS] run command: brew install " + dep["package-macOS"])
        exit(-1)

# create output directory and copy doc.css into it
os.system('mkdir -p build/')
os.system('cp doc.css build/')

# get current date in format YYYY-MM-DD
date = datetime.today().strftime('%Y-%m-%d')

# get links from file "links.txt"
f = open("links.txt", "r")
links = f.read()
print(links)
f.close()

# for each *.md file
files = glob.glob("*.md")
for file in files:
    out_path = 'build/docs-' + file.replace('.md', '.html')

    # get title
    f = open(file, "r")
    title = f.readlines()[0].replace('<!--', '').replace('-->', '').strip()
    f.close()

    # build
    cmd = 'pandoc -s ' + file + \
        ' --metadata title="' + title + '"' + \
        ' --metadata author=""' + \
        ' --metadata date="' + date + '"' + \
        ' --css doc.css ' + \
        ' --mathjax ' + \
        ' --standalone' + \
        ' -o ' + out_path
    os.system(cmd)

    # insert links
    f = open(out_path, "r")
    contents = f.read()
    f.close()
    contents = contents.replace(
        '<h1 class="title">', links + '<h1 class="title">')
    f = open(out_path, "w")
    f.write(contents)
    f.close()
