/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';

import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/style.dart';

class ChatWidget extends StatefulWidget {
  final MbclCourse course;

  const ChatWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => ChatState();
}

enum MessageType {
  BotMessage,
  UserButton,
  UserTextField,
}

class ChatState extends State<ChatWidget> {
  @override
  void initState() {
    super.initState();
  }

  Column generateChatRow(String text, MessageType type) {
    var fontSize = 18.0;
    var color = type == MessageType.UserButton
        ? getStyle().matheBuddyRed.withOpacity(0.9)
        : Colors.black.withOpacity(0.85);
    var textColor = Colors.white;
    List<InlineSpan> textItems = [];
    if (type == MessageType.BotMessage) {
      var logo = WidgetSpan(
          child: SizedBox(
              height: 32,
              width: 45,
              child: Image.asset('assets/img/logo.png')));
      textItems.add(logo);
    }
    Widget content = Text('');
    if (type == MessageType.BotMessage || type == MessageType.UserButton) {
      textItems.add(TextSpan(
          text: text, style: TextStyle(fontSize: fontSize, color: textColor)));
      content = RichText(
          text: TextSpan(
        children: textItems,
      ));
    } else if (type == MessageType.UserTextField) {
      content = Column(children: [
        TextField(
            style: TextStyle(fontSize: fontSize, color: Colors.white),
            decoration: InputDecoration(filled: true, fillColor: Colors.black))
      ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
                color: color,
                border: Border.all(color: color, width: 2.5),
                borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: EdgeInsets.all(7.0),
              child: content,
            ),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatHistory = [];

    var row = generateChatRow(
        "Wie kann ich Dir helfen? Nenne mir ein Stichwort, oder klicke auf einen der roten Buttons.",
        MessageType.BotMessage);
    chatHistory.add(row);

    row = generateChatRow("Ich möchte trainieren", MessageType.UserButton);
    chatHistory.add(row);

    row = generateChatRow("", MessageType.UserTextField);
    chatHistory.add(row);

    var body = Column(children: [...chatHistory]);

    return Scaffold(
        appBar: buildAppBar(this, null),
        body: body,
        backgroundColor: Colors.white);
  }
}
