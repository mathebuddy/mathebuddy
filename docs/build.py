# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

# This script updates the Script version numbers in file "index.html"
# to force browsers to load the most recent version.

import time

# get unit time
unix_time = int(time.time())

# read index.html
f = open("index.html", "r")
lines = f.readlines()
f.close()

# replace version number(s)
for i, line in enumerate(lines):
    if '?version=' in line:
        tokens = line.split('?')
        lines[i] = tokens[0] + '?version=' + str(unix_time) + '"></script>\n'

# write index.html
f = open("index.html", "w")
f.write("".join(lines))
f.close()
