import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An editable input field component with confirm/cancel actions.
///
/// States:
/// - [_EditState.empty]   → shows placeholder + "+" button to activate editing
/// - [_EditState.editing] → shows TextField + clear (—) + confirm (✓) + cancel (✗)
/// - [_EditState.filled]  → shows saved value + "+" button to re-edit
///
/// Usage:
/// ```dart
/// EditInputField(
///   label: 'เบอร์ฉุกเฉินลำดับ 1',
///   placeholder: '099-999-9999',
///   onSaved: (value) => print('Saved: $value'),
/// )
/// ```

enum _EditState { empty, editing, filled }

class EditInputField extends StatefulWidget {
  const EditInputField({
    super.key,
    required this.label,
    this.placeholder = 'เพิ่มเบอร์ที่นี่',
    this.initialValue,
    this.prefixText,
    this.keyboardType = TextInputType.phone,
    this.onSaved,
    this.onCancelled,
  });

  final String label;
  final String placeholder;
  final String? initialValue;
  final String? prefixText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onSaved;
  final VoidCallback? onCancelled;

  @override
  State<EditInputField> createState() => _EditInputFieldState();
}

class _EditInputFieldState extends State<EditInputField> {
  late _EditState _state;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String _savedValue = '';

  static const _borderRadius = BorderRadius.all(Radius.circular(12));
  static const _fieldHeight = 48.0;

  @override
  void initState() {
    super.initState();
    _savedValue = widget.initialValue ?? '';
    _state = _savedValue.isNotEmpty ? _EditState.filled : _EditState.empty;
    _controller = TextEditingController(text: _savedValue);
  }

  @override
  void didUpdateWidget(EditInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _savedValue = widget.initialValue ?? '';
      _controller.text = _savedValue;
      _state = _savedValue.isNotEmpty ? _EditState.filled : _EditState.empty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = _savedValue;
    setState(() => _state = _EditState.editing);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _confirmEdit() {
    final value = _controller.text.trim();
    setState(() {
      _savedValue = value;
      _state = value.isNotEmpty ? _EditState.filled : _EditState.empty;
    });
    _focusNode.unfocus();
    widget.onSaved?.call(value);
  }

  void _cancelEdit() {
    _controller.text = _savedValue;
    setState(
      () => _state = _savedValue.isNotEmpty
          ? _EditState.filled
          : _EditState.empty,
    );
    _focusNode.unfocus();
    widget.onCancelled?.call();
  }

  void _clearText() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppDisplayTextStyles.subtitleBold.copyWith(
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _state != _EditState.editing ? _startEditing : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _fieldHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.inputBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: _borderRadius,
                      side: BorderSide(
                        width: _state == _EditState.editing ? 1.5 : 1,
                        color: _state == _EditState.editing
                            ? AppColors.inputBorderFocus
                            : AppColors.inputBorder,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _state == _EditState.editing
                            ? TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: widget.keyboardType,
                                inputFormatters:
                                    widget.keyboardType == TextInputType.phone
                                    ? [PhoneNumberFormatter()]
                                    : [],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ).merge(AppBodyTextStyles.body),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  hintText: widget.placeholder,
                                ),
                              )
                            : Row(
                                children: [
                                  if ((widget.prefixText ?? '').isNotEmpty) ...[
                                    Text(
                                      widget.prefixText!,
                                      style: AppBodyTextStyles.body.copyWith(
                                        color: _state == _EditState.filled
                                            ? AppColors.textSupport
                                            : AppColors.textDisabled,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      _state == _EditState.filled
                                          ? _savedValue
                                          : widget.placeholder,
                                      style: AppBodyTextStyles.body.copyWith(
                                        color: _state == _EditState.filled
                                            ? AppColors.textPrimary
                                            : AppColors.inputPlaceholder,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      // (—) clear — editing state
                      if (_state == _EditState.editing)
                        GestureDetector(
                          onTap: _clearText,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      if (_state != _EditState.editing)
                        GestureDetector(
                          onTap: _startEditing,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // (✓)(✗) outside — editing state only
            if (_state == _EditState.editing) ...[
              const SizedBox(width: 8),
              _IconButton(
                color: AppColors.brandSecondary,
                icon: Icons.check,
                onTap: _confirmEdit,
              ),
              const SizedBox(width: 8),
              _IconButton(
                color: AppColors.error,
                icon: Icons.close,
                onTap: _cancelEdit,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  // ... (โค้ด _IconButton คงเดิม) ...
  const _IconButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: ShapeDecoration(
          color: color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        child: Center(
          child: Icon(icon, size: 16, color: AppColors.backgroundWhite),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // กรองเอามาเฉพาะตัวเลขล้วนๆ
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    // วนลูปจับยัดขีด '-' ทุกๆ 3 ตัวแรก และ 3 ตัวถัดมา
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '-';
      }
      formatted += text[i];
    }

    // ตัดความยาวไม่ให้เกิน 12 ตัวอักษร (เลข 10 + ขีด 2)
    if (formatted.length > 12) {
      formatted = formatted.substring(0, 12);
    }

    return TextEditingValue(
      text: formatted,
      // ดัน Cursor ไปไว้ขวาสุดเสมอเวลาพิมพ์
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
