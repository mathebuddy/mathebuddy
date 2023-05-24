/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:async';
import 'dart:html' as html;

void setTextInput(String elementId, String value) {
  (html.document.getElementById(elementId) as html.InputElement).value = value;
}

void setTextArea(String id, String value) {
  (html.document.getElementById(id) as html.TextAreaElement).value = value;
}

Future<String> readTextFile(String path) {
  return html.HttpRequest.getString(
          "$path?ver=${DateTime.now().millisecondsSinceEpoch}")
      .catchError((e) => throw Exception("failed to read file $path"))
      .then((value) => /*value.replaceAll("Hello",
          "Xxxxx"*/
          value.replaceAll("\r", "")); // Windows.... :-(
}

Future<List<String>> getFilesFromDir(String path) async {
  List<String> res = [];
  // a) try to do directory listing
  try {
    var data = await readTextFile(path);
    res = extractFilesFromDirectoryListingHtml(data);
  } catch (e) {
    print('reading _fs.txt');
    // b) try to read _fs.txt
    try {
      var data = await readTextFile('${path}_fs.txt');
      res = data.split('\n');
    } catch (e) {
      print("... failed to get files from dir '$path'");
    }
  }
  return Future.value(res);
}

Future<void> readDirRecursively(Map<String, String> fs, String path) async {
  path = path.replaceAll("//", "/").replaceAll("http:/", "http://");

  var fileList = await getFilesFromDir(path);
  for (var file in fileList) {
    print("readDirRecursively: $path, $file");
    if (file.endsWith("/")) {
      await readDirRecursively(fs, "$path/$file");
    } else {
      var p = "$path/$file";
      p = p.replaceAll("//", "/").replaceAll("http:/", "http://");
      fs[p] = await readTextFile("$path/$file");
    }
  }
}

List<String> extractFilesFromDirectoryListingHtml(String data) {
  List<String> files = [];
  var lines = data.split("\n");
  for (var line in lines) {
    if (line.startsWith('<li><a href="')) {
      var file = line.substring(13).split('"')[0];
      if (file.startsWith(".")) continue;
      //if (!file.endsWith("/") && !file.endsWith(".mbl")) continue;
      files.add(file);
    }
  }
  //console.log(files);
  files.sort();
  return files;
}
