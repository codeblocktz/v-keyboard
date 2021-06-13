import 'package:flutter/material.dart';
import 'package:v_keyboard/v_keyboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V Keyboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'V Keyboard Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Holds the text that user typed.
  String text = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              text,
              style: Theme.of(context).textTheme.display1,
            ),
            SwitchListTile(
              title: Text(
                'Keyboard Type = ' +
                    (isNumericMode
                        ? 'VKeyboardType.Numeric'
                        : 'VKeyboardType.Alphanumeric'),
              ),
              value: isNumericMode,
              onChanged: (val) {
                setState(() {
                  isNumericMode = val;
                });
              },
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              color: Colors.deepPurple,
              child: VKeyboard(
                  height: 300,
                  textColor: Colors.white,
                  type: isNumericMode
                      ? VKeyboardType.Numeric
                      : VKeyboardType.Alphanumeric,
                  onKeyPress: _onKeyPress),
            )
          ],
        ),
      ),
    );
  }

  /// Fired when the V keyboard key is pressed.
  _onKeyPress(VKeyboardKey key) {
    if (key.keyType == VKeyboardKeyType.String) {
      text = text + (shiftEnabled ? '${key.capsText}' : '${key.text}');
    } else if (key.keyType == VKeyboardKeyType.Action) {
      switch (key.action) {
        case VKeyboardKeyAction.Backspace:
          if (text.length == 0) return;
          text = text.substring(0, text.length - 1);
          break;
        case VKeyboardKeyAction.Return:
          text = text + '\n';
          break;
        case VKeyboardKeyAction.Space:
          text = text + '${key.text}';
          break;
        case VKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;
        default:
      }
    }
    // Update the screen
    setState(() {});
  }
}
