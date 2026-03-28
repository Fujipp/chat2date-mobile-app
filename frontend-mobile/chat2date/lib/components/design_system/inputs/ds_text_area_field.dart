import 'package:flutter/material.dart';

import 'ds_text_field.dart';
import 'ds_text_field_props.dart';

class DsTextAreaField extends StatelessWidget {
  const DsTextAreaField({
    super.key,
    this.label,
    this.required = false,
    this.enabled = true,
    this.hintText,
    this.supportText,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.state,
    this.showSupportText = false,
    this.minLines = 3,
    this.maxLines = 3,
  });

  final String? label;
  final bool required;
  final bool enabled;
  final String? hintText;
  final String? supportText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final DsInputVisualState? state;
  final bool showSupportText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      label: label,
      required: required,
      enabled: enabled,
      hintText: hintText,
      supportText: supportText,
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      state: state,
      showSupportText: showSupportText,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: TextInputAction.newline,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
