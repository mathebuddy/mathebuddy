/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/db_chat.dart';
import 'package:mathebuddy/keyboard.dart';
import 'package:mathebuddy/level_exercise.dart';
import 'package:mathebuddy/widget_level.dart';
import 'package:mathebuddy/level_paragraph.dart';
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

  List<MbclLevelItem> sessionExercises = [];

  @override
  void initState() {
    super.initState();
    reset();
  }

  void likeToExerciseAction() {
    chatHistory.removeLast(); // remove user input field
    chatHistory.removeLast(); // remove "i like to exercise" button
    var exercise = widget.course.suggestExercise(sessionExercises);
    if (exercise == null) {
      chatHistory.add(ChatMessage(ChatMessageType.botMessage,
          getChatText("noExercises", language, [])));
    } else {
      sessionExercises.add(exercise);

      exercise.exerciseData!.reset();
      var chapterId = exercise.level.chapter.title;
      chatHistory.add(ChatMessage(ChatMessageType.botMessage,
          getChatText("hereExercise", language, [chapterId])));
      var ex = ChatMessage(ChatMessageType.exercise, "");
      ex.referredItem = exercise;
      chatHistory.add(ex);

      // button for next exercise
      var anotherExercise = ChatMessage(ChatMessageType.userButton,
          getChatText("likeAnotherExercise", language, []));
      anotherExercise.action = () {
        chatHistory.removeLast(); // remove "hereExercise"
        chatHistory.removeLast(); // remove old exercise
        likeToExerciseAction();
      };
      chatHistory.add(anotherExercise);
    }

    pushTextInputField();
    setState(() {});
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
      likeToExerciseAction();
    };
    chatHistory.add(likeToExercise);

    // user text field
    pushTextInputField();
  }

  List<InlineSpan> generateParagraph(MbclLevelItem paragraph) {
    List<InlineSpan> res = [];
    for (var item in paragraph.items) {
      res.add(generateParagraphItem(this, item, color: Colors.black));
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
      textColor = Colors.white;
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
          onChanged: (value) {
            //var similarKeywords = widget.course.chat.getSimilarKeywords(value);
            /*if (similarKeywords.isNotEmpty) {
              textFieldController.value =
                  TextEditingValue(text: similarKeywords[0]);
            }*/
          },
          onEditingComplete: () {
            var text = textFieldController.text;
            //print(">>> editing complete: $text");
            answer(text);
            setState(() {});
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

  void answer(String text) {
    // TODO: languages DE vs EN!!!!

    // substitute user text field by user message
    chatHistory.removeLast();
    chatHistory.add(ChatMessage(ChatMessageType.userMessage, text));
    // search definition
    List<String> similarDefinitionKeywords =
        widget.course.chat.getSimilarKeywords(text.trim().toLowerCase());
    if (similarDefinitionKeywords.length > 1) {
      chatHistory.add(ChatMessage(ChatMessageType.botMessage,
          getChatText("similarKeywords", language, [])));
      for (var kw in similarDefinitionKeywords) {
        var msg = ChatMessage(ChatMessageType.userButton, kw.toUpperCase());
        msg.action = () {
          answer(kw);
          setState(() {});
        };
        chatHistory.add(msg);
      }
    } else if (similarDefinitionKeywords.length == 1) {
      var definition = widget.course.chat.getDefinition(text.toLowerCase());
      if (definition != null) {
        var def = ChatMessage(ChatMessageType.botMessage, "");
        def.referredItem = definition.data;
        chatHistory.add(def);
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
        levelName = levelName.split("///")[0].trim(); // TODO: switch language
        var gotoLevelBtn = ChatMessage(
            ChatMessageType.userButton, "Gehe zu Level \"$levelName\"");
        gotoLevelBtn.action = () {
          print("open level ${definition.levelPath}");
          if (chapter != null && level != null) {
            var route = MaterialPageRoute(builder: (context) {
              return LevelWidget(widget.course, chapter!, null, level!);
            });
            Navigator.push(context, route).then((value) => setState(() {}));
            // level.visited = true;
            setState(() {});
          }
        };
        chatHistory.add(gotoLevelBtn);
      }
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
        // TODO: English
        List<String> answers = [
          "Leider kann ich Dir nicht helfen :(",
          "Deine Eingabe verstehe ich nicht.",
          "Sorry, das kann ich momentan noch nicht verstehen. Ich werde demnächst besser!!"
        ];
        answer = answers[Random().nextInt(answers.length)];
      }
      chatHistory.add(ChatMessage(ChatMessageType.botMessage, answer));

      // List<String> answers = [
      //   "Ich agiere nur als Index.",
      //   "Gib bitte einen Suchbegriff ein.",
      //   "Versuche es bitte mit einem anderen Suchbegriff.",
      // ];
      // var answer = answers[Random().nextInt(answers.length)];
      // chatHistory.add(ChatMessage(ChatMessageType.botMessage, answer));
    }
    // add a new user text field
    pushTextInputField();
  }

  @override
  Widget build(BuildContext context) {
    levelBuildContext = context; // TODO: used for overlay

    List<Widget> chatWidgets = [];
    for (var msg in chatHistory) {
      if (!debugMode && msg.debugMessage) {
        continue;
      }
      chatWidgets.add(generateChatMessage(msg));
    }
    for (var i = 0; i < 5; i++) {
      chatWidgets.add(Text(" "));
    }
    var body = SingleChildScrollView(child: Column(children: chatWidgets));
    Widget bottomArea = Text('');
    if (keyboardState.layout != null) {
      var keyboard = Keyboard(this, keyboardState);
      bottomArea = keyboard.generateWidget();
    }
    return Scaffold(
      appBar: buildAppBar(true, [], false, this, context, widget.course),
      body: body,
      backgroundColor: Colors.white,
      bottomSheet: bottomArea,
    );
  }
}
