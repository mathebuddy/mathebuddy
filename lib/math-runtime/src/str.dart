/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'operand.dart';
import 'term.dart';

String term2string(Term term) {
  var s = '';
  switch (term.op) {
    case '#':
    case '\$':
      if (term.value.type == OperandType.int ||
          term.value.type == OperandType.real ||
          term.value.type == OperandType.irrational ||
          term.value.type == OperandType.identifier) {
        s = term.value.toString();
      } else {
        s = '(${term.value})';
      }
      break;
    case '.-':
      s += '(-(${term.o[0]}))'; // TODO: test!!
      break;
    default:
      if (term.op.length > 2) {
        // sin, cos, exp, ...
        s += term.op;
        if (term.dims.isNotEmpty) {
          s += '<';
          for (var i = 0; i < term.dims.length; i++) {
            if (i > 0) s += ',';
            s += term.dims[i].toString();
          }
          s += '>';
        }
        s += '(';
        for (var i = 0; i < term.o.length; i++) {
          if (i > 0) s += ',';
          s += term.o[i].toString();
        }
        s += ')';
      } else {
        // '+', '-', ...
        s += '(';
        for (var i = 0; i < term.o.length; i++) {
          if (i > 0) s += term.op;
          s += term.o[i].toString();
        }
        s += ')';
      }
      break;
  }
  return s;
}
