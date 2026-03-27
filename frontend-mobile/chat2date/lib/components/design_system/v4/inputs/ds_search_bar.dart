import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'ds_text_field_helper.dart';
import 'ds_text_field_props.dart';

class DsSearchBar extends StatefulWidget {
  const DsSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.state,
    this.width = 311,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final DsInputVisualState? state;
  final double width;
  final bool enabled;

  @override
  State<DsSearchBar> createState() => _DsSearchBarState();
}

class _DsSearchBarState extends State<DsSearchBar> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChanged);
    _focusNode.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant DsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleChanged);
      _controller.addListener(_handleChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleChanged);
      _focusNode.addListener(_handleChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _focusNode.removeListener(_handleChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _controller.text.trim().isNotEmpty;
    final effectiveState = DsTextFieldHelper.normalizeState(
      enabled: widget.enabled,
      hasFocus: _focusNode.hasFocus,
      hasError: false,
      hasValue: hasValue,
      explicitState: widget.state,
    );

    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        style: DsTextFieldHelper.bodyStyle(state: effectiveState),
        cursorColor: AppColors.brandPrimary,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.inputBg,
          hintText: widget.hintText,
          hintStyle: DsTextFieldHelper.hintStyle(state: effectiveState),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textBlack,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
        ),
      ),
    );
  }
}
