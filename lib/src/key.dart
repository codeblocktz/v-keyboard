part of v_keyboard;

/// Virtual Keyboard key
class VKeyboardKey {
  final String? text;
  final String? capsText;
  final VKeyboardKeyType keyType;
  final VKeyboardKeyAction action;

  VKeyboardKey(
      {this.text,
      this.capsText,
      this.keyType = VKeyboardKeyType.Action,
      this.action = VKeyboardKeyAction.Backspace});
}
