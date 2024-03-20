/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

// refer to the specification at https://mathebuddy.github.io/mathebuddy/

import 'level.dart';
import 'level_item_equation.dart';
import 'level_item_exercise.dart';
import 'level_item_figure.dart';
import 'level_item_input_field.dart';
import 'level_item_table.dart';

enum MbclLevelItemType {
  alignCenter,
  alignLeft,
  alignRight,
  boldText,
  color,
  debugInfo,
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
  inlineCode,
  inlineMath,
  inputField,
  italicText,
  itemize,
  lineFeed,
  multipleChoice,
  paragraph,
  part,
  reference,
  section,
  singleChoice,
  span,
  subSection,
  subSubSection,
  table,
  text,
  languageSeparator,
  todo,
  variableReferenceOperand,
  variableReferenceTerm,
  variableReferenceOptimizedTerm
}

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
  String chatKeys = '';
  List<int> indexOrdering =
      []; // e.g. used for random displayed order of multiple-choice

  MbclLevelItem(this.level, this.type, this.srcLine, [this.text = '']);

  List<MbclLevelItem> getItemsByType(MbclLevelItemType type) {
    List<MbclLevelItem> res = [];
    for (var item in items) {
      res.addAll(item.getItemsByType(type));
      if (item.type == type) {
        res.add(item);
      }
    }
    return res;
  }

  String gatherErrors() {
    var err = error.isEmpty ? "" : "$error\n";
    for (var item in items) {
      err += item.gatherErrors();
    }
    return err;
  }

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

String filterLanguage(String s, int languageIndex) {
  var tokens = s.split("///");
  var res = tokens[languageIndex < tokens.length ? languageIndex : 0];
  return res;
}

List<MbclLevelItem> filterLanguage2(
    List<MbclLevelItem> items, int languageIndex) {
  // TODO: support more than two languages
  var languageSeparatorIdx = -1;
  for (var i = 0; i < items.length; i++) {
    if (items[i].type == MbclLevelItemType.languageSeparator) {
      languageSeparatorIdx = i;
      break;
    }
  }
  var relevantItems = items;
  if (languageSeparatorIdx >= 0) {
    if (languageIndex == 0) {
      relevantItems = relevantItems.sublist(0, languageSeparatorIdx);
    } else {
      relevantItems = relevantItems.sublist(languageSeparatorIdx + 1);
    }
  }
  return relevantItems;
}
