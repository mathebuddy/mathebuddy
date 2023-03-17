/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:html' as html;

import '../../lib/chat/src/chat.dart';

var chat = Chat();

void chatPlayground() {
  updateChatHistory();

  var reset = html.querySelector('#chat-reset') as html.ButtonElement;
  reset.onClick.listen((event) {
    chat = Chat();
    updateChatHistory();
  });

  var input = html.querySelector("#chat-input") as html.InputElement;
  input.value = '';
  input.onKeyPress.listen((event) {
    if (event.keyCode == html.KeyCode.ENTER) {
      var studentMessage = input.value as String;
      print(studentMessage);
      chat.chat(studentMessage);
      input.value = '';
      updateChatHistory();
      var bodyElement = html.document.body as html.BodyElement;
      html.window.scrollTo(0, bodyElement.scrollHeight);
    }
  });
}

void updateChatHistory() {
  var chatDiv = html.document.getElementById('chat-content') as html.DivElement;
  chatDiv.innerHtml = '';
  var history = chat.getChatHistory();
  for (var message in history) {
    var isBot = message.startsWith('B:');
    message = message.substring(2);

    var row = html.document.createElement('div') as html.DivElement;
    row.classes.add('row');
    chatDiv.append(row);

    var box = html.document.createElement('div') as html.DivElement;
    row.append(box);
    box.classes.addAll(['ten', 'columns']);
    if (isBot == false) {
      box.classes.add('offset-by-two');
      box.style.textAlign = 'right';
    }
    box.style.borderStyle = 'solid';
    box.style.borderRadius = '4px';
    box.style.borderWidth = '2px';
    box.style.marginTop = '2px';
    box.style.marginBottom = '2px';
    box.style.cursor = 'pointer';
    box.style.paddingTop = '3px';
    box.style.paddingBottom = '3px';

    if (isBot) {
      var logo = html.document.createElement('img') as html.ImageElement;
      logo.src = 'img/logo/logo.svg';
      logo.style.marginLeft = '3px';
      logo.style.marginRight = '3px';
      logo.style.height = logo.style.maxHeight = '12px';
      box.append(logo);
    }

    var span = html.document.createElement('span') as html.SpanElement;
    if (isBot) {
      span.innerHtml = message;
    } else {
      span.innerHtml = '$message&nbsp';
    }
    box.append(span);
  }
}
