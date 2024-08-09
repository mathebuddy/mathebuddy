/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre

library mathe_buddy_app;

var chatDatabaseSrc = """
@@greetings
  @en
    How can I help you? Give me a keyword or click on one of the red buttons.
  @de
    Wie kann ich Dir helfen? Nenne mir ein STICHWORT, oder klicke auf einen der roten Buttons.

@@likeExercise
  @en
    I would like to exercise
  @de
    Ich möchte trainieren

@@likeAnotherExercise
  @en
    next exercise
  @de
    nächste Aufgabe

@@noExercises
  @en
    Unfortunately, I can't recommend a task at the moment. You should go forward in the chapters...
  @de
    Aktuell kann ich Dir leider keine Aufgabe empfehlen. Schreite zunächst in den Kapiteln weiter voran...

@@hereExercise
  @en
    Here is an exercise from chapter \"@0\":
  @de
    Hier eine Aufgabe aus dem Kapitel \"@0\":

@@similarKeywords
  @en
    Similar keywords:
  @de
    Ähnliche Begriffe:
""";

Map<String, String> chatDatabase = {};

String getChatText(String id, String languageId, List<String> placeholders) {
  if (chatDatabase.keys.isEmpty) {
    var lines = chatDatabaseSrc.split("\n");
    var kw = "";
    var lang = "";
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith("@@")) {
        kw = line.substring(2);
      } else if (line.startsWith("@")) {
        lang = line.substring(1);
      } else {
        chatDatabase["${kw}_$lang"] = line;
      }
    }
  }
  var query = "${id}_$languageId";
  if (chatDatabase.containsKey(query)) {
    var res = chatDatabase[query]!;
    for (var i = 0; i < placeholders.length; i++) {
      res = res.replaceAll("@$i", placeholders[i]);
    }
    return res;
  }
  return ""; // TODO
}
