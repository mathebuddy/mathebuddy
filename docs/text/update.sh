#!/bin/bash
pandoc -s mbl.md --metadata title="MBL Specification" --mathjax --syntax-definition mbl-syntax.xml -o mbl.html
pandoc -s smpl.md --metadata title="SMPL Specification" --mathjax --syntax-definition mbl-syntax.xml -o smpl.html
