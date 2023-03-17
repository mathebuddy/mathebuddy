/// mathe:buddy - a gamified learning-app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'dart:math';

import '../../math-runtime/src/parse.dart' as math_parser;
import '../../math-runtime/src/operand.dart' as math_operand;

class Chat {
  /// The history of previous messages.
  /// Prefixes: 'B' := mathe buddy bot, 'U' := user/student.
  final List<String> _history = [
    'B:Hallo! Gerne bin ich Dir behilflich beim Trainieren, '
        'erkläre Dir Begriffe oder rechne.',
  ];
  final Map<String, math_operand.Operand> _variableScope = {};

  void chat(String message) {
    message = message.trim();
    pushUserMessage(message);
    message = message.toLowerCase();
    // empty
    if (message.isEmpty) {
      var answers = [
        'Du musst auch etwas schreiben, wenn ich Dir helfen soll!',
        '?',
        'Sag was!'
      ];
      var idx = Random().nextInt(answers.length);
      pushBotMessage(answers[idx]);
      return;
    }
    // ...
    if (['fuck', 'idiot', 'dumm'].contains(message)) {
      var answers = ['...', 'Nicht nett.', 'Lass das!'];
      var idx = Random().nextInt(answers.length);
      pushBotMessage(answers[idx]);
      return;
    }
    // try to evaluate string
    var p = math_parser.Parser();
    try {
      String variableId = '';
      var tmp = message.replaceAll(' ', '');
      if (tmp.length > 2 && tmp[1] == '=') {
        variableId = tmp[0];
        message = message.split('=').sublist(1).join('=');
      }
      var term = p.parse(message);
      var value = term.eval(_variableScope);
      var valueTeX = value; // TODO!
      var answer = '\$$valueTeX\$'; // embed into TeX string
      if (variableId.isNotEmpty) {
        _variableScope[variableId] = value;
        answer = 'Merke mir den Wert $answer für Variable \$$variableId\$.';
      }
      pushBotMessage(answer);
      return;
    } catch (e) {
      print("[debug info: $e]");
      if (e.toString().contains("eval(..): unset variable")) {
        pushBotMessage('Leider sind mir nicht alle Variablen bekannt.');
        return;
      }
    }
    // misc
    if (message.contains('geht') && message.endsWith('?')) {
      pushBotMessage('Danke, mir geht es gut!');
      return;
    } else {
      pushBotMessage('Leider verstehe ich Deine Eingabe nicht.');
      return;
    }
  }

  void pushBotMessage(String message) {
    _history.add('B:$message');
  }

  void pushUserMessage(String message) {
    _history.add('U:$message');
  }

  List<String> getChatHistory() {
    return _history;
  }
}

// TODO: remove the following code, when migrated

/*
import * as mathjs from 'mathjs';

import {
    PartQuestion,
    QuestionVariable,
    QuestionVariableType,
} from './partQuestion';

enum ChatQuestionEval {
    Correct,
    Incorrect,
    SyntaxError,
}

class ChatQuestion extends PartQuestion {
    chapter = '';
    evaluate(message: string): ChatQuestionEval {
        const answerVariable = this.inputFields[0].answerVariable;
        const sampleSolution = answerVariable.toMathJs(this.variantIdx);
        let userSolution: mathjs.MathType;
        let result = ChatQuestionEval.Correct;
        switch (answerVariable.type) {
            case QuestionVariableType.Complex:
                try {
                    userSolution = mathjs.complex(message); // TODO: error handling!!
                } catch (error) {
                    result = ChatQuestionEval.SyntaxError;
                }
                if (result != ChatQuestionEval.SyntaxError) {
                    if (
                        (mathjs.abs(
                            <mathjs.Complex>(
                                mathjs.subtract(sampleSolution, userSolution)
                            ),
                        ) as any) > 1e-6
                    )
                        result = ChatQuestionEval.Incorrect;
                }
                break;
            default:
                console.assert(
                    false,
                    'unimplemented QuestionInputField: ' +
                        'evaluateChatQuestion() for type ' +
                        answerVariable.type,
                );
        }
        return result;
    }
}

export class Chat {
    // history prefixes: 'B' := chat bot, 'U' := user.
    private history: string[] = [
        'B:Hallo! Gerne bin ich Dir behilflich beim Trainieren, erkläre Dir Begriffe oder rechne.',
    ];
    private mathScope = {};
    private questions: ChatQuestion[] = [];
    private activeQuestionIdx = -1;
    private activeQuestionTry = 0;
    constructor() {
        //
    }
    pushBotMessage(msg: string) {
        this.history.push('B:' + msg);
    }
    pushUserMessage(msg: string) {
        this.history.push('U:' + msg);
    }
    getChatHistory(): string[] {
        return this.history;
    }
    triggerQuestion(): boolean {
        this.activeQuestionTry = 0;
        // TODO: question must depend on current learning progress
        if (this.questions.length == 0) return false;
        this.activeQuestionIdx = Math.floor(
            Math.random() * this.questions.length,
        );
        const question = this.questions[this.activeQuestionIdx];
        const msg = question.generateText(question.questionText);
        this.pushBotMessage(msg);
        return true;
    }
    chat(message: string): void {
        message = message.trim();
        this.pushUserMessage(message);
        if (this.activeQuestionIdx >= 0) {
            const question = this.questions[this.activeQuestionIdx];
            const result = question.evaluate(message);
            switch (result) {
                case ChatQuestionEval.Correct:
                    if (this.activeQuestionTry == 0)
                        this.pushBotMessage('Gut gemacht!');
                    else this.pushBotMessage('Jetzt ist es richtig!');
                    this.activeQuestionIdx = -1;
                    break;
                case ChatQuestionEval.Incorrect:
                    this.pushBotMessage(
                        'Leider nicht korrekt. ' +
                            question.generateText(question.solutionText),
                    );
                    this.activeQuestionTry++;
                    break;
                case ChatQuestionEval.SyntaxError:
                    this.pushBotMessage('Deine Eingabe enthält Fehler.');
                    this.activeQuestionTry++;
                    break;
                default:
                    console.assert(
                        false,
                        'unimplemented chat(): ChatQuestionEval type' + result,
                    );
            }
            return;
        }
        if (message.toLowerCase().includes('train')) {
            this.triggerQuestion();
            return;
        }
        message = message.toLowerCase();
        let answer = '';
        try {
            answer = mathjs.evaluate(message, this.mathScope);
            const tmp = message.replace('/ /g', ''); // remove spaces
            if (tmp.length > 2 && tmp[1] == '=') answer = 'Merke ich mir!';
        } catch (error) {
            const errStr = error.toString();
            if (errStr.startsWith('Error: Undefined symbol')) {
                const sym = errStr
                    .substring('Error: Undefined symbol'.length)
                    .trim();
                if (sym.length == 1)
                    answer = 'Tut mir leid, ' + sym + ' ist mir nicht bekannt!';
                else {
                    // otherwise: non-math symbol
                }
            } else {
                console.log(errStr);
            }
        }
        if (answer.length == 0) {
            if (message.includes('geht') && message.endsWith('?'))
                answer = 'Danke, mir geht es gut!';
            else if (message.includes('normalform'))
                answer =
                    'Sei z ∈ C. Dann ist z = x + yi die Normalform von z und x, y ∈ R sind die kartesischen Koordinaten von z.';
            else answer = 'Leider verstehe ich Deine Eingabe nicht.';
        }
        this.pushBotMessage(answer);
    }
    import(data: any): void {
        for (const question of data['questions']) {
            const questionInstance = new ChatQuestion(null);
            questionInstance.import(question);
            questionInstance.chatMode = true;
            questionInstance.chapter = question['chapter'];
            this.questions.push(questionInstance);
        }
    }
}
*/
