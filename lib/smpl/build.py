# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

grammar = ""

paths = ["src/parser.dart"]

for path in paths:
    f = open(path, "r")
    lines = f.readlines()
    f.close()
    recording = False
    for line in lines:
        if line.startswith("///") is False:
            continue
        line = line[4:]
        if line.startswith("<GRAMMAR"):
            recording = True
        if recording:
            grammar += line
        if line.startswith("</GRAMMAR"):
            recording = False

f = open("grammar.txt", "w")
f.writelines(grammar)
f.close()

# print(grammar)
