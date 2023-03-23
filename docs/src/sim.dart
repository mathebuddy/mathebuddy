/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

// ignore: avoid_relative_lib_imports
import '../../lib/compiler/src/compiler.dart';

import 'help.dart';

// TODO: comment variables and methods!!
List<String> simPath = [];
var simURL = "";
var simBaseDir = "demo/";

var mblData = "";
var mbclData = "";

var dataArea = html.document.getElementById("sim-data-area") as html.DivElement;
var logArea = html.document.getElementById("sim-log-area") as html.DivElement;

void init() {
  html.querySelector('#showSimInfo')?.onClick.listen((event) {
    html.querySelector('#sim-info')?.style.display = 'block';
    html.querySelector('#sim')?.style.display = 'none';
  });
  html.querySelector('#showSimDemo')?.onClick.listen((event) {
    html.querySelector('#sim-info')?.style.display = 'none';
    showSim('demo');
  });
  html.querySelector('#showSimLocalhost')?.onClick.listen((event) {
    html.querySelector('#sim-info')?.style.display = 'none';
    showSim('localhost');
  });
  html.querySelector('#resetSim')?.onClick.listen((event) {
    resetSim();
  });
  html.querySelector('#simShowMblButton')?.onClick.listen((event) {
    showMbl();
  });
  html.querySelector('#simShowMbclButton')?.onClick.listen((event) {
    showMbcl();
  });
}

// virtual file system
Map<String, String> fs = {};

String loadFunction(String path) {
  if (fs.containsKey(path)) {
    return fs[path] as String;
  } else {
    return '';
  }
}

String compileMblCode(String src) {
  var compiler = Compiler(loadFunction);
  try {
    fs["test.mbl"] = src;
    compiler.compile('test.mbl');
    var y = compiler.getCourse()?.toJSON();
    var jsonStr = JsonEncoder.withIndent("  ").convert(y);
    logArea.innerHtml = '... compilation to MBCL was successful!';
    return jsonStr;
  } catch (e) {
    logArea.innerHtml = e.toString();
    return '';
  }
}

void showSim(String location) {
  var src = html.window.location.host.contains("localhost")
      ? "sim/index.html"
      : "sim-ghpages/index.html";
  simURL = '$src?ver=${DateTime.now().millisecondsSinceEpoch}';
  //resetSim();
  html.document.getElementById("sim")?.style.display = "block";
  simBaseDir = location == "demo" ? "demo/" : "http://localhost:8271/";
  updateSimPathButtons();
}

void resetSim() {
  if (simURL.isNotEmpty) {
    (html.document.getElementById("sim-iframe") as html.IFrameElement).src =
        simURL;
  }
  Timer(Duration(milliseconds: 500), () => sendCourseToSim());
}

void sendCourseToSim() {
  var e = html.document.getElementById("sim-iframe") as html.IFrameElement;
  e.contentWindow?.postMessage(htmlSafe(mbclData), '*');
}

void updateSimPathButtons() {
  var path = simBaseDir + simPath.join("/");
  if (simPath.isEmpty || simPath[simPath.length - 1].endsWith("/")) {
    getFilesFromDir(path).then((files) {
      // only keep directories and .mbl files
      List<String> filesList = [];
      for (var file in files) {
        if (file.endsWith(".mbl") || file.endsWith("/")) filesList.add(file);
      }
      files = filesList;
      // add dir-up button
      if (simPath.isNotEmpty && files.contains("..") == false) {
        files.insert(0, "..");
      }
      // create buttons
      updateSimPathButtonsCore(files);
    });
  } else if (simPath.isNotEmpty &&
      simPath[simPath.length - 1].endsWith(".mbl")) {
    loadMblFile(path);
  }
  // TODO: reactivate message in div "localhost-error-info"!
}

void loadMblFile(String path) {
  readTextFile(path).then((text) {
    mblData = text;
    updateSimPathButtonsCore(simPath.isNotEmpty ? [".."] : []);
    showMbl();
    // compile
    mbclData = compileMblCode(mblData);
  });
}

void showMbl() {
  var tmp = htmlSafe(mblData);
  dataArea.innerHtml = "MBL Code:<br/><pre><code>$tmp</code></pre>";
}

void showMbcl() {
  var tmp = htmlSafe(mbclData);
  dataArea.innerHtml = "MBCL Code:<br/><pre><code>$tmp</code></pre>";
}

String htmlSafe(String s) {
  s = s.replaceAll("<", '&lt;');
  s = s.replaceAll(">", '&gt;');
  s = s.replaceAll("\"", '&quot;');
  s = s.replaceAll("'", '&#039;');
  return s;
}

void updateSimPathButtonsCore(List<String> files) {
  var simPathButtons =
      html.document.getElementById("sim-path-buttons") as html.SpanElement;
  simPathButtons.innerHtml = "";
  for (var file in files) {
    var button = html.document.createElement("button");
    button.classes.add("button");
    button.innerHtml = file;
    simPathButtons.append(button);
    var span = html.document.createElement("span");
    span.innerHtml = "&nbsp;";
    simPathButtons.append(span);
    button.onClick.listen((event) {
      if (file == "..") {
        simPath.removeLast();
      } else {
        simPath.add(file);
      }
      updateSimPath();
      updateSimPathButtons();
    });
  }
}

void updateSimPath() {
  var e = html.document.getElementById("sim-current-path");
  var p = "";
  for (var i = 0; i < simPath.length; i++) {
    p += "&raquo; ${simPath[i].replaceAll("/", "")} ";
  }
  p += "<br/>";
  e?.innerHtml = p;
}
