/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/chat_db.dart';
import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/widget_level.dart';
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

enum ChatMessageType {
  botMessage,
  userMessage,
  userButton,
  userInputField,
  exercise,
}

class ChatMessage {
  bool debugMessage = false;
  ChatMessageType type;
  String text;
  Color textColor = Colors.black;
  MbclLevelItem? referredItem;
  Function? action;

  ChatMessage(this.type, this.text);
}

class ChatState extends State<ChatWidget> {
  List<ChatMessage> chatHistory = [];
  late ChatMessage likeToExercise;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    chatHistory = [];

    // greetings text
    var greetings = ChatMessage(
        ChatMessageType.botMessage, getChatText("greetings", language, []));
    chatHistory.add(greetings);

    // debug reset button
    var resetBtn =
        ChatMessage(ChatMessageType.userButton, "reset chat history");
    resetBtn.debugMessage = true;
    resetBtn.action = () {
      reset();
      setState(() {});
    };
    chatHistory.add(resetBtn);

    // debug list definitions
    var genDefBtn =
        ChatMessage(ChatMessageType.userButton, "list all definitions");
    genDefBtn.debugMessage = true;
    genDefBtn.action = () {
      var definitions = widget.course.chat.definitions;
      for (var key in definitions.keys) {
        var definition = definitions[key]!;
        var def = ChatMessage(
            ChatMessageType.botMessage, "[$key;${definition.levelPath}] ");
        def.textColor = Style().matheBuddyRed;
        def.debugMessage = true;
        def.referredItem = definition.data;
        chatHistory.add(def);
      }
      setState(() {});
    };
    chatHistory.add(genDefBtn);

    // initial user button(s)
    likeToExercise = ChatMessage(
        ChatMessageType.userButton, getChatText("likeExercise", language, []));
    likeToExercise.action = () {
      chatHistory.removeLast(); // remove user input field
      chatHistory.removeLast(); // remove "i like to exercise" button
      var exercise = widget.course.getSuggestedExercise();
      if (exercise == null) {
        chatHistory.add(ChatMessage(ChatMessageType.botMessage,
            getChatText("noExercises", language, [])));
      } else {
        var chapterId = exercise.level.chapter.title;
        chatHistory.add(ChatMessage(ChatMessageType.botMessage,
            getChatText("hereExercise", language, [chapterId])));
        var ex = ChatMessage(ChatMessageType.exercise, "");
        ex.referredItem = exercise;
        chatHistory.add(ex);
      }
      //TODO: chatHistory.add(likeToExercise);
      //TODO: pushTextInputField();
      setState(() {});
    };
    chatHistory.add(likeToExercise);

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
    chatHistory.add(ChatMessage(ChatMessageType.userInputField, ""));
  }

  Column generateChatMessage(ChatMessage msg) {
    if (msg.type == ChatMessageType.exercise) {
      var exercise = msg.referredItem!;
      var exerciseWidget = generateExercise(this, exercise.level, exercise,
          borderRadius: 20, borderWidth: 2.5);
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.only(left: 6, right: 6), child: exerciseWidget)
      ]);
    }
    var fontSize = 18.0;
    //var color = Colors.black.withOpacity(0.85); // bot message
    var color = Colors.white;
    var textColor = msg.textColor;
    var borderColor = Colors.black;
    if (msg.type == ChatMessageType.userButton) {
      color = getStyle().matheBuddyRed.withOpacity(0.9);
      textColor = Colors.white;
    } else if (msg.type == ChatMessageType.userMessage ||
        msg.type == ChatMessageType.userInputField) {
      color = getStyle().matheBuddyGreen.withOpacity(0.9);
    }
    if (msg.debugMessage) {
      color = color.withOpacity(0.8);
    }
    List<InlineSpan> textItems = [];
    if (msg.type == ChatMessageType.botMessage) {
      var matheBuddyIcon = WidgetSpan(
          child: SizedBox(
              height: 32,
              width: 45,
              child: Image.asset('assets/img/logo.png')));
      textItems.add(matheBuddyIcon);
    } else if (msg.type == ChatMessageType.userMessage) {
      var userIcon = WidgetSpan(
          child: Icon(
        MdiIcons.fromString("account"),
        size: 32,
        color: Colors.white,
      ));
      textItems.add(userIcon);
    }
    Widget content = Text('');
    if (msg.type == ChatMessageType.botMessage ||
        msg.type == ChatMessageType.userMessage ||
        msg.type == ChatMessageType.userButton) {
      if (msg.text.isNotEmpty) {
        textItems.add(TextSpan(
            text: msg.text,
            style: TextStyle(fontSize: fontSize, color: textColor)));
      }
      if (msg.referredItem != null) {
        var item = msg.referredItem!;
        if (item.type == MbclLevelItemType.paragraph) {
          textItems.addAll(generateParagraph(item));
        }
      }
      content = RichText(
          text: TextSpan(
        children: textItems,
      ));
    } else if (msg.type == ChatMessageType.userInputField) {
      var textFieldController = TextEditingController();
      var textField = TextField(
          controller: textFieldController,
          autocorrect: false,
          onEditingComplete: () {
            var text = textFieldController.text;
            //print(">>> editing complete: $text");
            //TODO: answer(text);
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
                if (msg.action != null) {
                  msg.action!();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: borderColor, width: 2.5),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: EdgeInsets.all(7.0),
                  child: content,
                ),
              )))
    ]);
  }

  // !!!!! TODO

  // void answer(String text) {
  //   // substitute user text field by user message
  //   chatHistory.removeLast();
  //   chatHistory
  //       .add(generateChatRow(text, [], ChatMessageType.userMessage, () {}));
  //   // search definition
  //   var definition = widget.course.chat.getDefinition(text.toLowerCase());
  //   if (definition != null) {
  //     chatHistory.add(generateChatRow("", generateParagraph(definition.data),
  //         ChatMessageType.botMessage, () {}));
  //     // add link to chapter
  //     var pathParts = definition.levelPath.split("/");
  //     MbclChapter? chapter;
  //     MbclLevel? level;
  //     var levelName = "";
  //     if (pathParts.length == 2 &&
  //         pathParts[0].isNotEmpty &&
  //         pathParts[1].isNotEmpty) {
  //       var chapterFileId = pathParts[0];
  //       var levelFileId = pathParts[1];
  //       chapter = widget.course.getChapterByFileID(chapterFileId);
  //       if (chapter != null) {
  //         level = chapter.getLevelByFileID(levelFileId);
  //         if (level != null) {
  //           levelName = level.title;
  //         }
  //       }
  //     }
  //     chatHistory.add(generateChatRow(
  //         "Gehe zu Level \"$levelName\"", [], ChatMessageType.userButton, () {
  //       print("open level ${definition.levelPath}");
  //       if (chapter != null && level != null) {
  //         var route = MaterialPageRoute(builder: (context) {
  //           return LevelWidget(widget.course, chapter!, null, level!);
  //         });
  //         Navigator.push(context, route).then((value) => setState(() {}));
  //         // level.visited = true;
  //         setState(() {});
  //       }
  //     }));
  //   } else {
  //     var evalSuccess = true;
  //     var answer = "";
  //     try {
  //       var term = math_parse.Parser().parse(text);
  //       var res = term.eval({});
  //       answer = res.toTeXString();
  //     } catch (err) {
  //       print(">>> ${err.toString()}");
  //       if (err.toString().contains("unset var")) {
  //         answer = "Dein Term enthält unbekannte Variablen.";
  //       } else {
  //         evalSuccess = false;
  //       }
  //     }
  //     if (evalSuccess == false) {
  //       List<String> answers = [
  //         "Leider kann ich Dir nicht helfen :(",
  //         "Deine Eingabe verstehe ich nicht.",
  //         "Sorry, das kann ich monentan noch nicht verstehen. Ich werde demnächst besser!!"
  //       ];
  //       answer = answers[Random().nextInt(answers.length)];
  //     }
  //     chatHistory
  //         .add(generateChatRow(answer, [], ChatMessageType.botMessage, () {}));
  //   }
  //   // add a new user text field
  //   pushTextInputField();
  //   // refresh
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatWidgets = [];
    for (var msg in chatHistory) {
      if (!debugMode && msg.debugMessage) {
        continue;
      }
      chatWidgets.add(generateChatMessage(msg));
    }
    var body = SingleChildScrollView(child: Column(children: chatWidgets));
    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      var keyboard = Keyboard(this, keyboardState, false);
      bottomArea = keyboard.generateWidget();
    }
    return Scaffold(
      appBar: buildAppBar(this, null, null),
      body: body,
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}