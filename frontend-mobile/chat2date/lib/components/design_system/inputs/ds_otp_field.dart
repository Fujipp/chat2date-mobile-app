import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DsOtpField extends StatefulWidget {
  const DsOtpField({
    super.key,
    this.length = 6,
    required this.label,
    this.required = false,
    this.supportText,
    this.autoFocus = false,
    this.obscure = false,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final String label;
  final bool required;
  final String? supportText;
  final bool autoFocus;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<DsOtpField> createState() => _DsOtpFieldState();
}

class _DsOtpFieldState extends State<DsOtpField> {
  static const _frameWidth = 295.0;
  static const _fieldWidth = 290.0;
  static const _fieldHeight = 48.0;
  static const _fieldRadius = 8.23;
  static const _boxWidth = 39.11;
  static const _boxHeight = 40.49;
  static const _boxRadius = 13.72;
  static const _boxSpacing = 9.61;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int? _selectedIndex;
  bool _replaceMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _notify(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  void _focusAt(int index) {
    final text = _controller.text;
    final safeIndex = index.clamp(0, widget.length - 1);
    final target = safeIndex.clamp(0, text.length);

    TextSelection selection;
    if (safeIndex < text.length) {
      selection = TextSelection(baseOffset: safeIndex, extentOffset: safeIndex + 1);
      _replaceMode = true;
    } else {
      selection = TextSelection.collapsed(offset: target);
      _replaceMode = false;
    }

    _selectedIndex = safeIndex;
    _focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.selection = selection;
    });
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    final text = _controller.text;
    if (text.isEmpty) {
      return KeyEventResult.handled;
    }

    final selection = _controller.selection;
    final hasRange = selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start != selection.end;

    if (hasRange) {
      final start = selection.start.clamp(0, text.length);
      final end = selection.end.clamp(0, text.length);
      final updated = text.replaceRange(start, end, '');
      _controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: start),
      );
      _selectedIndex = start > 0 ? start - 1 : 0;
      _replaceMode = false;
    } else {
      final cursor = selection.baseOffset < 0 ? text.length : selection.baseOffset;
      final removeIndex = cursor > 0 ? cursor - 1 : text.length - 1;
      final updated = text.replaceRange(removeIndex, removeIndex + 1, '');
      _controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: removeIndex),
      );
      _selectedIndex = removeIndex > 0 ? removeIndex - 1 : 0;
      _replaceMode = false;
    }

    setState(() {});
    _notify(_controller.text);
    return KeyEventResult.handled;
  }

  int get _activeIndex {
    if (!_focusNode.hasFocus) return -1;
    if (_selectedIndex != null) {
      return _selectedIndex!.clamp(0, widget.length - 1);
    }
    final base = _controller.selection.baseOffset;
    if (base < 0) return 0;
    if (base >= widget.length) return widget.length - 1;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.text;
    final chars = value.split('');

    return SizedBox(
      width: _frameWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppDisplayTextStyles.subtitleBold.copyWith(
                color: AppColors.textBlack,
              ),
              children: widget.required
                  ? const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: _fieldWidth,
            height: _fieldHeight,
            child: Focus(
              onKeyEvent: _handleKeyEvent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: widget.autoFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      obscureText: false,
                      enableSuggestions: false,
                      autocorrect: false,
                      showCursor: false,
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontSize: 1,
                        height: 1,
                      ),
                      cursorColor: Colors.transparent,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_fieldRadius),
                          borderSide: const BorderSide(color: AppColors.background),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_fieldRadius),
                          borderSide: const BorderSide(color: AppColors.background),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_fieldRadius),
                          borderSide: const BorderSide(color: AppColors.background),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(widget.length),
                      ],
                      onChanged: (text) {
                        final replaceIndex = _replaceMode ? _selectedIndex : null;

                        if (replaceIndex != null && replaceIndex + 1 < text.length) {
                          final nextIndex = replaceIndex + 1;
                          _selectedIndex = nextIndex;
                          _replaceMode = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            _controller.selection = TextSelection(
                              baseOffset: nextIndex,
                              extentOffset: nextIndex + 1,
                            );
                          });
                        } else {
                          _selectedIndex = null;
                          _replaceMode = false;
                        }

                        setState(() {});
                        _notify(text);
                      },
                      onTapOutside: (_) => _focusNode.unfocus(),
                      onSubmitted: (_) => _focusNode.unfocus(),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _focusAt(chars.length),
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: _fieldWidth,
                        height: _fieldHeight,
                        padding: const EdgeInsets.symmetric(vertical: 8.23),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: AppColors.background),
                            borderRadius: BorderRadius.circular(_fieldRadius),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.length, (index) {
                      final char = index < chars.length ? chars[index] : '';
                      final isActive = _activeIndex == index;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == widget.length - 1 ? 0 : _boxSpacing,
                        ),
                        child: GestureDetector(
                          onTap: () => _focusAt(index),
                          child: Container(
                            width: _boxWidth,
                            height: _boxHeight,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: AppColors.inputBg,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1.37,
                                  color: isActive
                                      ? AppColors.inputBorderFocus
                                      : AppColors.inputBorder,
                                ),
                                borderRadius: BorderRadius.circular(_boxRadius),
                              ),
                            ),
                            child: Text(
                              widget.obscure && char.isNotEmpty ? '*' : char,
                              style: AppBodyTextStyles.bodyBold.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          if (widget.supportText != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: _frameWidth,
              child: Text(
                widget.supportText!,
                style: AppBodyTextStyles.helper.copyWith(
                  color: AppColors.textSupport,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
