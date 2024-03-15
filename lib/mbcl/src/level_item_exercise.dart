/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'package:collection/collection.dart';

import 'level.dart';
import 'level_item.dart';
import 'level_item_input_field.dart';

//import 'package:mathebuddy/math-runtime/src/parse.dart' as term_parser;
import '../../math-runtime/src/parse.dart' as term_parser;

enum MbclExerciseFeedback {
  //
  unchecked,
  correct,
  incorrect
}

class MbclExerciseData {
  // import/export
  String code = '';
  List<String> variables = [];
  List<String> functionVariables = []; // e.g. "f" for a function "let f(x)=x^2"
  List<Map<String, String>> instances = []; // TODO: DESCRIBE!!
  bool staticOrder = false;
  bool disableRetry = false;
  int scores = 1;
  int numInstances = 5;
  int time = -1; // time in seconds; negative := exercise has no time limit
  //TODO: remove: bool showGapLength = false;
  //TODO: remove: bool showRequiredGapLettersOnly = false;
  bool alignChoicesHorizontally = false;
  //TODO: remove: bool arrangement = false;
  //TODO: remove: String forceKeyboardId = "";
  List<MbclLevelItem> requiredExercises = [];

  // temporary
  bool generateInputFields = true;
  MbclLevelItem exercise;
  int staticVariableCounter = 0;
  Map<String, String> smplOperandType = {}; // base type
  Map<String, String> smplOperandSubType = {}; // e.g. type of vector elements
  //Map<String, MbclInputFieldData> inputFields = {};
  List<MbclLevelItem> inputFields = [];
  MbclExerciseFeedback feedback = MbclExerciseFeedback.unchecked;

  double maxReachedScore = 0;

  // runtime variables
  int runInstanceIdx = -1; // selected exercise instance; -1 := not chosen
  int randomInstanceOrderIdx =
      0; // current index to index to randomInstanceOrder
  List<int> randomInstanceOrder = [];
  Map<String, String> activeInstance = {};

  MbclExerciseData(this.exercise);

  void prepare() {
    inputFields = exercise.getItemsByType(MbclLevelItemType.inputField);
    for (var f in inputFields) {
      f.exerciseData = this;
    }
    nextInstance();
  }

  void reset() {
    runInstanceIdx = -1;
    maxReachedScore = 0;
    feedback = MbclExerciseFeedback.unchecked;
    for (var f in inputFields) {
      f.inputFieldData!.reset();
    }
    nextInstance();
  }

  List<String> getChoicesOfFirstInputField() {
    if (inputFields.isEmpty) return [];
    var firstInputField = inputFields[0];
    if (firstInputField.inputFieldData!.choices == false) return [];
    var varId = "CHOICES.${firstInputField.id}";
    if (activeInstance.containsKey(varId) == false) return [];
    List<String> choices = activeInstance[varId]!.split("#");
    choices = choices.map((x) => x.trim()).toList();
    return choices;
  }

  List<MbclLevelItem> getSingleChoiceAnswers() {
    List<MbclLevelItem> result = [];
    for (var item in exercise.items) {
      if (item.type == MbclLevelItemType.singleChoice) {
        result = item.items;
      }
    }
    return result;
  }

  void nextInstance() {
    if (exercise.error.isNotEmpty) {
      print("WARNING: exercise contains errors");
      return;
    }
    if (instances.isEmpty) {
      print("WARNING: exercise has no instances");
      return;
    }
    if (runInstanceIdx < 0) {
      // create order, if not yet done
      if (randomInstanceOrder.isEmpty) {
        randomInstanceOrder = [for (var i = 0; i < numInstances; i++) i];
        randomInstanceOrder.shuffle();
      }
      // proceed to next instance
      runInstanceIdx = randomInstanceOrder[randomInstanceOrderIdx];
      randomInstanceOrderIdx = (randomInstanceOrderIdx + 1) % numInstances;
    }
    activeInstance = instances[runInstanceIdx];
    for (var inputField in inputFields) {
      var ifd = inputField.inputFieldData!;
      ifd.studentValue = "";
      if (ifd.isFunction) {
        ifd.expectedValue = activeInstance["@${ifd.variableId}"] as String;
      } else {
        ifd.expectedValue = activeInstance[ifd.variableId] as String;
      }
      if (ifd.index >= 0) {
        var t = term_parser.Parser().parse(ifd.expectedValue);
        if (ifd.index >= t.o.length) {
          print("ERROR: indexing exceeds bound!");
        } else {
          t = t.o[ifd.index];
        }
        ifd.expectedValue = t.toString();
      }
    }
  }

  void evaluate() {
    //if (feedback == MbclExerciseFeedback.correct) return;
    // check exercise: TODO must implement in e.g. new file exercise.dart
    var allCorrect = true;
    for (var inputFieldItem in inputFields) {
      var data = inputFieldItem.inputFieldData!;
      data.correct = false;

      if (data.type == MbclInputFieldType.string) {
        // --- gap exercise ---
        var student = data.studentValue.trim().toUpperCase();
        var expected = data.expectedValue.trim().toUpperCase();
        print("comparing STRINGS $student to $expected");
        data.correct = student == expected;
      } else {
        // term / number exercise
        try {
          var studentTerm = term_parser.Parser().parse(data.studentValue);
          if (data.diffVariableId.isNotEmpty) {
            var studentTermDiff =
                studentTerm.diff(data.diffVariableId).optimize();
            print("diff student answer: $studentTerm -> $studentTermDiff");
            studentTerm = studentTermDiff;
          }
          var expected = data.expectedValue;
          var expectedTerm = term_parser.Parser().parse(expected);
          print("comparing $studentTerm to $expectedTerm");
          data.correct = expectedTerm.compareNumerically(studentTerm);
        } catch (e) {
          // TODO: give GUI feedback, that term is not well formed, ...
          print("evaluating answer failed: $e");
          data.correct = false;
        }
      }
      if (data.correct) {
        print("answer OK");
      } else {
        allCorrect = false;
        print("answer wrong: expected ${data.expectedValue},"
            " got ${data.studentValue}");
      }
    }
    if (allCorrect) {
      print("... all answers are correct!");
      feedback = MbclExerciseFeedback.correct;
    } else {
      print("... at least one answer is incorrect!");
      feedback = MbclExerciseFeedback.incorrect;
    }
    print("----- end of exercise evaluation -----");
  }

  String getVariableValuesAsString() {
    var instance = instances[runInstanceIdx];
    var text = "";
    for (var key in instance.keys) {
      if (key.startsWith("__") || key.endsWith(".tex") || key.startsWith("@")) {
        continue;
      }
      if (text.isNotEmpty) text += "\n";
      var value = instance[key];
      text += "$key=$value";

      var term = "";
      var opt = "";
      if (instance.containsKey("@$key")) {
        term = instance["@$key"]!;
      }
      if (instance.containsKey("@@$key")) {
        opt = instance["@@$key"]!;
      }
      if (term.contains("rand") == false) {
        text += ", term($key)=$term";
        text += ", opt($key)=$opt";
      }
    }
    return text;
  }

  Map<String, dynamic> progressToJSON() {
    var studentValues = [];
    for (var inputField in inputFields) {
      studentValues.add(inputField.inputFieldData!.studentValue);
    }
    return {
      "feedback": feedback.name,
      "maxReachedScore": maxReachedScore,
      "instance": activeInstance,
      "studentValues": studentValues
    };
  }

  progressFromJSON(Map<String, dynamic> src) {
    // check, if exercise is still "similar" to current exercise revision
    // if not, then nothing is loaded
    if (instances.isEmpty ||
        src.containsKey("instance") == false ||
        src.containsKey("studentValues") == false) return;
    if (src["studentValues"].length != inputFields.length) {
      print("Warning: exercise ${exercise.label} could not be imported,"
          " since the number of input fields changed.");
    }
    var keysNew = instances[0].keys.toList();
    keysNew.sort();
    var keysOld = src["instance"].keys.toList();
    keysOld.sort();
    if (IterableEquality().equals(keysNew, keysOld) == false) {
      print("Warning: exercise ${exercise.label} could not be imported,"
          " since its variable set changed.");
      return;
    }
    // import
    if (src.containsKey("feedback")) {
      try {
        feedback = MbclExerciseFeedback.values.byName(src["feedback"]);
      } catch (e) {
        return;
      }
    }
    if (src.containsKey("maxReachedScore")) {
      maxReachedScore = src["maxReachedScore"];
    }
    activeInstance = {};
    for (var key in src["instance"].keys) {
      String value = src["instance"][key];
      activeInstance[key] = value;
    }
    for (var i = 0; i < inputFields.length; i++) {
      var inputField = inputFields[i].inputFieldData!;
      inputField.studentValue = src["studentValues"][i];
      inputField.cursorPos = inputField.studentValue.length;
    }
  }

  Map<String, dynamic> toJSON() {
    // TODO: do NOT output "code" in final build
    return {
      "code": code,
      "variables": variables.map((e) => e).toList(),
      "functionVariables": functionVariables.map((e) => e).toList(),
      "instances": instances.map((e) => e).toList(),
      "staticOrder": staticOrder,
      "disableRetry": disableRetry,
      "scores": scores,
      "numInstances": numInstances,
      "time": time,
      //"showGapLength": showGapLength,
      //"showRequiredGapLettersOnly": showRequiredGapLettersOnly,
      "alignChoicesHorizontally": alignChoicesHorizontally,
      //"arrangement": arrangement,
      //"forceKeyboardId": forceKeyboardId,
      "requiredExercises": requiredExercises.map((e) => e.label).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    code = src["code"];
    variables = [];
    int n = src["variables"].length;
    for (var i = 0; i < n; i++) {
      variables.add(src["variables"][i]);
    }
    functionVariables = [];
    n = src["functionVariables"].length;
    for (var i = 0; i < n; i++) {
      functionVariables.add(src["functionVariables"][i]);
    }
    instances = [];
    n = src["instances"].length;
    for (var i = 0; i < n; i++) {
      Map<String, dynamic> instanceSrc = src["instances"][i];
      Map<String, String> instance = {};
      for (var key in instanceSrc.keys) {
        String value = instanceSrc[key];
        instance[key] = value;
      }
      instances.add(instance);
    }
    staticOrder = src["staticOrder"] as bool;
    disableRetry = src["disableRetry"] as bool;
    scores = src["scores"] as int;
    numInstances = src["numInstances"] as int;
    time = src["time"] as int;
    //showGapLength = src["showGapLength"] as bool;
    //showRequiredGapLettersOnly = src["showRequiredGapLettersOnly"] as bool;
    alignChoicesHorizontally = src["alignChoicesHorizontally"] as bool;
    //arrangement = src["arrangement"] as bool;
    //forceKeyboardId = src["forceKeyboardId"] as String;
    requiredExercises = [];
    n = src["requiredExercises"].length;
    for (var i = 0; i < n; i++) {
      var reqLabel = src["requiredExercises"][i] as String;
      requiredExercises.add(exercise.level.getExerciseByLabel(reqLabel)!);
    }
    prepare();
  }
}
