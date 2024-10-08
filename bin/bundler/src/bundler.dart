/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import '../../../lib/compiler/src/compiler.dart';

String loadFile(String path) {
  try {
    if (path.endsWith(".jpg")) {
      var bytes = File(path).readAsBytesSync();
      return base64Encode(bytes);
    } else {
      return File(path).readAsStringSync();
    }
  } catch (e) {
    print("ERROR: file '$path' does not exist"
        " (current directory is '${Directory.current.path}')!");
    exit(-1);
  }
}

void main(List<String> args) {
  print('MatheBuddy course bundler tool');
  if (args.length != 2) {
    print('ERROR: usage: bundler.dart INPUT_BUNDLE_FILE_PATH OUTPUT_FILE_PATH');
    exit(-1);
  }
  // read bundle file
  var bundleFilePath = args[0];
  if (File(bundleFilePath).existsSync() == false) {
    print("ERROR: bundle file '$bundleFilePath' does not exist");
    exit(-1);
  }
  var bundleFileSrc = File(bundleFilePath).readAsStringSync();
  // bundle
  var bundle = Map<String, Map<String, Object>>();
  bundle["__type"] = {"type": "mathebuddy_bundle"};
  // parse bundle file + compile
  var lines = bundleFileSrc.split("\n");
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    var tokens = line.split(':');
    if (tokens.length != 2) {
      print(
          'ERROR: line "$line" in bundle file "$bundleFilePath" is not well formatted');
    }
    var id = tokens[0];
    var path = tokens[1];
    print("... processing '$id' ...");
    // compile
    var compiler = new Compiler(loadFile);
    try {
      compiler.compile(path);
      var output = compiler.getCourse()?.toJSON() as Map<String, Object>;
      bundle[id] = output;
      var softErrors = compiler.gatherErrors();
      if (softErrors.isNotEmpty) {
        print(">>> ERROR LOG >>>");
        print(softErrors);
        print(">>> END OF ERROR LOG >>>");
      }
    } catch (e) {
      print("ERROR: $e");
      exit(-1);
    }
  }
  // generate JSON file
  var json = JsonEncoder.withIndent("  ").convert(bundle);
  var outputFilePath = args[1];
  File(outputFilePath).writeAsStringSync(json);
  exit(0);
}
