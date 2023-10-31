/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

String extractDirname(String path) {
  if (path.contains('/') == false) return '';
  return path.substring(0, path.lastIndexOf('/') + 1);
}

/// A counter variable to generate unique IDs.
int uniqueIdCounter = 0;

int createUniqueId() {
  return uniqueIdCounter++;
}

void checkAttributes(Map<String, String> attributes, List<String> validKeys) {
  for (var key in attributes.keys) {
    if (validKeys.contains(key) == false) {
      throw Exception("Unknown attribute $key. ");
    }
  }
}

bool hasAttribute(Map<String, String> attributes, String key) {
  return attributes.containsKey(key);
}

bool getAttributeBool(
    Map<String, String> attributes, String key, bool defaultValue) {
  var res = defaultValue;
  if (attributes.containsKey(key)) {
    var value = attributes[key]!;
    if (value == "true") {
      res = true;
    } else if (value == "false") {
      res = false;
    } else {
      throw Exception(
          "Attribute value of '$key' must be boolean, i.e. 'true' or 'false'. ");
    }
  }
  return res;
}

int getAttributeInt(
    Map<String, String> attributes, String key, int defaultValue) {
  var res = defaultValue;
  if (attributes.containsKey(key)) {
    var value = attributes[key]!;
    try {
      res = int.parse(value);
    } catch (e) {
      throw Exception("Attribute value of '$key' must be an integral number. ");
    }
  }
  return res;
}

String getAttributeIdentifier(Map<String, String> attributes, String key) {
  var res = "";
  if (attributes.containsKey(key)) {
    res = attributes[key]!;
  }
  if (isIdentifier(res) == false) {
    throw Exception("Attribute value of '$key' must be an identifier. ");
  }
  return res;
}

String getAttributeString(Map<String, String> attributes, String key,
    List<String> allowedValues, String defaultValue) {
  var res = defaultValue;
  if (attributes.containsKey(key)) {
    res = attributes[key]!;
  }
  if (allowedValues.contains(res) == false) {
    throw Exception("Attribute value of '$key' must be one of "
        "[${allowedValues.map((e) => '"$e"').join(",")}]. ");
  }
  return res;
}

bool isNum0(String tk) {
  return tk.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
      tk.codeUnitAt(0) <= '9'.codeUnitAt(0);
}

bool isNum1(String tk) {
  return tk.codeUnitAt(0) >= '1'.codeUnitAt(0) &&
      tk.codeUnitAt(0) <= '9'.codeUnitAt(0);
}

bool isAlpha(String tk) {
  if (tk.isEmpty) return false;
  return tk.codeUnitAt(0) == '_'.codeUnitAt(0) ||
      (tk.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          tk.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
      (tk.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          tk.codeUnitAt(0) <= 'z'.codeUnitAt(0));
}

bool isIdentifier(String tk) {
  var n = tk.length;
  for (var i = 0; i < n; i++) {
    var ch = tk[i];
    if (i == 0 && !isAlpha(ch)) {
      return false;
    } else if (!isAlpha(ch) && !isNum0(ch)) {
      return false;
    }
  }
  return true;
}
