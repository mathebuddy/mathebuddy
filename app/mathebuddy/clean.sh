#!/bin/bash
flutter clean
rm -rf ../../docs/sim
cp -r build/web/ ../../docs/sim

