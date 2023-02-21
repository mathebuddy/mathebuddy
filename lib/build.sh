#!/bin/bash
cd math-runtime
./build.sh
cd ..

cd smpl
./build.sh
cd ..

cd compiler
./build.sh
cd ..
