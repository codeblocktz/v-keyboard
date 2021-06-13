part of v_keyboard;

/// The default keyboard height. Can we overriden by passing
///  `height` argument to `VKeyboard` widget.
const double _virtualKeyboardDefaultHeight = 300;

const int _virtualKeyboardBackspaceEventPerioud = 250;

/// Virtual Keyboard widget.
class VKeyboard extends StatefulWidget {
  /// Keyboard Type: Should be inited in creation time.
  final VKeyboardType type;

  /// Callback for Key press event. Called with pressed `Key` object.
  final Function onKeyPress;

  /// Virtual keyboard height. Default is 300
  final double height;

  /// Color for key texts and icons.
  final Color textColor;

  /// Font size for keyboard keys.
  final double fontSize;

  /// The builder function will be called for each Key object.
  final Widget Function(BuildContext context, VKeyboardKey key)? builder;

  /// Set to true if you want only to show Caps letters.
  final bool alwaysCaps;

  VKeyboard(
      {Key? key,
      required this.type,
      required this.onKeyPress,
      this.builder,
      this.height = _virtualKeyboardDefaultHeight,
      this.textColor = Colors.black,
      this.fontSize = 14,
      this.alwaysCaps = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VKeyboardState();
  }
}

/// Holds the state for Virtual Keyboard class.
class _VKeyboardState extends State<VKeyboard> {
  late VKeyboardType type;
  late Function onKeyPress;
  // The builder function will be called for each Key object.
  Widget Function(BuildContext context, VKeyboardKey key)? builder;
  late double height;
  late Color textColor;
  late double fontSize;
  late bool alwaysCaps;
  // Text Style for keys.
  late TextStyle textStyle;

  // True if shift is enabled.
  bool isShiftEnabled = false;

  @override
  void didUpdateWidget(VKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      type = widget.type;
      onKeyPress = widget.onKeyPress;
      height = widget.height;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      alwaysCaps = widget.alwaysCaps;

      // Init the Text Style for keys.
      textStyle = TextStyle(
        fontSize: fontSize,
        color: textColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    type = widget.type;
    onKeyPress = widget.onKeyPress;
    height = widget.height;
    textColor = widget.textColor;
    fontSize = widget.fontSize;
    alwaysCaps = widget.alwaysCaps;

    // Init the Text Style for keys.
    textStyle = TextStyle(
      fontSize: fontSize,
      color: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == VKeyboardType.Numeric ? _numeric() : _alphanumeric();
  }

  Widget _alphanumeric() {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  Widget _numeric() {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  /// Returns the rows for keyboard.
  List<Widget> _rows() {
    // Get the keyboard Rows
    List<List<VKeyboardKey>> keyboardRows = type == VKeyboardType.Numeric
        ? _getKeyboardRowsNumeric()
        : _getKeyboardRows();

    // Generate keyboard row.
    List<Widget> rows = List.generate(keyboardRows.length, (int rowNum) {
      return Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Generate keboard keys
          children: List.generate(
            keyboardRows[rowNum].length,
            (int keyNum) {
              // Get the VKeyboardKey object.
              VKeyboardKey virtualKeyboardKey = keyboardRows[rowNum][keyNum];

              Widget keyWidget;

              // Check if builder is specified.
              // Call builder function if specified or use default
              //  Key widgets if not.
              if (builder == null) {
                // Check the key type.
                switch (virtualKeyboardKey.keyType) {
                  case VKeyboardKeyType.String:
                    // Draw String key.
                    keyWidget = _keyboardDefaultKey(virtualKeyboardKey);
                    break;
                  case VKeyboardKeyType.Action:
                    // Draw action key.
                    keyWidget = _keyboardDefaultActionKey(virtualKeyboardKey);
                    break;
                }
              } else {
                // Call the builder function, so the user can specify custom UI for keys.
                keyWidget = builder!(context, virtualKeyboardKey);

                // ignore: unnecessary_null_comparison
                if (keyWidget == null) {
                  throw 'builder function must return Widget';
                }
              }

              return keyWidget;
            },
          ),
        ),
      );
    });

    return rows;
  }

  // True if long press is enabled.
  late bool longPress;

  /// Creates default UI element for keyboard Key.
  Widget _keyboardDefaultKey(VKeyboardKey key) {
    return Expanded(
        child: InkWell(
      onTap: () {
        onKeyPress(key);
      },
      child: Container(
        height: height / _keyRows.length,
        child: Center(
            child: Text(
          alwaysCaps
              ? '${key.capsText}'
              : (isShiftEnabled ? '${key.capsText}' : '${key.text}'),
          style: textStyle,
        )),
      ),
    ));
  }

  /// Creates default UI element for keyboard Action Key.
  Widget _keyboardDefaultActionKey(VKeyboardKey key) {
    // Holds the action key widget.
    Widget actionKey;

    // Switch the action type to build action Key widget.
    switch (key.action) {
      case VKeyboardKeyAction.Backspace:
        actionKey = GestureDetector(
            onLongPress: () {
              longPress = true;
              // Start sending backspace key events while longPress is true
              Timer.periodic(
                  Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                  (timer) {
                if (longPress) {
                  onKeyPress(key);
                } else {
                  // Cancel timer.
                  timer.cancel();
                }
              });
            },
            onLongPressUp: () {
              // Cancel event loop
              longPress = false;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Icon(
                Icons.backspace,
                color: textColor,
              ),
            ));
        break;
      case VKeyboardKeyAction.Shift:
        actionKey = Icon(Icons.arrow_upward, color: textColor);
        break;
      case VKeyboardKeyAction.Space:
        actionKey = actionKey = Icon(Icons.space_bar, color: textColor);
        break;
      case VKeyboardKeyAction.Return:
        actionKey = Icon(
          Icons.keyboard_return,
          color: textColor,
        );
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          if (key.action == VKeyboardKeyAction.Shift) {
            if (!alwaysCaps) {
              setState(() {
                isShiftEnabled = !isShiftEnabled;
              });
            }
          }

          onKeyPress(key);
        },
        child: Container(
          alignment: Alignment.center,
          height: height / _keyRows.length,
          child: actionKey,
        ),
      ),
    );
  }
}
