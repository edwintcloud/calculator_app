//===================================================================
// File: main.dart
//
// Desc: Main entry point for application.
//
// Copyright © 2019 Edwin Cloud. All rights reserved.
//
// * Attribution to Tensor and his channel on YouTube at      *
// * https://www.youtube.com/channel/UCYqCZOwHbnPwyjawKfE21wg *
//===================================================================

//-------------------------------------------------------------------
// Imports
//-------------------------------------------------------------------
import 'package:flutter/material.dart';

//-------------------------------------------------------------------
// Global Constants
//-------------------------------------------------------------------
const DEBUG_BANNER = false;

//-------------------------------------------------------------------
// Main Entrypoint
//-------------------------------------------------------------------
void main() => runApp(MyApp());

//-------------------------------------------------------------------
// MyApp (Class) - StatelessWidget
//-------------------------------------------------------------------
class MyApp extends StatelessWidget {
  // build app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calculator",
      debugShowCheckedModeBanner: DEBUG_BANNER,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Calculator(),
    );
  }
}

//-------------------------------------------------------------------
// CalculatorLayout (Class) - StatelessWidget
//-------------------------------------------------------------------
class CalculatorLayout extends StatelessWidget {
  // build calculator
  @override
  Widget build(BuildContext context) {
    final mainState = MainState.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Text(
                    mainState.inputValue ?? '0', // if null return 0
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 48.0,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4, // proportionally expand
            child: Container(
              child: Column(
                children: <Widget>[
                  makeButtons('_%C⌫'),
                  makeButtons('789÷'),
                  makeButtons('456x'),
                  makeButtons('123-'),
                  makeButtons('0.=+'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // build calculator buttons for row
  Widget makeButtons(String row) {
    List<String> token = row.split("");
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: token
            .map((e) => CalculatorButton(
                  keyValue: e == "_" ? "+/-" : e,
                ))
            .toList(),
      ),
    );
  }
}

//-------------------------------------------------------------------
// Calculator (Class) - StatefulWidget
//-------------------------------------------------------------------
class Calculator extends StatefulWidget {
  // create CalculatorState
  @override
  CalculatorState createState() => CalculatorState();
}

//-------------------------------------------------------------------
// CalculatorState (Class) - State<Calculator>
//-------------------------------------------------------------------
class CalculatorState extends State<Calculator> {
  // class variables (State)
  String inputString = "";
  double prevValue;
  String value = "";
  String op = "z";

  // build CalculatorState as InheritedWidget MainState
  @override
  Widget build(BuildContext context) {
    return MainState(
      inputValue: inputString,
      prevValue: prevValue,
      value: value,
      op: op,
      onPressed: onPressed,
      child: CalculatorLayout(),
    );
  }

  // on button press handler
  void onPressed(String keyValue) {
    switch (keyValue) {
      case "C":
        op = null;
        prevValue = 0.0;
        value = "";
        setState(() => inputString = "");
        break;
      case ".":
        if (!inputString.contains(".")) {
          setState(() {
            inputString += ".";
          });
        }
        break;
      case "%":
      case "+/-":
        break;
      case "⌫":
        setState(() {
          inputString = inputString.substring(0, inputString.length - 1);
        });
        break;
      case "x":
      case "+":
      case "-":
      case "÷":
        op = keyValue;
        value = "";
        prevValue = double.parse(inputString);
        setState(() => inputString += " $keyValue ");
        break;
      case "=":
        if (op != null) {
          setState(() {
            switch (op) {
              case "x":
                inputString = normalizeDouble(prevValue * double.parse(value));
                break;
              case "+":
                inputString = normalizeDouble(prevValue + double.parse(value));
                break;
              case "-":
                inputString = normalizeDouble(prevValue - double.parse(value));
                break;
              case "÷":
                inputString = normalizeDouble(prevValue / double.parse(value));
                break;
            }
          });
        }
        op = null;
        prevValue = double.parse(inputString);
        value = "";
        break;
      default:
        double numKeyValue = double.tryParse(keyValue);
        if (numKeyValue != null) {
          setState(() => inputString += keyValue);
          value += keyValue;
        } else {
          op = "z";
          inputString = "";
          onPressed(keyValue);
        }
    }

    if (inputString.length > 13) {
      setState(() {
        inputString = inputString.substring(0, 13);
      });
    }
  }

  // normalize double into integer or truncated double string
  String normalizeDouble(double input) {
    if (input % 1 == 0) {
      return input.toStringAsFixed(0);
    } else {
      String result = input.toString();
      String intPortion = result.substring(0, result.lastIndexOf("."));
      String decimalPortion = result.substring(result.lastIndexOf("."));
      decimalPortion.replaceAll("0", "");
      if (decimalPortion.length > 5)
        decimalPortion = decimalPortion.substring(0, 5);
      return intPortion + decimalPortion;
    }
  }
}

//-------------------------------------------------------------------
// MainState (Class) - InheritedWidget
//-------------------------------------------------------------------
class MainState extends InheritedWidget {
  // constructor
  MainState({
    Key key,
    this.inputValue,
    this.prevValue,
    this.value,
    this.op,
    this.onPressed,
    Widget child,
  }) : super(key: key, child: child);

  // class variables (State)
  final String inputValue;
  final double prevValue;
  final String value;
  final String op;
  final Function onPressed;

  // condition for when the widgets should re-render
  @override
  bool updateShouldNotify(MainState oldWidget) {
    return inputValue != oldWidget.inputValue;
  }

  // method to get instance of MainState from other classes
  static MainState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MainState);
  }
}

//-------------------------------------------------------------------
// CalculatorButton (Class) - StatelessWidget
//-------------------------------------------------------------------
class CalculatorButton extends StatelessWidget {
  // constructor
  CalculatorButton({this.keyValue});

  // class variables
  final String keyValue;

  // build calculator button
  @override
  Widget build(BuildContext context) {
    final mainState = MainState.of(context);
    return Expanded(
      flex: 1,
      child: FlatButton(
        shape: Border.fromBorderSide(BorderSide(
          color: Colors.deepPurple.withOpacity(0.3),
          width: 0.3,
        )),
        color: Colors.deepPurple.withOpacity(0.1),
        child: Text(
          keyValue,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 36.0,
            color: Colors.black,
            fontStyle: FontStyle.normal,
          ),
        ),
        onPressed: () {
          mainState.onPressed(keyValue);
        },
      ),
    );
  }
}
