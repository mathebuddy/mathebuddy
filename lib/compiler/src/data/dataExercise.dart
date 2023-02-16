/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataBlock.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

class MBL_Exercise extends MBL_BlockItem {
  String type = 'exercise';
  Map<String,MBL_Exercise_Variable> variables: = {};
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
  type: MBL_Exercise_VariableType;
  toJSON(): JSONValue {
    return {
      type: this.type.toString(),
    };
  }
}

class MBL_Exercise_Instance {
  values: { [id: string]: string } = {};
  toJSON(): JSONValue {
    return this.values;
  }
}

abstract class MBL_Exercise_Text extends MBL_Text {}

class MBL_Exercise_Text_Variable extends MBL_Exercise_Text {
  type = 'variable';
  variableId = '';
  postProcess(): void {
    /* empty */
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      variable: this.variableId,
    };
  }
}

class MBL_Exercise_Text_Input extends MBL_Exercise_Text {
  type = 'text_input';
  input_id = 'NONE';
  input_type: MBL_Exercise_Text_Input_Type;
  variable = '';
  inputRequire: string[] = [];
  inputForbid: string[] = [];
  width = 0;
  postProcess(): void {
    /* empty */
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      input_id: this.input_id,
      input_type: this.type,
      input_require: this.inputRequire.map((i) => i.toString()),
      input_forbid: this.inputForbid.map((i) => i.toString()),
      variable: this.variable,
      width: this.width,
    };
  }
}

// TODO: class MBL_Exercise_Text_Choices_Input

class MBL_Exercise_Text_Multiple_Choice extends MBL_Exercise_Text {
  type = 'multiple_choice';
  items: MBL_Exercise_Text_Single_or_Multi_Choice_Option[] = [];
  postProcess(): void {
    for (var i of this.items) i.postProcess();
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      items: this.items.map((i) => i.toJSON()),
    };
  }
}

class MBL_Exercise_Text_Single_Choice extends MBL_Exercise_Text {
  type = 'single_choice';
  items: MBL_Exercise_Text_Single_or_Multi_Choice_Option[] = [];
  postProcess(): void {
    for (var i of this.items) i.postProcess();
  }
  toJSON(): JSONValue {
    return {
      type: this.type,
      items: this.items.map((i) => i.toJSON()),
    };
  }
}

class MBL_Exercise_Text_Single_or_Multi_Choice_Option {
  variable = '';
  input_id = 'NONE';
  text: MBL_Text;
  postProcess(): void {
    this.text.postProcess();
  }
  toJSON(): JSONValue {
    return {
      variable: this.variable,
      input_id: this.input_id,
      text: this.text.toJSON(),
    };
  }
}

enum MBL_Exercise_Text_Input_Type {
  Int = 'int',
  Real = 'real',
  ComplexNormal = 'complex_normal',
  ComplexPolar = 'complex_polar',
  ComplexSet = 'complex_set',
  IntSet = 'int_set',
  IntSetNArts = 'int_set_n_args',
  Vector = 'vector',
  VectorFlex = 'vector_flex',
  Matrix = 'matrix',
  MatrixFlexRows = 'matrix_flex_rows',
  MatrixFlexCols = 'matrix_flex_cols',
  MatrixFlex = 'matrix_flex',
  Term = 'term',
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
