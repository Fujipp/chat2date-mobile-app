import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DsChatMessageInput extends StatefulWidget {
  const DsChatMessageInput({
    super.key,
    this.controller,
    this.hintText = 'เขียนข้อความ',
    this.disabledText = 'ไม่สามารถส่งข้อความได้เนื่องจากมีการรายงาน',
    this.enabled = true,
    this.onChanged,
    this.onSend,
    this.autofocus = false,
    this.width = 390,
  });

  final TextEditingController? controller;
  final String hintText;
  final String disabledText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSend;
  final bool autofocus;
  final double width;

  @override
  State<DsChatMessageInput> createState() => _DsChatMessageInputState();
}

class _DsChatMessageInputState extends State<DsChatMessageInput> {
  late TextEditingController _internalController;
  final FocusNode _focusNode = FocusNode();
  bool _sendPressed = false;

  TextEditingController get _controller => widget.controller ?? _internalController;
  bool get _hasText => _controller.text.trim().isNotEmpty;
  bool get _showSend => widget.enabled && _hasText;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant DsChatMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.removeListener(_handleTextChanged);
      } else {
        _internalController.removeListener(_handleTextChanged);
      }

      if (widget.controller != null) {
        widget.controller!.addListener(_handleTextChanged);
      } else {
        _internalController.addListener(_handleTextChanged);
      }
      setState(() {});
    }
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_handleTextChanged);
    } else {
      _internalController.removeListener(_handleTextChanged);
    }
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _internalController.dispose();
    super.dispose();
  }

  void _send() {
    if (!_showSend) return;
    widget.onSend?.call();
  }

  int _estimateLineCount(double maxWidth, TextStyle style) {
    if (!widget.enabled) return 1;

    final text = _controller.text.isEmpty ? widget.hintText : _controller.text;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 5,
    )..layout(maxWidth: maxWidth);

    final lines = painter.computeLineMetrics().length;
    return lines.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.enabled && _focusNode.hasFocus
        ? AppColors.brandPrimary
        : AppColors.inputBorder;
    final fillColor = widget.enabled ? AppColors.background : AppColors.inputDisabledBg;
    final textColor = widget.enabled ? AppColors.textBlack : AppColors.textDisabled;
    final hintColor = widget.enabled ? AppColors.textPlaceholder : AppColors.textDisabled;
    final horizontalPadding = widget.enabled
        ? (_showSend ? 6.0 : 16.0)
        : 6.0;

    return SizedBox(
      width: widget.width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveWidth = constraints.maxWidth == double.infinity
              ? widget.width
              : constraints.maxWidth;
          final sendAreaWidth = _showSend ? 12 + 32 : 0;
          final textMaxWidth =
              effectiveWidth - 16 - horizontalPadding - sendAreaWidth;
          final bodyStyle = AppBodyTextStyles.body.copyWith(color: textColor);
          final lineCount = _estimateLineCount(textMaxWidth, bodyStyle);
          final displayLines = lineCount.clamp(1, 5);
          final height = 40.0 + (displayLines - 1) * 20.0;
          final borderRadius = displayLines > 1 ? 28.0 : 71.0;

          return AnimatedSize(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                height: height,
                padding: EdgeInsets.only(
                  top: 8,
                  left: 16,
                  right: horizontalPadding,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: widget.enabled
                          ? TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              enabled: true,
                              autofocus: widget.autofocus,
                              onChanged: widget.onChanged,
                              minLines: 1,
                              maxLines: 5,
                              maxLength: 2000,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              style: bodyStyle,
                              cursorColor: AppColors.brandPrimary,
                              scrollPhysics: const BouncingScrollPhysics(),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                isDense: true,
                                filled: false,
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                hintText: widget.hintText,
                                hintStyle: AppBodyTextStyles.body.copyWith(
                                  color: hintColor,
                                ),
                              ),
                            )
                          : Text(
                              widget.disabledText,
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                              style: AppBodyTextStyles.body.copyWith(
                                color: hintColor,
                              ),
                            ),
                    ),
                    if (_showSend) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTapDown: (_) => setState(() => _sendPressed = true),
                        onTapUp: (_) => setState(() => _sendPressed = false),
                        onTapCancel: () => setState(() => _sendPressed = false),
                        onTap: _send,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          offset: _sendPressed ? const Offset(0, -0.06) : Offset.zero,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            scale: _sendPressed ? 1.04 : 1,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppAssets.sendIcon,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
