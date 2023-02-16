#!/bin/bash
git pull
npm install

wget -O docs-mbl.html https://raw.githubusercontent.com/mathebuddy/mathebuddy-compiler/main/mbl.html
wget -O docs-smpl.html https://raw.githubusercontent.com/mathebuddy/mathebuddy-smpl/main/smpl.html
wget -O docs-mbcl.html https://raw.githubusercontent.com/mathebuddy/mathebuddy-compiler/main/mbcl.html
wget -O docs-sim.html https://raw.githubusercontent.com/mathebuddy/mathebuddy-simulator/main/sim.html
