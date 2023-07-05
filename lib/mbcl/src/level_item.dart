/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

import 'level.dart';

// TODO: label vs id?????

class MbclLevelItem {
  MbclLevel level;
  MbclLevelItemType type;
  int srcLine = -1; // line number in MBL input file
  String title = '';
  String label = '';
  String error = '';
  String text = '';
  String id = '';
  List<MbclLevelItem> items = [];

  // data for certain types only
  MbclEquationData? equationData;
  MbclExerciseData? exerciseData;
  MbclFigureData? figureData;
  MbclTableData? tableData;
  MbclInputFieldData? inputFieldData;

  // temporary data

  MbclLevelItem(this.level, this.type, this.srcLine, [this.text = '']);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      "type": type.name,
    };
    if (srcLine != -1) json["srcLine"] = srcLine;
    if (title.isNotEmpty) json["title"] = title;
    if (label.isNotEmpty) json["label"] = label;
    if (error.isNotEmpty) json["error"] = error;
    if (text.isNotEmpty) json["text"] = text;
    if (id.isNotEmpty) json["id"] = id;
    if (items.isNotEmpty) {
      json["items"] = items.map((item) => item.toJSON()).toList();
    }
    switch (type) {
      case MbclLevelItemType.equation:
        json["equationData"] = equationData?.toJSON();
        break;
      case MbclLevelItemType.exercise:
        json["exerciseData"] = exerciseData?.toJSON();
        break;
      case MbclLevelItemType.figure:
        json["figureData"] = figureData?.toJSON();
        break;
      case MbclLevelItemType.table:
        json["tableData"] = tableData?.toJSON();
        break;
      case MbclLevelItemType.inputField:
        json["inputFieldData"] = inputFieldData?.toJSON();
        break;
      default:
        break;
    }
    return json;
  }

  fromJSON(Map<String, dynamic> src) {
    type = MbclLevelItemType.values.byName(src["type"]);
    srcLine = src.containsKey("srcLine") ? src["srcLine"] : -1;
    title = src.containsKey("title") ? src["title"] : "";
    label = src.containsKey("label") ? src["label"] : "";
    error = src.containsKey("error") ? src["error"] : "";
    text = src.containsKey("text") ? src["text"] : "";
    id = src.containsKey("id") ? src["id"] : "";
    items = [];
    if (src.containsKey("items")) {
      int n = src["items"].length;
      for (var i = 0; i < n; i++) {
        var item = MbclLevelItem(level, MbclLevelItemType.error, srcLine);
        item.fromJSON(src["items"][i]);
        items.add(item);
      }
    }
    switch (type) {
      case MbclLevelItemType.equation:
        equationData = MbclEquationData(this);
        equationData?.fromJSON(src["equationData"]);
        break;
      case MbclLevelItemType.exercise:
        exerciseData = MbclExerciseData(this);
        exerciseData?.fromJSON(src["exerciseData"]);
        break;
      case MbclLevelItemType.figure:
        figureData = MbclFigureData(this);
        figureData?.fromJSON(src["figureData"]);
        break;
      case MbclLevelItemType.table:
        tableData = MbclTableData(this);
        tableData?.fromJSON(src["tableData"]);
        break;
      case MbclLevelItemType.inputField:
        inputFieldData = MbclInputFieldData();
        inputFieldData?.fromJSON(src["inputFieldData"]);
        break;
      default:
        break;
    }
  }
}

enum MbclLevelItemType {
  alignCenter,
  alignLeft,
  alignRight,
  boldText,
  color,
  defAxiom,
  defClaim,
  defConjecture,
  defCorollary,
  defDefinition,
  defIdentity,
  defLemma,
  defParadox,
  defProposition,
  defTheorem,
  displayMath,
  enumerate,
  enumerateAlpha,
  equation,
  error,
  example,
  exercise,
  figure,
  inlineMath,
  inputField,
  italicText,
  itemize,
  lineFeed,
  multipleChoice,
  //multipleChoiceOption,
  //newPage,
  paragraph,
  part,
  reference,
  section,
  singleChoice,
  //singleChoiceOption,
  span,
  subSection,
  subSubSection,
  table,
  text,
  todo,
  variableReference
}

// TODO: fill this list
Map<MbclLevelItemType, List<MbclLevelItemType>> mbclSubBlockWhiteList = {
  MbclLevelItemType.exercise: [
    //
    MbclLevelItemType.equation,
    MbclLevelItemType.figure,
    MbclLevelItemType.error,
    MbclLevelItemType.paragraph,
  ],
  MbclLevelItemType.example: [
    //
    MbclLevelItemType.paragraph,
    MbclLevelItemType.equation,
    MbclLevelItemType.figure,
  ],
  MbclLevelItemType.defDefinition: [
    // also applied for MbclLevelItemType.def*
    MbclLevelItemType.alignLeft,
    MbclLevelItemType.alignCenter,
    MbclLevelItemType.alignRight,
    MbclLevelItemType.equation,
    MbclLevelItemType.paragraph,
    MbclLevelItemType.figure,
    MbclLevelItemType.table,
  ],
};

class MbclEquationData {
  MbclLevelItem equation;
  //List<MbclEquationOption> options = [];
  MbclLevelItem? math;
  int number = 0;

  MbclEquationData(this.equation);

  Map<String, dynamic> toJSON() {
    return {
      //"options": options.map((o) => o.name).toList(),
      "math": math?.toJSON(),
      "number": number
    };
  }

  fromJSON(Map<String, dynamic> src) {
    /*options = [];
    int n = src["options"].length;
    for (var i = 0; i < n; i++) {
      var option = MbclEquationOption.values.byName(src["options"][i]);
      options.add(option);
    }*/
    math = MbclLevelItem(equation.level, MbclLevelItemType.error, -1);
    math?.fromJSON(src["math"]);
    number = src["number"];
  }
}

/*enum MbclEquationOption {
  aligned,
}*/

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
  List<Map<String, String>> instances = []; // TODO: DESCRIBE!!
  bool staticOrder = false;
  bool disableRetry = false;
  int scores = 1;
  bool showGapLength = false;
  bool showRequiredGapLettersOnly = false;
  bool horizontalSingleMultipleChoiceAlignment = false;
  String forceKeyboardId = "";
  List<MbclLevelItem> requiredExercises = [];

  // temporary
  MbclLevelItem exercise;
  int staticVariableCounter = 0;
  Map<String, String> smplOperandType = {};
  Map<String, MbclInputFieldData> inputFields = {};
  MbclExerciseFeedback feedback = MbclExerciseFeedback.unchecked;
  List<int> indexOrdering =
      []; // e.g. used for random displayed order of multiple-choice
  double maxReachedScore = 0;

  // runtime variables
  int runInstanceIdx = -1; // selected exercise instance; -1 := not chosen

  MbclExerciseData(this.exercise);

  void reset() {
    runInstanceIdx = -1;
    feedback = MbclExerciseFeedback.unchecked;
    for (var inputFieldId in inputFields.keys) {
      var inputField = inputFields[inputFieldId];
      inputField!.reset();
    }
    inputFields = {};
    indexOrdering = [];
  }

  Map<String, dynamic> toJSON() {
    // TODO: do NOT output "code" in final build
    return {
      "code": code,
      "variables": variables.map((e) => e).toList(),
      "instances": instances.map((e) => e).toList(),
      "staticOrder": staticOrder,
      "disableRetry": disableRetry,
      "scores": scores,
      "showGapLength": showGapLength,
      "showRequiredGapLettersOnly": showRequiredGapLettersOnly,
      "horizontalSingleMultipleChoiceAlignment":
          horizontalSingleMultipleChoiceAlignment,
      "forceKeyboardId": forceKeyboardId,
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
    showGapLength = src["showGapLength"] as bool;
    showRequiredGapLettersOnly = src["showRequiredGapLettersOnly"] as bool;
    horizontalSingleMultipleChoiceAlignment =
        src["horizontalSingleMultipleChoiceAlignment"] as bool;
    forceKeyboardId = src["forceKeyboardId"] as String;
    requiredExercises = [];
    n = src["requiredExercises"].length;
    for (var i = 0; i < n; i++) {
      var reqLabel = src["requiredExercises"][i] as String;
      requiredExercises.add(exercise.level.getExerciseByLabel(reqLabel)!);
    }
  }
}

class MbclFigureData {
  MbclLevelItem figure;
  String filePath = '';
  String code = '';
  String data = '';
  List<MbclLevelItem> caption = [];
  List<MbclFigureOption> options = [];

  MbclFigureData(this.figure);

  Map<String, dynamic> toJSON() {
    return {
      "filePath": filePath,
      "code": code,
      "data": data,
      "caption": caption.map((e) => e.toJSON()).toList(),
      "options": options.map((e) => e.name).toList(),
    };
  }

  fromJSON(Map<String, dynamic> src) {
    filePath = src["filePath"];
    code = src["code"];
    data = src["data"];
    int n = src["caption"].length;
    for (var i = 0; i < n; i++) {
      var cap = MbclLevelItem(figure.level, MbclLevelItemType.error, -1);
      cap.fromJSON(src["caption"][i]);
      caption.add(cap);
    }
    n = src["options"].length;
    for (var i = 0; i < n; i++) {
      options.add(MbclFigureOption.values.byName(src["options"][i]));
    }
  }
}

enum MbclFigureOption {
  width25,
  width33,
  width50,
  width66,
  width75,
  width100,
}

class MbclTableData {
  MbclLevelItem table;
  MbclTableRow head;
  List<MbclTableRow> rows = [];
  List<MbclTableOption> options = [];

  MbclTableData(this.table) : head = MbclTableRow(table);

  Map<String, dynamic> toJSON() {
    return {
      "head": head.toJSON(),
      "rows": rows.map((e) => e.toJSON()).toList(),
      "options": options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    head = MbclTableRow(table);
    head.fromJSON(src["head"]);
    rows = [];
    int n = src["rows"].length;
    for (var i = 0; i < n; i++) {
      var row = MbclTableRow(table);
      row.fromJSON(src["rows"][i]);
      rows.add(row);
    }
    options = [];
    n = src["options"].length;
    for (var i = 0; i < n; i++) {
      options.add(MbclTableOption.values.byName(src["options"][i]));
    }
  }
}

class MbclInputFieldData {
  // import/export
  MbclInputFieldType type = MbclInputFieldType.none;
  String variableId = '';
  int score = 1;
  int choices =
      0; // a nonzero value provides a "keyboard" with solutions (similar to multiple choice)

  // temporary
  MbclExerciseData? exerciseData;
  int cursorPos = 0;
  String studentValue = '';
  String expectedValue = '';

  void reset() {
    cursorPos = 0;
    studentValue = "";
  }

  Map<String, dynamic> toJSON() {
    return {
      "type": type.name,
      "variableId": variableId,
      "score": score,
      "choices": choices,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    type = MbclInputFieldType.values.byName(src["type"]);
    variableId = src["variableId"] as String;
    score = src["score"] as int;
    choices = src["choices"] as int;
  }
}

enum MbclInputFieldType {
  none,
  bool,
  int,
  rational,
  real,
  complexNormal,
  complexPolar,
  complexIntSet,
  intSet,
  intSetNArts,
  vector,
  vectorFlex,
  matrix,
  matrixFlexRows,
  matrixFlexCols,
  matrixFlex,
  term,
  choices,
}

/*class MbclSingleOrMultipleChoiceOptionData {
  String inputId = '';
  String variableId = '';

  Map<String, dynamic> toJSON() {
    return {
      "inputId": inputId,
      "variableId": variableId,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    inputId = src["inputId"];
    variableId = src["variableId"];
  }
}*/

class MbclTableRow {
  MbclLevelItem table;
  List<MbclLevelItem> columns = [];

  MbclTableRow(this.table);

  Map<String, dynamic> toJSON() {
    return {"columns": columns.map((e) => e.toJSON()).toList()};
  }

  fromJSON(Map<String, dynamic> src) {
    columns = [];
    int n = src["columns"].length;
    for (var i = 0; i < n; i++) {
      var column = MbclLevelItem(table.level, MbclLevelItemType.error, -1);
      column.fromJSON(src["columns"][i]);
      columns.add(column);
    }
  }
}

enum MbclTableOption {
  alignLeft,
  alignCenter,
  alignRight,
}
