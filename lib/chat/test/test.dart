/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import '../src/chat.dart';

void main() {
  print('hello');
  stdout.write('>> ');
  var x = stdin.readLineSync(encoding: utf8);
  print('.. you typed $x');
}
