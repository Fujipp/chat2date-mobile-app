import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'ds_text_field_helper.dart';
import 'ds_text_field_props.dart';

class DsTextField extends StatefulWidget {
  const DsTextField({
    super.key,
    this.label,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.supportText,
    this.controller,
    this.onSuffixTap,
    this.labelFontSize,
    this.inputFontSize,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
    this.state,
    this.showSupportText = false,
    this.showTitle = true,
    this.unit,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
  });

  final String? label;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final String? hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final String? supportText;
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap;
  final double? labelFontSize;
  final double? inputFontSize;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final DsInputVisualState? state;
  final bool showSupportText;
  final bool showTitle;
  final String? unit;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;

  @override
  State<DsTextField> createState() => _DsTextFieldState();
}

class _DsTextFieldState extends State<DsTextField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant DsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _controller.addListener(_handleControllerChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasLabel = (widget.label ?? '').isNotEmpty && widget.showTitle;
    final hasValue = _controller.text.trim().isNotEmpty;
    final effectiveState = DsTextFieldHelper.normalizeState(
      enabled: widget.enabled,
      hasFocus: _focusNode.hasFocus,
      hasError: widget.state == DsInputVisualState.error,
      hasValue: hasValue,
      explicitState: widget.state,
    );

    final labelStyle = DsTextFieldHelper.labelStyle(
      fontSize: widget.labelFontSize,
    );
    final inputStyle = DsTextFieldHelper.bodyStyle(
      state: effectiveState,
      fontSize: widget.inputFontSize,
    );
    final hintStyle = DsTextFieldHelper.hintStyle(
      state: effectiveState,
      fontSize: widget.inputFontSize,
    );

    final prefixWidget =
        widget.prefix ??
        (widget.unit != null
            ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(widget.unit!, style: hintStyle),
              )
            : null);

    final suffixWidget =
        widget.suffix ??
        (widget.suffixIcon != null
            ? IconButton(
                onPressed: widget.enabled ? widget.onSuffixTap : null,
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 20,
                  height: 20,
                ),
                icon: Icon(
                  widget.suffixIcon,
                  size: 16,
                  color: effectiveState == DsInputVisualState.error
                      ? AppColors.error
                      : AppColors.brandPrimary,
                ),
              )
            : null);

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: DsTextFieldHelper.fillColorForVisualState(effectiveState),
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: widget.hintText ?? '',
      hintStyle: hintStyle,
      prefixIcon: widget.prefixIcon != null
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              child: Icon(
                widget.prefixIcon,
                size: 18,
                color: DsTextFieldHelper.hintColorFor(effectiveState),
              ),
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefix: prefixWidget,
      suffixIcon: suffixWidget,
      enabledBorder: DsTextFieldHelper.borderForVisualState(effectiveState),
      focusedBorder: DsTextFieldHelper.borderForVisualState(effectiveState),
      disabledBorder: DsTextFieldHelper.borderForVisualState(
        DsInputVisualState.inactive,
      ),
      errorBorder: DsTextFieldHelper.borderForVisualState(
        DsInputVisualState.error,
      ),
      focusedErrorBorder: DsTextFieldHelper.borderForVisualState(
        DsInputVisualState.error,
      ),
      border: DsTextFieldHelper.borderForVisualState(effectiveState),
    );

    final textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: inputStyle,
      cursorColor: AppColors.brandPrimary,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      textInputAction: widget.textInputAction,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: decoration,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel)
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
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
        if (hasLabel) const SizedBox(height: 8),
        textField,
        if ((widget.showSupportText || widget.supportText != null) &&
            (widget.supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.supportText!,
            style: DsTextFieldHelper.supportStyle(effectiveState),
          ),
        ],
      ],
    );
  }
}
