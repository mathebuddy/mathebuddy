/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

// TODO: remove the following import!
import '../../math-runtime/src/operand.dart';

// refer to the specification at https://mathebuddy.github.io/mathebuddy/ (TODO: update link!)

class MBCL_LevelItem {
  MBCL_LevelItemType type;
  String title = '';
  String label = '';
  String error = '';
  String text = '';
  String id = '';
  List<MBCL_LevelItem> items = [];

  // data for certain types only
  MBCL_EquationData? equationData = null;
  MBCL_ExerciseData? exerciseData = null;
  MBCL_FigureData? figureData = null;
  MBCL_TableData? tableData = null;
  MBCL_InputFieldData? inputFieldData = null;
  MBCL_SingleOrMultipleChoiceOptionData? singleOrMultipleChoiceOptionData =
      null;

  MBCL_LevelItem(this.type, [text = '']) {
    this.text = text;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      "type": this.type.name,
    };
    if (this.title.length > 0) json["title"] = this.title;
    if (this.label.length > 0) json["label"] = this.label;
    if (this.error.length > 0) json["error"] = this.error;
    if (this.text.length > 0) json["text"] = this.text;
    if (this.id.length > 0) json["id"] = this.id;
    if (this.items.length > 0)
      json["items"] = this.items.map((item) => item.toJSON()).toList();
    switch (this.type) {
      case MBCL_LevelItemType.Equation:
        json["equationData"] = this.equationData?.toJSON();
        break;
      case MBCL_LevelItemType.Exercise:
        json["exerciseData"] = this.exerciseData?.toJSON();
        break;
      case MBCL_LevelItemType.Figure:
        json["figureData"] = this.figureData?.toJSON();
        break;
      case MBCL_LevelItemType.Table:
        json["tableData"] = this.tableData?.toJSON();
        break;
      case MBCL_LevelItemType.InputField:
        json["inputFieldData"] = this.inputFieldData?.toJSON();
        break;
      case MBCL_LevelItemType.SingleChoiceOption:
      case MBCL_LevelItemType.MultipleChoiceOption:
        json["singleOrMultipleChoiceOptionData"] =
            this.singleOrMultipleChoiceOptionData?.toJSON();
        break;
      default:
        break;
    }
    return json;
  }

  fromJSON(Map<String, dynamic> src) {
    this.type = MBCL_LevelItemType.values.byName(src["type"]);
    this.title = src.containsKey("title") ? src["title"] : "";
    this.label = src.containsKey("label") ? src["label"] : "";
    this.error = src.containsKey("error") ? src["error"] : "";
    this.text = src.containsKey("text") ? src["text"] : "";
    this.id = src.containsKey("id") ? src["id"] : "";
    this.items = [];
    if (src.containsKey("items")) {
      int n = src["items"].length;
      for (var i = 0; i < n; i++) {
        var item = new MBCL_LevelItem(MBCL_LevelItemType.Error);
        item.fromJSON(src["items"][i]);
        this.items.add(item);
      }
    }
    this.equationData = null;
    this.exerciseData = null;
    this.figureData = null;
    this.tableData = null;
    this.inputFieldData = null;
    this.singleOrMultipleChoiceOptionData = null;
    switch (this.type) {
      case MBCL_LevelItemType.Equation:
        this.equationData = new MBCL_EquationData();
        this.equationData?.fromJSON(src["equationData"]);
        break;
      case MBCL_LevelItemType.Exercise:
        this.exerciseData = new MBCL_ExerciseData();
        this.exerciseData?.fromJSON(src["exerciseData"]);
        break;
      case MBCL_LevelItemType.Figure:
        this.figureData = new MBCL_FigureData();
        this.figureData?.fromJSON(src["figureData"]);
        break;
      case MBCL_LevelItemType.Table:
        this.tableData = new MBCL_TableData();
        this.tableData?.fromJSON(src["tableData"]);
        break;
      case MBCL_LevelItemType.InputField:
        this.inputFieldData = new MBCL_InputFieldData();
        this.inputFieldData?.fromJSON(src["inputFieldData"]);
        break;
      case MBCL_LevelItemType.SingleChoiceOption:
      case MBCL_LevelItemType.MultipleChoiceOption:
        this.singleOrMultipleChoiceOptionData =
            new MBCL_SingleOrMultipleChoiceOptionData();
        this
            .singleOrMultipleChoiceOptionData
            ?.fromJSON(src["singleOrMultipleChoiceOptionData"]);
        break;
      default:
        break;
    }
  }
}

enum MBCL_LevelItemType {
  AlignCenter,
  AlignLeft,
  AlignRight,
  BoldText,
  Color,
  DefAxiom,
  DefClaim,
  DefConjecture,
  DefCorollary,
  DefDefinition,
  DefIdentity,
  DefLemma,
  DefParadox,
  DefProposition,
  DefTheorem,
  Enumerate,
  EnumerateAlpha,
  Equation,
  Error,
  Example,
  Exercise,
  Figure,
  InlineMath,
  InputField,
  ItalicText,
  Itemize,
  LineFeed,
  MultipleChoice,
  MultipleChoiceOption,
  NewPage,
  Paragraph,
  Reference,
  Section,
  SingleChoice,
  SingleChoiceOption,
  Span,
  SubSection,
  SubSubSection,
  Table,
  Text,
  VariableReference
}

// TODO: fill this list
Map<MBCL_LevelItemType, List<MBCL_LevelItemType>> MBCL_SubBlockWhiteList = {
  MBCL_LevelItemType.Exercise: [MBCL_LevelItemType.Equation]
};

class MBCL_EquationData {
  List<MBCL_EquationOption> options = [];
  int number = 0;

  Map<String, dynamic> toJSON() {
    return {
      "options": this.options.map((o) => o.name).toList(),
      "number": this.number
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.options = [];
    int n = src["options"].length;
    for (var i = 0; i < n; i++) {
      var option = MBCL_EquationOption.values.byName(src["options"][i]);
      this.options.add(option);
    }
    this.number = src["number"];
  }
}

enum MBCL_EquationOption {
  AlignLeft,
  AlignCenter,
  AlignRight,
  AlignEquals,
}

class MBCL_ExerciseData {
  String code = '';
  List<String> variables = [];
  List<Map<String, String>> instances = [];
  List<String> inputRequire = [];
  List<String> inputForbid = [];
  String inputVariableId = '';
  int inputWidth = 0;
  int staticVariableCounter___ = 0; // not exported
  Map<String, OperandType> operandType___ = {}; // not exported

  Map<String, dynamic> toJSON() {
    // TODO: do NOT output "code" in final build
    return {
      "code": this.code,
      "variables": this.variables.map((e) => e).toList(),
      "instances": this.instances.map((e) => e).toList(),
      "inputRequire": this.inputRequire.map((e) => e).toList(),
      "inputForbid": this.inputForbid.map((e) => e).toList(),
      "inputVariableId": this.inputVariableId,
      "inputWidth": this.inputWidth
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.code = src["code"];
    this.variables = [];
    int n = src["variables"].length;
    for (var i = 0; i < n; i++) this.variables.add(src["variables"][i]);
    this.instances = [];
    n = src["instances"].length;
    for (var i = 0; i < n; i++) {
      Map<String, dynamic> instanceSrc = src["instances"][i];
      Map<String, String> instance = {};
      for (var key in instanceSrc.keys) {
        String value = instanceSrc[key];
        instance[key] = value;
      }
      this.instances.add(instance);
    }
    this.inputRequire = [];
    n = src["inputRequire"].length;
    for (var i = 0; i < n; i++) this.inputRequire.add(src["inputRequire"][i]);
    this.inputForbid = [];
    n = src["inputForbid"].length;
    for (var i = 0; i < n; i++) this.inputForbid.add(src["inputForbid"][i]);
    this.inputVariableId = src["inputVariableId"];
    this.inputWidth = src["inputWidth"];
  }
}

class MBCL_FigureData {
  String filePath = '';
  String data = '';
  List<MBCL_LevelItem> caption = [];
  List<MBCL_Figure_Option> options = [];

  Map<String, dynamic> toJSON() {
    return {
      "filePath": this.filePath,
      "data": this.data,
      "caption": this.caption.map((e) => e.toJSON()).toList(),
      "options": this.options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.filePath = src["filePath"];
    this.data = src["data"];
    int n = src["caption"].length;
    for (var i = 0; i < n; i++) {
      var cap = new MBCL_LevelItem(MBCL_LevelItemType.Error);
      cap.fromJSON(src["caption"][i]);
      this.caption.add(cap);
    }
    n = src["options"].length;
    for (var i = 0; i < n; i++)
      this.options.add(MBCL_Figure_Option.values.byName(src["options"][i]));
  }
}

enum MBCL_Figure_Option {
  Width25,
  Width33,
  Width50,
  Width66,
  Width75,
  Width100,
}

class MBCL_TableData {
  MBCL_Table_Row head = new MBCL_Table_Row();
  List<MBCL_Table_Row> rows = [];
  List<MBCL_Table_Option> options = [];

  Map<String, dynamic> toJSON() {
    return {
      "head": this.head.toJSON(),
      "rows": this.rows.map((e) => e.toJSON()).toList(),
      "options": this.options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.head = new MBCL_Table_Row();
    this.head.fromJSON(src["head"]);
    this.rows = [];
    int n = src["rows"].length;
    for (var i = 0; i < n; i++) {
      var row = new MBCL_Table_Row();
      row.fromJSON(src["rows"][i]);
      this.rows.add(row);
    }
    this.options = [];
    n = src["options"].length;
    for (var i = 0; i < n; i++)
      this.options.add(MBCL_Table_Option.values.byName(src["options"][i]));
  }
}

class MBCL_InputFieldData {
  MBCL_InputField_Type type = MBCL_InputField_Type.None;

  Map<String, dynamic> toJSON() {
    return {"type": this.type.name};
  }

  fromJSON(Map<String, dynamic> src) {
    this.type = MBCL_InputField_Type.values.byName(src["type"]);
  }
}

enum MBCL_InputField_Type {
  None,
  Int,
  Rational,
  Real,
  ComplexNormal,
  ComplexPolar,
  ComplexSet,
  IntSet,
  IntSetNArts,
  Vector,
  VectorFlex,
  Matrix,
  MatrixFlexRows,
  MatrixFlexCols,
  MatrixFlex,
  Term,
}

class MBCL_SingleOrMultipleChoiceOptionData {
  String inputId = '';
  String variableId = '';

  Map<String, dynamic> toJSON() {
    return {
      "inputId": this.inputId,
      "variableId": this.variableId,
    };
  }

  fromJSON(Map<String, dynamic> src) {
    this.inputId = src["inputId"];
    this.variableId = src["variableId"];
  }
}

class MBCL_Table_Row {
  List<MBCL_LevelItem> columns = [];

  Map<String, dynamic> toJSON() {
    return {"columns": this.columns.map((e) => e.toJSON()).toList()};
  }

  fromJSON(Map<String, dynamic> src) {
    this.columns = [];
    int n = src["columns"];
    for (var i = 0; i < n; i++) {
      var column = new MBCL_LevelItem(MBCL_LevelItemType.Error);
      column.fromJSON(src["columns"][i]);
      this.columns.add(column);
    }
  }
}

enum MBCL_Table_Option {
  AlignLeft,
  AlignCenter,
  AlignRight,
}
