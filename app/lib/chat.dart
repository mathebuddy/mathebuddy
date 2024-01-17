/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/level.dart';
import 'package:mathebuddy/level_paragraph_item.dart';
import 'package:mathebuddy/main.dart';
import 'package:mathebuddy/style.dart';

import 'package:mathebuddy/math-runtime/src/parse.dart' as math_parse;

import 'package:mathebuddy/mbcl/src/course.dart';
import 'package:mathebuddy/mbcl/src/chapter.dart';
import 'package:mathebuddy/mbcl/src/level.dart';
import 'package:mathebuddy/mbcl/src/level_item.dart';

class ChatWidget extends StatefulWidget {
  final MbclCourse course;

  const ChatWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => ChatState();
}

enum MessageType {
  botMessage,
  userMessage,
  userButton,
  userTextField,
}

class ChatState extends State<ChatWidget> {
  List<Widget> chatHistory = [];

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    chatHistory = [];
    // greetings text
    chatHistory.add(generateChatRow(
        "Wie kann ich Dir helfen? Nenne mir ein Stichwort, oder klicke auf einen der roten Buttons.",
        [],
        MessageType.botMessage,
        () {}));
    // debug options
    if (debugMode) {
      // reset button
      chatHistory.add(generateChatRow(
          "[DEBUG] reset chat history", [], MessageType.userButton, () {
        reset();
        setState(() {});
      }));
      // list definitions
      chatHistory.add(generateChatRow(
          "[DEBUG] list all definitions", [], MessageType.userButton, () {
        var definitions = widget.course.chat.definitions;
        for (var key in definitions.keys) {
          var definition = definitions[key]!;
          var def = generateChatRow(
              "[$key;${definition.levelPath}] ",
              generateParagraph(definition.data),
              MessageType.botMessage,
              () {});
          chatHistory.add(def);
        }
        setState(() {});
      }));
    }
    // initial user button(s)
    chatHistory.add(generateChatRow(
        "Ich möchte trainieren", [], MessageType.userButton, () {
      chatHistory.removeLast();
      chatHistory.add(generateChatRow(
          "Feature 'trainieren' wird bald verfügbar sein. Geduld bitte :-)",
          [],
          MessageType.botMessage,
          () {}));
      pushTextInputField();
      setState(() {});
    }));
    // user text field
    pushTextInputField();
  }

  List<InlineSpan> generateParagraph(MbclLevelItem paragraph) {
    List<InlineSpan> res = [];
    for (var item in paragraph.items) {
      res.add(generateParagraphItem(LevelState(), item, color: Colors.white));
    }
    return res;
  }

  pushTextInputField() {
    chatHistory.add(generateChatRow("", [], MessageType.userTextField, () {}));
  }

  Column generateChatRow(
      String text, List<InlineSpan> items, MessageType type, Function action) {
    var fontSize = 18.0;
    var color = Colors.black.withOpacity(0.85);
    if (type == MessageType.userButton) {
      color = getStyle().matheBuddyRed.withOpacity(0.9);
    } else if (type == MessageType.userMessage ||
        type == MessageType.userTextField) {
      color = getStyle().matheBuddyGreen.withOpacity(0.9);
    }
    if (text.contains("DEBUG")) {
      color = color.withOpacity(0.5);
    }
    var textColor = Colors.white;
    List<InlineSpan> textItems = [];
    if (type == MessageType.botMessage) {
      var matheBuddyIcon = WidgetSpan(
          child: SizedBox(
              height: 32,
              width: 45,
              child: Image.asset('assets/img/logo.png')));
      textItems.add(matheBuddyIcon);
    } else if (type == MessageType.userMessage) {
      var userIcon = WidgetSpan(
          child: Icon(
        MdiIcons.fromString("account"),
        size: 32,
        color: Colors.white,
      ));
      textItems.add(userIcon);
    }
    Widget content = Text('');
    if (type == MessageType.botMessage ||
        type == MessageType.userMessage ||
        type == MessageType.userButton) {
      if (text.isNotEmpty) {
        textItems.add(TextSpan(
            text: text,
            style: TextStyle(fontSize: fontSize, color: textColor)));
      }
      textItems.addAll(items);
      content = RichText(
          text: TextSpan(
        children: textItems,
      ));
    } else if (type == MessageType.userTextField) {
      var textFieldController = TextEditingController();
      var textField = TextField(
          controller: textFieldController,
          autocorrect: false,
          onEditingComplete: () {
            var text = textFieldController.text;
            //print(">>> editing complete: $text");
            answer(text);
          },
          style: TextStyle(fontSize: fontSize, color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: color));
      content = Column(children: [
        Icon(
          MdiIcons.fromString("account"),
          size: 32,
          color: Colors.white,
        ),
        textField
      ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.all(5.0),
          child: GestureDetector(
              onTap: () {
                action();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: color, width: 2.5),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: EdgeInsets.all(7.0),
                  child: content,
                ),
              )))
    ]);
  }

  void answer(String text) {
    // substitute user text field by user message
    chatHistory.removeLast();
    chatHistory.add(generateChatRow(text, [], MessageType.userMessage, () {}));
    // search definition
    var definition = widget.course.chat.getDefinition(text.toLowerCase());
    if (definition != null) {
      chatHistory.add(generateChatRow("", generateParagraph(definition.data),
          MessageType.botMessage, () {}));
      // add link to chapter
      var pathParts = definition.levelPath.split("/");
      MbclChapter? chapter;
      MbclLevel? level;
      var levelName = "";
      if (pathParts.length == 2 &&
          pathParts[0].isNotEmpty &&
          pathParts[1].isNotEmpty) {
        var chapterFileId = pathParts[0];
        var levelFileId = pathParts[1];
        chapter = widget.course.getChapterByFileID(chapterFileId);
        if (chapter != null) {
          level = chapter.getLevelByFileID(levelFileId);
          if (level != null) {
            levelName = level.title;
          }
        }
      }
      chatHistory.add(generateChatRow(
          "Gehe zu Level \"$levelName\"", [], MessageType.userButton, () {
        print("open level ${definition.levelPath}");
        if (chapter != null && level != null) {
          var route = MaterialPageRoute(builder: (context) {
            return LevelWidget(widget.course, chapter!, level!);
          });
          Navigator.push(context, route).then((value) => setState(() {}));
          // level.visited = true;
          setState(() {});
        }
      }));
    } else {
      var evalSuccess = true;
      var answer = "";
      try {
        var term = math_parse.Parser().parse(text);
        var res = term.eval({});
        answer = res.toTeXString();
      } catch (err) {
        print(">>> ${err.toString()}");
        if (err.toString().contains("unset var")) {
          answer = "Dein Term enthält unbekannte Variablen.";
        } else {
          evalSuccess = false;
        }
      }
      if (evalSuccess == false) {
        List<String> answers = [
          "Leider kann ich Dir nicht helfen :(",
          "Deine Eingabe verstehe ich nicht.",
          "Sorry, das kann ich monentan noch nicht verstehen. Ich werde demnächst besser!!"
        ];
        answer = answers[Random().nextInt(answers.length)];
      }
      chatHistory
          .add(generateChatRow(answer, [], MessageType.botMessage, () {}));
    }
    // add a new user text field
    pushTextInputField();
    // refresh
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var body = SingleChildScrollView(child: Column(children: chatHistory));
    return Scaffold(
        appBar: buildAppBar(this, null, null),
        body: body,
        backgroundColor: Colors.white);
  }
}
