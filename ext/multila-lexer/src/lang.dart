/*
  PROJECT

    MULTILA Compiler and Computer Architecture Infrastructure
    Copyright (c) 2022 by Andreas Schwenk, contact@multila.org
    Licensed by GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

  SYNOPSIS

    TODO

*/

enum Language { EN, DE }

enum LanguageText {
  EXPECTED,
  EXPECTED_ONE_OF,
  CONDITION_NOT_BOOLEAN,
  UNKNOWN_SYMBOL,
  SYMBOL_IS_NOT_A_FUNCTION,
  BIN_OP_INCOMPATIBLE_TYPES
}

var lang = Language.EN;

void setLanguage(Language l) {
  lang = l;
}

String getStr(LanguageText str) {
  switch (lang) {
    case Language.EN:
      {
        switch (str) {
          case LanguageText.EXPECTED:
            return 'expected';
          case LanguageText.EXPECTED_ONE_OF:
            return 'expected one of';
          case LanguageText.CONDITION_NOT_BOOLEAN:
            return 'condition must be boolean';
          case LanguageText.UNKNOWN_SYMBOL:
            return 'unknown symbol';
          case LanguageText.SYMBOL_IS_NOT_A_FUNCTION:
            return 'symbol is not a function';
          case LanguageText.BIN_OP_INCOMPATIBLE_TYPES:
            return 'Operator \$OP is incompatible for types \$T1 and \$T2';
        }
      }
    case Language.DE:
      {
        switch (str) {
          case LanguageText.EXPECTED:
            return 'erwarte';
          case LanguageText.EXPECTED_ONE_OF:
            return 'erwarte Token aus Liste';
          case LanguageText.CONDITION_NOT_BOOLEAN:
            return 'Bedingung muss Boolsch sein';
          case LanguageText.UNKNOWN_SYMBOL:
            return 'unbekanntes Symbol';
          case LanguageText.SYMBOL_IS_NOT_A_FUNCTION:
            return 'Symbol ist keine Funktion';
          case LanguageText.BIN_OP_INCOMPATIBLE_TYPES:
            return 'Operator \$OP ist inkompatibel mit den Typen \$T1 und \$T2';
        }
      }
  }
}
