import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IosThemedChatTextView extends StatefulWidget {
  const IosThemedChatTextView({
    super.key,
    required this.controller,
    required this.hintText,
    required this.textStyle,
    required this.hintColor,
    required this.cursorColor,
    required this.selectionColor,
    required this.onChanged,
    required this.onFocusChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextStyle textStyle;
  final Color hintColor;
  final Color cursorColor;
  final Color selectionColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChanged;
  final bool autofocus;

  static Future<void> dismissActiveKeyboard() =>
      _IosThemedChatTextViewState.dismissActiveKeyboard();

  @override
  State<IosThemedChatTextView> createState() => _IosThemedChatTextViewState();
}

class _IosThemedChatTextViewState extends State<IosThemedChatTextView> {
  static MethodChannel? _activeChannel;

  static Future<void> dismissActiveKeyboard() async {
    await _activeChannel?.invokeMethod<void>('clearFocus');
  }

  MethodChannel? _channel;
  String _lastNativeText = '';

  @override
  void initState() {
    super.initState();
    _lastNativeText = widget.controller.text;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    if (identical(_activeChannel, _channel)) {
      _activeChannel = null;
    }
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _handleControllerChanged() {
    final text = widget.controller.text;
    if (text == _lastNativeText) return;
    _lastNativeText = text;
    _channel?.invokeMethod<void>('setText', text);
  }

  Future<void> _handlePlatformCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final text = (call.arguments as String?) ?? '';
        if (text == widget.controller.text) {
          _lastNativeText = text;
          return;
        }
        _lastNativeText = text;
        widget.controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        widget.onChanged?.call(text);
        return;
      case 'focusChanged':
        widget.onFocusChanged?.call(call.arguments == true);
        return;
      default:
        return;
    }
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('chat2date/ios-themed-text-view/$id');
    _channel = channel;
    _activeChannel = channel;
    channel.setMethodCallHandler(_handlePlatformCall);
    channel.invokeMethod<void>('setText', widget.controller.text);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        channel.invokeMethod<void>('requestFocus');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'chat2date/ios-themed-text-view',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: {
        'text': widget.controller.text,
        'hintText': widget.hintText,
        'fontSize': widget.textStyle.fontSize ?? 14.0,
        'fontFamily': widget.textStyle.fontFamily ?? 'Inter',
        'textColor': widget.textStyle.color?.toARGB32() ?? Colors.black.toARGB32(),
        'hintColor': widget.hintColor.toARGB32(),
        'cursorColor': widget.cursorColor.toARGB32(),
        'selectionColor': widget.selectionColor.toARGB32(),
      },
    );
  }
}
