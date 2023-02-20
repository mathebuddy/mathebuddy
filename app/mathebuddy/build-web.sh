#!/bin/bash
#flutter build web --web-renderer canvaskit --release
#flutter build web --web-renderer html --release
flutter build web --web-renderer auto --release  # auto := html for mobile, canvaskit for desktop

# update website
rm -rf ../../docs/sim
cp -r build/web/ ../../docs/sim

# replace <base href="/"> by <base href="/sim/">
sed -i.bak 's/<base href="\/">/<base href="\/sim\/">/g' ../../docs/sim/index.html 
rm ../../docs/sim/index.html.bak
