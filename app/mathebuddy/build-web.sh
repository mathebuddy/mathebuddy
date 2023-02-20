#!/bin/bash
#flutter build web --web-renderer canvaskit --release
#flutter build web --web-renderer html --release
flutter build web --web-renderer auto --release  # auto := html for mobile, canvaskit for desktop
