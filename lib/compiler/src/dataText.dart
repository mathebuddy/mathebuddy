/**
 * mathe:buddy - a gamified learning-app for higher math
 * (c) 2022-2023 by TH Koeln
 * Author: Andreas Schwenk contact@compiler-construction.com
 * Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
 * License: GPL-3.0-or-later
 */

import 'dataLevel.dart';

// refer to the specification at https://app.f07-its.fh-koeln.de/docs-mbcl.html

// -------- TEXT --------

abstract class MBL_Text extends MBL_LevelItem {}

void simplifyText(List<MBL_Text> items) {
  // remove unnecessary line feeds
  while (items.length > 0 && items[0] is MBL_Text_Linefeed) {
    items.shift();
  }
  while (
    items.length > 0 &&
    items[items.length - 1] is MBL_Text_Linefeed
  ) {
    items.removeLast();
  }
  // concatenate consecutive text items
  for (var i = 0; i < items.length; i++) {
    if (
      i > 0 &&
      items[i - 1] is MBL_Text_Text &&
      items[i] is MBL_Text_Text
    ) {
      var text = (<MBL_Text_Text>items[i]).value;
      if ('.,:!?'.includes(text) == false) text = ' ' + text;
      (<MBL_Text_Text>items[i - 1]).value += text;
      // TODO: next line is an ugly hack for TeX..
      (<MBL_Text_Text>items[i - 1]).value = (<MBL_Text_Text>(
        items[i - 1]
      )).value.replace(/\\ /g, '\\');
      items.splice(i, 1);
      i--;
    }
  }
}

class MBL_Text_Paragraph extends MBL_Text {
  String type = 'paragraph';
  List<MBL_Text> items = [];

  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
    aggregateMultipleChoice(this.items);
    aggregateSingleChoice(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_InlineMath extends MBL_Text {
  String type = 'inline_math';
  List<MBL_Text> items = [];

  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_Bold extends MBL_Text {
  String type = 'bold';
  List<MBL_Text> items = [];

  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_Italic extends MBL_Text {
  String type = 'italic';
  List<MBL_Text> items = [];

  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

enum MBL_Text_Itemize_Type {
  Itemize,
  Enumerate,
  EnumerateAlpha,
}

class MBL_Text_Itemize extends MBL_Text {
  type: MBL_Text_Itemize_Type;
  List<MBL_Text> items = [];

  MBL_Text_Itemize(type: MBL_Text_Itemize_Type) {
    super();
    this.type = type;
  }

  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_Span extends MBL_Text {
  String type = 'span';
  List<MBL_Text> items = [];
  
  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }
  
  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

// TODO: aggregate next 3 classes into one!

class MBL_Text_AlignLeft extends MBL_Text {
  String type = 'align_left';
  List<MBL_Text> items = [];
  
  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }
  
  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_AlignCenter extends MBL_Text {
  String type = 'align_center';
  List<MBL_Text> items = [];
  
  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }
  
  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_AlignRight extends MBL_Text {
  String type = 'align_right';
  List<MBL_Text> items = [];
  
  void postProcess() {
    for(var i=0; i<this.items.length; i++) {
      var item = this.items[i];
      item.postProcess();
    }
    simplifyText(this.items);
  }
  
  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_Text extends MBL_Text {
  String type = 'text';
  String value = '';
  
  void postProcess() {
    /* empty */
  }
  
  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      value: this.value,
    };
  }
}

class MBL_Text_Linefeed extends MBL_Text {
  String type = 'linefeed';

  void postProcess() {
    /* empty */
  }

  Map<Object,Object> toJSON() {
      return {
      type: this.type,
    };
  }
}

class MBL_Text_Color extends MBL_Text {
  String type = 'color';
  int key = 0;
  List<MBL_Text> items = [];

  void postProcess() {
    simplifyText(this.items);
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      key: this.key,
      items: this.items.map((item) => item.toJSON()),
    };
  }
}

class MBL_Text_Reference extends MBL_Text {
  String type = 'reference';
  String label = '';

  void postProcess() {
    /* empty */
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      label: this.label,
    };
  }
}

class MBL_Text_Error extends MBL_Text {
  String type = 'error';
  String message = '';

  MBL_Text_Error(this.message);

  void postProcess() {
    /* empty */
  }

  Map<Object,Object> toJSON() {
    return {
      type: this.type,
      message: this.message,
    };
  }
}
