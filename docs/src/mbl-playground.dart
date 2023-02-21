/**
 * mathe:buddy - a gamified app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:convert';
import 'dart:html';

import '../../lib/compiler/src/compiler.dart';

import 'help.dart';

// TODO: add more examples in (yet not existing) drop-down menu
var example = '''Hello World
###########

Hello world from math buddy!

% this is a comment; intended for course developers
''';

void mblPlayground() {
  // get code
  setTextArea('mbl-editor', example);
  querySelector('#runMbl')?.onClick.listen((event) {
    var src = (querySelector('#mbl-editor') as TextAreaElement).value as String;
    //print(src);
    runMblCode(src);
  });
}

// virtual file system
// TODO: dynamic loading of dependent *.mbl files!
Map<String, String> fs = {"test.mbl": ""};
String load(String path) {
  if (fs.containsKey(path))
    return fs[path] as String;
  else
    return '';
}

void runMblCode(String src) {
  var compiler = new Compiler(load);
  try {
    fs["test.mbl"] = src;
    compiler.compile('test.mbl');
    var y = compiler.getCourse()?.toJSON();
    var json = JsonEncoder.withIndent("  ").convert(y);
    showOutput(json);
  } catch (e) {
    showOutput(e.toString());
  }
}

void showOutput(String o) {
  document.getElementById('mbl-output')?.innerHtml =
      '<pre><code>' + o + '</code></pre>';
}
