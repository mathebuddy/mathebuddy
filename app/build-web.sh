#!/bin/bash

# more info: https://docs.flutter.dev/deployment/web

# build web app
flutter build web --web-renderer auto --release  # auto := html for mobile, canvaskit for desktop

# update website
rm -rf ../docs/sim
cp -r build/web/ ../docs/sim

cp ../docs/sim/index.html ../docs/sim/index-github.html 

# for localhost: replace <base href="/"> by <base href="/sim/">
sed -i.bak 's/<base href="\/" \/>/<base href="\/sim\/" \/>/g' ../docs/sim/index.html 
rm ../docs/sim/index.html.bak

# for github pages: replace <base href="/"> by <base href="/mathebuddy-sim/">
sed -i.bak 's/<base href="\/" \/>/<base href="\/mathebuddy\/sim\/" \/>/g' ../docs/sim/index-github.html 
rm ../docs/sim/index-github.html.bak
