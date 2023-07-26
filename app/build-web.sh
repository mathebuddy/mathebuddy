#!/bin/bash

# more info: https://docs.flutter.dev/deployment/web

# build web app  (auto := html for mobile, canvaskit for desktop)

# ===== TODO: reenable first one, after fixing vscode plugin issues! ===== 
#flutter build web --web-renderer auto --release --no-tree-shake-icons 
flutter build web --web-renderer auto --profile --no-tree-shake-icons --dart-define=Dart2jsOptimization=O0


# update website
rm -rf ../docs/sim
cp -r build/web/ ../docs/sim

rm -rf ../docs/sim-ghpages
mkdir -p ../docs/sim-ghpages
cp ../docs/sim/index.html ../docs/sim-ghpages/index.html

cd ../docs/sim-ghpages/
ln -s ../sim/.last_build_id .
ln -s ../sim/assets .
ln -s ../sim/canvaskit .
ln -s ../sim/favicon.png .
ln -s ../sim/flutter_service_worker.js .
ln -s ../sim/flutter.js .
ln -s ../sim/icons .
ln -s ../sim/logo.png .
ln -s ../sim/main.dart.js .
ln -s ../sim/manifest.json .
ln -s ../sim/version.json .

cd ../sim/

# for localhost: replace <base href="/"> by <base href="/sim/">
sed -i.bak 's/<base href="\/" \/>/<base href="\/sim\/" \/>/g' index.html 
rm index.html.bak

cd ../sim-ghpages/

# for github pages: replace <base href="/"> by <base href="/mathebuddy-sim/">
sed -i.bak 's/<base href="\/" \/>/<base href="\/mathebuddy\/sim-ghpages\/" \/>/g' index.html 
rm index.html.bak
