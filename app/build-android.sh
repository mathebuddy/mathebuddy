#!/bin/bash

# more info: https://docs.flutter.dev/deployment/android

flutter build apk --split-per-abi --no-tree-shake-icons
flutter build appbundle --no-tree-shake-icons --release
