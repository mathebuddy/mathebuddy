// TODO: rename file, add meta data to file header, ...

class Block_NEW {
  String id = "";
  String title = "";
  int indent = 0;
  String label = "";
  Map<String, String> attributes = {};
  String data = "";
  List<Block_NEW> children = [];
  int srcLine = -1;

  Block_NEW(this.id, this.indent, this.srcLine);

  void postProcess() {
    // combine consecutive DEFAULT blocks
    for (int i = 0; i < children.length; i++) {
      if (children[i].id == "DEFAULT") {
        for (int k = i + 1; k < children.length; k++) {
          if (children[k].id == "DEFAULT") {
            children[i].data += children[k].data;
            children.removeAt(k);
            k--;
          } else {
            break;
          }
        }
      }
    }
    for (var child in children) {
      child.postProcess();
    }
    // reduce indentation (if applicable)
    if (data.isNotEmpty) {
      // (a) for all nonempty lines: get minimum of preceding spaces
      var lines = data.split("\n");
      var minSpaces = 10000;
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        var spaces = 0;
        for (var k = 0; k < line.length; k++) {
          if (line[k] == ' ') {
            spaces++;
          } else {
            break;
          }
        }
        if (spaces < minSpaces) {
          minSpaces = spaces;
        }
      }
      // (b) for all nonempty lines: remove spaces
      for (int i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.trim().isEmpty) continue;
        lines[i] = line.substring(minSpaces);
      }
      data = lines.join("\n");
    }
  }

  @override
  String toString() {
    var s = '';
    s += '${_indent(indent)}--------\n';
    s += '${_indent(indent)}ID="$id"\n';
    s += '${_indent(indent)}SRC_LINE="$srcLine"\n';
    s += '${_indent(indent)}TITLE="$title"\n';
    s += '${_indent(indent)}LABEL="$label"\n';
    s += '${_indent(indent)}ATTRIBUTES=[';
    for (var key in attributes.keys) {
      var value = attributes[key];
      s += '$key=$value';
      s += ',';
    }
    s += ']\n';
    var d = data.replaceAll("\n", "\\n").replaceAll("\t", "\\t");
    s += '${_indent(indent)}DATA="$d"\n';
    s += '${_indent(indent)}CHILDREN:\n';
    for (var child in children) {
      s += child.toString();
    }
    return s;
  }

  String _indent(int n) {
    var s = '';
    for (int i = 0; i < n * 4; i++) {
      s += ' ';
    }
    return s;
  }
}
