/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the home screen widget that contains the list of
/// courses.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

import 'package:mathebuddy/mbcl/src/persistence.dart';

import 'package:mathebuddy/main.dart';

// TODO: exceptions / file revisions / ...

class AppPersistence implements MbclPersistence {
  String documentsPath = '';

  AppPersistence() {
    if (kIsWeb) {
      documentsPath = "userdata/";
    } else {
      getApplicationDocumentsDirectory().then((data) {
        print("=== PATH ===");
        documentsPath = data.path;
        print(documentsPath);

        //var file = File("$documentsPath/hello.txt");
        //file.writeAsStringSync("hello, world!\n");
      });
    }
  }

  @override
  Future<String> readFile(String localPath) async {
    if (kIsWeb) {
      if (websiteDevMode) {
        localPath = "$documentsPath$localPath";
        var response =
            await http.get(Uri.parse("http://localhost:8271/$localPath"));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("failed to load $localPath");
        }
      } else {
        //var msg = "WARNING: reading file '$localPath' is not supported";
        //throw Exception(msg);
        if (html.window.localStorage.containsKey(localPath)) {
          return html.window.localStorage[localPath]!;
        } else {
          throw Exception("failed to load $localPath");
        }
      }
    } else {
      var file = File("$documentsPath/$localPath");
      return file.readAsString();
    }
  }

  @override
  void writeFile(String localPath, String data) {
    if (kIsWeb) {
      if (websiteDevMode) {
        localPath = "$documentsPath$localPath";
        http.post(Uri.parse("http://localhost:8271/$localPath"),
            headers: <String, String>{
              //'Content-Type': 'application/json; charset=UTF-8',
              'Content-Type': 'text/plain; charset=UTF-8',
            },
            // body: jsonEncode(<String, String>{
            //   'title': "hello, world!",
            // }),
            body: data);
      } else {
        //print("WARNING: writing file '$localPath' is not supported");
        html.window.localStorage[localPath] = data;
        // console.log(window.localStorage.getItem("blub"));
      }
    } else {
      var file = File("$documentsPath/$localPath");
      file.writeAsStringSync(data);
    }
  }
}
