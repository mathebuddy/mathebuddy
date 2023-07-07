/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

import 'color.dart';
import 'home.dart';

var showDebugReleaseSwitch = true;
var debugMode = true;

void main() {
  if (html.window.location.href.contains("mathebuddy.github.io/alpha/")) {
    showDebugReleaseSwitch = false;
    debugMode = false;
  }
  runApp(MaterialApp(
      title: 'mathe:buddy',
      theme: ThemeData(
        primarySwatch: buildMaterialColor(Color(0xFFFFFFFF)),
      ),
      home: const HomeWidget(),
      debugShowCheckedModeBanner: false));
}
