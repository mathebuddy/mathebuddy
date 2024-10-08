/// MatheBuddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../mbcl/src/course.dart';

import '../src/compiler.dart';

// load function that allows the compiler to read files dynamically by request
String load(String path) {
  //var pwd = Directory.current;
  if (File(path).existsSync() == false) {
    return '';
  } else {
    return File(path).readAsStringSync();
  }
}

void compile(String pathIn) {
  var compiler = Compiler(load);
  compiler.compile(pathIn);
  var y = compiler.getCourse()?.toJSON();
  var jsonStr = JsonEncoder.withIndent("  ").convert(y);
  print(jsonStr);
  var pathOut = '${pathIn.substring(0, pathIn.length - 4)}_COMPILED.json';
  File(pathOut).writeAsStringSync(jsonStr);

  var dec = jsonDecode(jsonStr);
  var reimportTest = MbclCourse();
  try {
    reimportTest.fromJSON(dec);
    var y2 = reimportTest.toJSON();
    var jsonStr2 = JsonEncoder.withIndent("  ").convert(y2);
    print(jsonStr2);
    pathOut = '${pathIn.substring(0, pathIn.length - 4)}_COMPILED_2.json';
    File(pathOut).writeAsStringSync(jsonStr2);
    if (jsonStr != jsonStr2) {
      var a = jsonStr.split("\n");
      var b = jsonStr2.split("\n");
      if (a.length != b.length) {
        print("reimport of JSon fails: "
            "number of lines do not match: ${a.length} vs ${b.length}!");
      }
      var na = a.length;
      var nb = b.length;
      for (var i = 0; i < min(na, nb); i++) {
        var ai = a[i];
        var bi = b[i];
        if (ai != bi) {
          print("error reimport: line $i does not match:\n  $ai\n  $bi");
          break;
        }
      }
    }
    assert(jsonStr == jsonStr2, "reimport of JSon fails!");
    var softErrors = compiler.gatherErrors();
    if (softErrors.isNotEmpty) {
      print(">>> ERROR LOG >>>");
      print(softErrors);
      print(">>> END OF ERROR LOG >>>");
    }
  } catch (e) {
    print("ERROR: $e");
    assert(false);
  }
}

void main() {
  print('MatheBuddy Compiler (c) 2022-2024 by TH Koeln');

  // demo course
  print('=== TESTING DEMO FILES ===');

  var files = [
    'smoke-test.mbl',
    //'../../../../mathebuddy-public-courses/demo-course/course.mbl'
    //'../../../../mathebuddy-public-courses/demo-course/basics/index.mbl'
    //'../../../../mathebuddy-private-courses/hm1/komplex/index.mbl',
    //'../../../../mathebuddy-private-courses/hm1/course.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/exercises.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/hello.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/typography.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/exercises-simple.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/definitions.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/equations.mbl',
    //'../../../../mathebuddy-public-courses/demo-basic/examples.mbl',
    //'../../../../mathebuddy-public-courses/demo-ma2/ma2-1.mbl',
  ];
  for (var file in files) {
    print("******************* TESTING FILE $file *******************");
    compile('test/$file');
  }

  var bp = 1337;

  /*fs.writeFileSync(
    'examples/demo-course/course_COMPILED.json',
    JSON.stringify(compiler.getCourse().toJSON(), null, 2),
  );
  fs.writeFileSync(
    'examples/demo-course/course_COMPILED.hex',
    lz_string.compressToBase64(
      JSON.stringify(compiler.getCourse().toJSON(), null, 0),
    ),
    'base64',
  );*/

  /* TODO
  // demo files
  const inputPath = 'examples/';
  const files = fs.readdirSync(inputPath).sort();
  for (const file of files) {
    /*if (file.includes('hello.mbl')) {
      const bp = 1337;
    }*/
    const path = inputPath + file;
    if (path.endsWith('.mbl') == false) continue;
    print('=== TESTING FILE ' + path + ' ===');
    // compile file
    const compiler = new Compiler();
    compiler.compile(path, load);
    // write output as JSON
    const outputPath =
      inputPath + file.substring(0, file.length - 4) + '_COMPILED.json';
    fs.writeFileSync(
      outputPath,
      JSON.stringify(compiler.getCourse().toJSON(), null, 2),
    );
    // write output as compressed HEX file
    const outputCompressed = lz_string.compressToBase64(
      JSON.stringify(compiler.getCourse().toJSON(), null, 0),
    );
    const outputPathCompressed =
      inputPath + file.substring(0, file.length - 4) + '_COMPILED.hex';
    fs.writeFileSync(outputPathCompressed, outputCompressed, 'base64');
  }*/
}
