# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

import json

out_path = 'data/smpl-tests.json'
in_paths = ['../../compiler/test/data/demo-ma2/ma2-1.mbl']

programs = []
program = dict()

for path in in_paths:

    f = open(path, "r")
    lines = f.readlines()
    f.close()

    reading_code = False
    for line in lines:
        if line.startswith('EXERCISE'):
            if 'title' in program:
                programs.append(program)
            program = dict()
            program['title'] = line[8:].strip()
        if line.startswith('@code'):
            reading_code = True
            program['code'] = ''
        elif line.startswith('@') or line.startswith('---'):
            reading_code = False
        elif reading_code:
            program['code'] += line
    programs.append(program)

res = {'programs': programs}

res_json = json.dumps(res, indent=2)

print(res_json)

f = open(out_path, "w")
f.write(res_json)
f.close()
