import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class CalculatorModel extends ChangeNotifier {
  String _userInput = '';
  String _answer = '0';
  bool _isDarkTheme = true;
  double _answerFontSize = 30.0;

  String get userInput => _userInput;
  String get answer => _answer;
  bool get isDarkTheme => _isDarkTheme;
  double get answerFontSize => _answerFontSize;

  void addToInput(String value) {
    _userInput += value;
    calculateResult();
    notifyListeners();
  }

  void clearInput() {
    _userInput = '';
    _answer = '0';
    notifyListeners();
  }

  void deleteLast() {
    if (_userInput.isNotEmpty) {
      _userInput = _userInput.substring(0, _userInput.length - 1);
      calculateResult();
      notifyListeners();
    }
  }

  void toggleNegative() {
    if (_userInput.isNotEmpty) {
      if (_userInput[0] == '-') {
        _userInput = _userInput.substring(1);
      } else {
        _userInput = '-' + _userInput;
      }
      calculateResult();
      notifyListeners();
    }
  }

  void calculateResult() {
    if (_userInput.isNotEmpty) {
      String finalUserInput = _userInput.replaceAll('x', '*');

      Parser p = Parser();
      Expression exp;

      try {
        exp = p.parse(finalUserInput);
      } catch (e) {
        return;
      }

      ContextModel cm = ContextModel();
      double eval;

      try {
        eval = exp.evaluate(EvaluationType.REAL, cm);
      } catch (e) {
        return;
      }

      _answer = eval.toString();
      notifyListeners();
    }
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  void increaseFontSize() {
    _answerFontSize += 5.0;

    _answerFontSize >= 40.0;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorModel(),
      child: Consumer<CalculatorModel>(
        builder: (context, model, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomePage(),
            theme: model.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<List<String>> buttons = [
    ['C', '+/-', '%', 'DEL'],
    ['7', '8', '9', '/'],
    ['4', '5', '6', 'x'],
    ['1', '2', '3', '-'],
    ['0', '.', '=', '+'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: CalculatorDisplay(),
          ),
          Expanded(
            flex: 3,
            child: CalculatorButtons(buttons: buttons),
          ),
        ],
      ),
    );
  }
}

class CalculatorDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Consumer<CalculatorModel>(
              builder: (context, model, child) {
                return Text(
                  model.userInput,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.centerRight,
            child: Consumer<CalculatorModel>(
              builder: (context, model, child) {
                return Text(
                  model.answer,
                  style: TextStyle(
                    fontSize: model.answerFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorButtons extends StatelessWidget {
  final List<List<String>> buttons;

  CalculatorButtons({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        itemCount: buttons.length * buttons[0].length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: buttons[0].length,
        ),
        itemBuilder: (BuildContext context, int index) {
          final row = index ~/ buttons[0].length;
          final col = index % buttons[0].length;
          return CalculatorButton(buttons[row][col]);
        },
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String buttonText;

  CalculatorButton(this.buttonText);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorModel>(
      builder: (context, model, child) {
        return GestureDetector(
          onTap: () {
            handleButtonTap(context, model);
          },
          child: Container(
            decoration: BoxDecoration(
              color: getButtonColor(model.isDarkTheme),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(10),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getButtonTextColor(model.isDarkTheme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void handleButtonTap(BuildContext context, CalculatorModel model) {
    if (buttonText == 'C') {
      model.clearInput();
    } else if (buttonText == '+/-') {
      model.toggleNegative();
    } else if (buttonText == 'DEL') {
      model.deleteLast();
    } else if (buttonText == '=') {
      model.calculateResult();
      model.increaseFontSize();
    } else {
      model.addToInput(buttonText);
    }
  }

  Color getButtonColor(bool isDarkTheme) {
    if (buttonText == '=') {
      return Colors.orange[700]!;
    } else if (buttonText == '/' ||
        buttonText == 'x' ||
        buttonText == '-' ||
        buttonText == '+') {
      return isDarkTheme ? Colors.grey[800]! : Colors.grey[200]!;
    } else {
      return isDarkTheme ? Colors.grey[900]! : Colors.grey[300]!;
    }
  }

  Color getButtonTextColor(bool isDarkTheme) {
    return buttonText == '/' ||
            buttonText == 'x' ||
            buttonText == '-' ||
            buttonText == '+' ||
            buttonText == '='
        ? Colors.white
        : isDarkTheme
            ? Colors.white
            : Colors.black;
  }
}

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorModel>(
      builder: (context, model, child) {
        return IconButton(
          icon: Icon(model.isDarkTheme ? Icons.brightness_7 : Icons.brightness_3),
          onPressed: () {
            model.toggleTheme();
          },
        );
      },
    );
  }
}
