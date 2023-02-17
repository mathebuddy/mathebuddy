# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

import shutil

dependencies = [
    {"command": "flutter", "package-macOS": "flutter", "package-debian": "flutter"}
]

for dep in dependencies:
    if shutil.which(dep["command"]) is None:
        print(dep["command"] + " is not installed")
        print("[Linux] run command: sudo apt install " + dep["package-macOS"])
        print("[macOS] run command: brew install " + dep["package-macOS"])
        exit(-1)
