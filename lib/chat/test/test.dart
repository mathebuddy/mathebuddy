/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import '../src/chat.dart';

void main() {
  var chat = Chat();
  for (var message in chat.getChatHistory()) {
    print(message);
  }
  while (true) {
    stdout.write('>> ');
    var message = stdin.readLineSync(encoding: utf8) as String;
    if (message == 'exit') break;
    chat.chat(message);
    print(chat.getChatHistory().last);
  }
}
