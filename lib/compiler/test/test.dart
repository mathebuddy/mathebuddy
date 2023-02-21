/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dart:convert';
import 'dart:io';

import '../src/compiler.dart';

// load function
String load(String path) {
  if (File(path).existsSync() == false)
    return '';
  else
    return File(path).readAsStringSync();
}

void main() {
  print('mathe:buddy Compiler (c) 2022-2023 by TH Koeln');

  // demo course
  print('=== TESTING DEMO COURSE ===');
  var compiler = new Compiler(load);
  //compiler.compile('examples/demo-course/course.mbl');
  compiler.compile('lib/compiler/test/data/demo-basic/hello.mbl');
  var y = compiler.getCourse()?.toJSON();
  var json = JsonEncoder().convert(y);
  print(json);

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
