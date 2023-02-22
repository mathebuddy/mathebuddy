/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import '../../compiler/src/level.dart';
import '../../compiler/src/level_item.dart';
import '../../math-runtime/src/operand.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html (TODO: update link!)

abstract class MBCL_LevelItem__ABSTRACT {
  MBCL_LevelItemType type;
  String title = '';
  String label = '';
  String error = '';
  String text = '';
  String id = '';
  List<MBCL_LevelItem__ABSTRACT> items = [];

  // data for certain types only
  MBCL_EquationData? equationData = null;
  MBCL_ExerciseData? exerciseData = null;
  MBCL_FigureData? figureData = null;
  MBCL_TableData? tableData = null;
  MBCL_InputFieldData? inputFieldData = null;

  MBCL_LevelItem__ABSTRACT(this.type);

  void postProcess();

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      "type": this.type.name,
      "title": this.title,
      "label": this.label,
      "error": this.error,
      "text": this.text,
      "id": this.id,
      "items": this.items.map((item) => item.toJSON()).toList(),
    };
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
      default:
        break;
    }
    return json;
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
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
  InputField,
  //ExerciseTextVariable, ???
  Figure,
  InlineMath,
  ItalicText,
  Itemize,
  LineFeed,
  NewPage,
  Paragraph,
  Reference,
  Section,
  Span,
  SubSection,
  SubSubSection,
  Table,
  Text,
}

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
    // TODO
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
  int staticVariableCounter = 0;
  List<String> variables = [];
  List<Map<String, String>> instances = [];
  List<String> inputRequire = [];
  List<String> inputForbid = [];
  String inputVariableId = '';
  int inputWidth = 0;
  // TODO: single/multiple choice
  Map<String, OperandType> operandType___ = {}; // not experted

  Map<String, dynamic> toJSON() {
    // TODO: do NOT output code in final build
    return {
      "code": this.code,
      "variables": this.variables,
      "instances": this.instances.map((e) => e).toList(),
      "inputRequire": this.inputRequire.map((e) => e).toList(),
      "inputForbid": this.inputForbid.map((e) => e).toList(),
      "inputVariableId": this.inputVariableId,
      "inputWidth": this.inputWidth
    };
    // TODO: single/multiple choice
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
  }
}

/*enum MBCL_Exercise_VariableType {
  Bool,
  Int,
  IntSet,
  Real,
  RealSet,
  Complex,
  ComplexSet,
  Vector,
  Matrix,
  Term,
}*/

class MBCL_FigureData {
  String filePath = '';
  String data = '';
  List<MBCL_Figure_Option> options = [];

  Map<String, dynamic> toJSON() {
    return {
      "filePath": this.filePath,
      "data": this.data,
      "options": this.options.map((e) => e.name).toList()
    };
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
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
    // TODO
  }
}

class MBCL_InputFieldData {
  MBCL_InputField_Type type = MBCL_InputField_Type.None;

  Map<String, dynamic> toJSON() {
    return {"type": this.type.name};
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
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

class MBCL_Table_Row {
  List<MBCL_LevelItem__ABSTRACT> columns = [];

  Map<String, dynamic> toJSON() {
    return {"columns": this.columns.map((e) => e.toJSON()).toList()};
  }

  fromJSON(Map<String, dynamic> src) {
    // TODO
  }
}

enum MBCL_Table_Option {
  AlignLeft,
  AlignCenter,
  AlignRight,
}
