/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataBlock.dart';
import 'dataText.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

class MBL_Exercise extends MBL_BlockItem {
  String type = 'exercise';
  Map<String,MBL_Exercise_Variable> variables = {};
  List<MBL_Exercise_Instance> instances = [];
  String code = '';
  MBL_Exercise_Text text = new MBL_Text_Paragraph();
  int staticVariableCounter = 0;

  String addStaticBooleanVariable(bool value) {
    var varId = '__bool__' + (this.staticVariableCounter++).toString();
    var v = new MBL_Exercise_Variable();
    v.type = MBL_Exercise_VariableType.Bool;
    this.variables[varId] = v;
    var NUM_INST = 3; // TODO!!
    if (this.instances.length == 0)
      for (var i = 0; i < NUM_INST; i++)
        this.instances.add(new MBL_Exercise_Instance());
    for (var i = 0; i < NUM_INST; i++)
      this.instances[i].values[varId] = value ? 'true' : 'false';
    return varId;
  }

  void postProcess() {
    this.text.postProcess();
  }

  Map<String,Object> toJSON() {
    var variablesJSON: { [id: string]: JSONValue } = {};
    for (var v in this.variables) {
      variablesJSON[v] = this.variables[v].toJSON();
    }
    // TODO: do NOT output code when "single_level" == false
    return {
      "type": this.type,
      "title": this.title,
      "label": this.label,
      "error": this.error,
      "code": this.code,
      "variables": variablesJSON,
      "instances": this.instances.map((instance) => instance.toJSON()),
      "text": this.text.toJSON(),
    };
  }
}

enum MBL_Exercise_VariableType {
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
}

class MBL_Exercise_Variable {
  MBL_Exercise_VariableType type;

  MBL_Exercise_Variable(this.type);
  
  Map<String,Object> toJSON() {
    return {
      "type": this.type.name,
    };
  }
}

class MBL_Exercise_Instance {
  Map<String,String> values = {};

  toJSON(): JSONValue {
    return this.values;
  }
}

abstract class MBL_Exercise_Text extends MBL_Text {}

class MBL_Exercise_Text_Variable extends MBL_Exercise_Text {
  String type = 'variable';
  String variableId = '';
  
  void postProcess() {
    /* empty */
  }
  
  Map<String,Object> toJSON() {
    return {
      "type": this.type,
      "variable": this.variableId,
    };
  }
}

class MBL_Exercise_Text_Input extends MBL_Exercise_Text {
  String type = 'text_input';
  String input_id = 'NONE';
  MBL_Exercise_Text_Input_Type input_type;
  String variable = '';
  List<String> inputRequire = [];
  List<String> inputForbid = [];
  int width = 0;
  
  void postProcess() {
    /* empty */
  }
  
  Map<String,Object> toJSON() {
    return {
      "type": this.type,
      "input_id": this.input_id,
      "input_type": this.type,
      "input_require": this.inputRequire.map((i) => i.toString()),
      "input_forbid": this.inputForbid.map((i) => i.toString()),
      "variable": this.variable,
      "width": this.width,
    };
  }
}

// TODO: class MBL_Exercise_Text_Choices_Input

class MBL_Exercise_Text_Multiple_Choice extends MBL_Exercise_Text {
  String type = 'multiple_choice';
  List<MBL_Exercise_Text_Single_or_Multi_Choice_Option> items = [];
  
  void postProcess() {
    for (var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
  }
  
  Map<String,Object> toJSON() {
    return {
      "type": this.type,
      "items": this.items.map((i) => i.toJSON()),
    };
  }
}

class MBL_Exercise_Text_Single_Choice extends MBL_Exercise_Text {
  String type = 'single_choice';
  List<MBL_Exercise_Text_Single_or_Multi_Choice_Option> items = [];
  
  void postProcess() {
    for (var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
  }
  
  Map<String,Object> toJSON() {
    return {
      "type": this.type,
      "items": this.items.map((i) => i.toJSON()),
    };
  }
}

class MBL_Exercise_Text_Single_or_Multi_Choice_Option {
  String variable = '';
  String input_id = 'NONE';
  MBL_Text text;

  void postProcess() {
    this.text.postProcess();
  }

  Map<String,Object> toJSON() {
    return {
      "variable": this.variable,
      "input_id": this.input_id,
      "text": this.text.toJSON(),
    };
  }
}

enum MBL_Exercise_Text_Input_Type {
  Int,
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

void aggregateMultipleChoice(List<MBL_Text> items) {
  for (var i = 0; i < items.length; i++) {
    if (
      i > 0 &&
      items[i - 1] is MBL_Exercise_Text_Multiple_Choice &&
      items[i] is MBL_Exercise_Text_Multiple_Choice
    ) {
      var u = <MBL_Exercise_Text_Multiple_Choice>items[i - 1];
      var v = <MBL_Exercise_Text_Multiple_Choice>items[i];
      u.items = u.items.concat(v.items);
      items.splice(i, 1);
      i--;
    }
  }
}

void aggregateSingleChoice(List<MBL_Text> items) {
  for (var i = 0; i < items.length; i++) {
    if (
      i > 0 &&
      items[i - 1] is MBL_Exercise_Text_Single_Choice &&
      items[i] is MBL_Exercise_Text_Single_Choice
    ) {
      var u = <MBL_Exercise_Text_Multiple_Choice>items[i - 1];
      var v = <MBL_Exercise_Text_Multiple_Choice>items[i];
      u.items = u.items.concat(v.items);
      items.splice(i, 1);
      i--;
    }
  }
}
