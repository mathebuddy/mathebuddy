#!/bin/bash

# more info: https://docs.flutter.dev/deployment/android

#flutter build appbundle
flutter build apk --split-per-abi --no-tree-shake-icons
