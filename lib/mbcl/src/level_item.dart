/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

class MbclLevelItem {
  MbclLevelItemType type;
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
  //MbclSingleOrMultipleChoiceOptionData? singleOrMultipleChoiceOptionData;

  MbclLevelItem(this.type, [this.text = '']);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      "type": type.name,
    };
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
      /*case MbclLevelItemType.singleChoiceOption:
      case MbclLevelItemType.multipleChoiceOption:
        json["singleOrMultipleChoiceOptionData"] =
            singleOrMultipleChoiceOptionData?.toJSON();
        break;*/
      default:
        break;
    }
    return json;
  }

  fromJSON(Map<String, dynamic> src) {
    type = MbclLevelItemType.values.byName(src["type"]);
    title = src.containsKey("title") ? src["title"] : "";
    label = src.containsKey("label") ? src["label"] : "";
    error = src.containsKey("error") ? src["error"] : "";
    text = src.containsKey("text") ? src["text"] : "";
    id = src.containsKey("id") ? src["id"] : "";
    items = [];
    if (src.containsKey("items")) {
      int n = src["items"].length;
      for (var i = 0; i < n; i++) {
        var item = MbclLevelItem(MbclLevelItemType.error);
        item.fromJSON(src["items"][i]);
        items.add(item);
      }
    }
    switch (type) {
      case MbclLevelItemType.equation:
        equationData = MbclEquationData();
        equationData?.fromJSON(src["equationData"]);
        break;
      case MbclLevelItemType.exercise:
        exerciseData = MbclExerciseData();
        exerciseData?.fromJSON(src["exerciseData"]);
        break;
      case MbclLevelItemType.figure:
        figureData = MbclFigureData();
        figureData?.fromJSON(src["figureData"]);
        break;
      case MbclLevelItemType.table:
        tableData = MbclTableData();
        tableData?.fromJSON(src["tableData"]);
        break;
      case MbclLevelItemType.inputField:
        inputFieldData = MbclInputFieldData();
        inputFieldData?.fromJSON(src["inputFieldData"]);
        break;
      /*case MbclLevelItemType.singleChoiceOption:
      case MbclLevelItemType.multipleChoiceOption:
        singleOrMultipleChoiceOptionData =
            MbclSingleOrMultipleChoiceOptionData();
        singleOrMultipleChoiceOptionData
            ?.fromJSON(src["singleOrMultipleChoiceOptionData"]);
        break;*/
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
  newPage,
  paragraph,
  reference,
  section,
  singleChoice,
  //singleChoiceOption,
  span,
  subSection,
  subSubSection,
  table,
  text,
  variableReference
}

// TODO: fill this list
Map<MbclLevelItemType, List<MbclLevelItemType>> mbclSubBlockWhiteList = {
  MbclLevelItemType.exercise: [
    //
    MbclLevelItemType.equation
  ],
  MbclLevelItemType.defDefinition: [
    // also applied for MbclLevelItemType.def*
    MbclLevelItemType.alignLeft,
    MbclLevelItemType.alignCenter,
    MbclLevelItemType.alignRight,
    MbclLevelItemType.equation,
    MbclLevelItemType.paragraph,
  ],
  MbclLevelItemType.example: [
    //
    MbclLevelItemType.equation
  ]
};

class MbclEquationData {
  //List<MbclEquationOption> options = [];
  MbclLevelItem? math;
  int number = 0;

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
    math = MbclLevelItem(MbclLevelItemType.error);
    math?.fromJSON(src["math"]);
    number = src["number"];
  }
}

/*enum MbclEquationOption {
  aligned,
}*/

enum MbclExerciseFeedback { unchecked, correct, incorrect }

class MbclExerciseData {
  // import/export
  String code = '';
  List<String> variables = [];
  List<Map<String, String>> instances = []; // TODO: DESCRIBE!!
  bool staticOrder = false;
  int scores = 1;
  bool showGapLength = false;
  bool showRequiredGapLettersOnly = false;

  // temporary
  int staticVariableCounter = 0; // not exported
  Map<String, String> smplOperandType = {}; // not exported
  Map<String, MbclInputFieldData> inputFields = {};
  MbclExerciseFeedback feedback = MbclExerciseFeedback.unchecked;
  List<int> indexOrdering =
      []; // e.g. used for random displayed order of multiple-choice

  // runtime variables
  int runInstanceIdx = -1; // selected exercise instance; -1 := not chosen

  Map<String, dynamic> toJSON() {
    // TODO: do NOT output "code" in final build
    return {
      "code": code,
      "variables": variables.map((e) => e).toList(),
      "instances": instances.map((e) => e).toList(),
      "staticOrder": staticOrder,
      "scores": scores,
      "showGapLength": showGapLength,
      "showRequiredGapLettersOnly": showRequiredGapLettersOnly,
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
    scores = src["scores"] as int;
    showGapLength = src["showGapLength"] as bool;
    showRequiredGapLettersOnly = src["showRequiredGapLettersOnly"] as bool;
  }
}

class MbclFigureData {
  String filePath = '';
  String code = '';
  String data = '';
  List<MbclLevelItem> caption = [];
  List<MbclFigureOption> options = [];

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
      var cap = MbclLevelItem(MbclLevelItemType.error);
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
  MbclTableRow head = MbclTableRow();
  List<MbclTableRow> rows = [];
  List<MbclTableOption> options = [];

  Map<String, dynamic> toJSON() {
    return {
      "head": head.toJSON(),
      "rows": rows.map((e) => e.toJSON()).toList(),
      "options": options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    head = MbclTableRow();
    head.fromJSON(src["head"]);
    rows = [];
    int n = src["rows"].length;
    for (var i = 0; i < n; i++) {
      var row = MbclTableRow();
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
  String studentValue = '';
  String expectedValue = '';

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
  complexSet,
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
  List<MbclLevelItem> columns = [];

  Map<String, dynamic> toJSON() {
    return {"columns": columns.map((e) => e.toJSON()).toList()};
  }

  fromJSON(Map<String, dynamic> src) {
    columns = [];
    int n = src["columns"].length;
    for (var i = 0; i < n; i++) {
      var column = MbclLevelItem(MbclLevelItemType.error);
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
