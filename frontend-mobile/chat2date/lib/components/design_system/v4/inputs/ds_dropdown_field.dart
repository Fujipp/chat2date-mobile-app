import 'package:chat2date/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'ds_text_field_helper.dart';
import 'ds_text_field_props.dart';

class DsDropdownItem<T> {
  const DsDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

class DsDropdownField<T> extends StatefulWidget {
  const DsDropdownField({
    super.key,
    required this.items,
    this.label,
    this.required = false,
    this.value,
    this.onChanged,
    this.hintText = 'Placeholder',
    this.supportText,
    this.showSupportText = false,
    this.enabled = true,
    this.state,
  });

  final List<DsDropdownItem<T>> items;
  final String? label;
  final bool required;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final String? supportText;
  final bool showSupportText;
  final bool enabled;
  final DsInputVisualState? state;

  @override
  State<DsDropdownField<T>> createState() => _DsDropdownFieldState<T>();
}

class _DsDropdownFieldState<T> extends State<DsDropdownField<T>> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;
    final effectiveState = DsTextFieldHelper.normalizeState(
      enabled: widget.enabled,
      hasFocus: _focusNode.hasFocus,
      hasError: widget.state == DsInputVisualState.error,
      hasValue: hasValue,
      explicitState: widget.state,
    );

    final iconTurns = effectiveState == DsInputVisualState.typing ? 0.5 : 0.0;
    final iconColor = switch (effectiveState) {
      DsInputVisualState.error => DsTextFieldHelper.borderColorFor(
        effectiveState,
      ),
      DsInputVisualState.inactive => DsTextFieldHelper.borderColorFor(
        effectiveState,
      ),
      DsInputVisualState.empty => DsTextFieldHelper.borderColorFor(
        DsInputVisualState.typing,
      ),
      DsInputVisualState.typing => DsTextFieldHelper.borderColorFor(
        effectiveState,
      ),
      DsInputVisualState.filled => DsTextFieldHelper.borderColorFor(
        DsInputVisualState.typing,
      ),
    };
    final dropdownIcon = Padding(
      padding: const EdgeInsets.only(right: 16),
      child: DsTextFieldHelper.buildSvgIcon(
        AppAssets.v4InputDropdownIcon,
        size: 12,
        color: iconColor,
        turns: iconTurns,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((widget.label ?? '').isNotEmpty)
          RichText(
            text: TextSpan(
              text: widget.label,
              style: DsTextFieldHelper.labelStyle(),
              children: widget.required
                  ? const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                    ]
                  : null,
            ),
          ),
        if ((widget.label ?? '').isNotEmpty) const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField<T>(
            initialValue: widget.value,
            focusNode: _focusNode,
            onChanged: widget.enabled ? widget.onChanged : null,
            icon: dropdownIcon,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: DsTextFieldHelper.fillColorForVisualState(
                effectiveState,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: DsTextFieldHelper.borderForVisualState(
                effectiveState,
              ),
              focusedBorder: DsTextFieldHelper.borderForVisualState(
                effectiveState == DsInputVisualState.empty
                    ? DsInputVisualState.typing
                    : effectiveState,
              ),
              disabledBorder: DsTextFieldHelper.borderForVisualState(
                DsInputVisualState.inactive,
              ),
              errorBorder: DsTextFieldHelper.borderForVisualState(
                DsInputVisualState.error,
              ),
              focusedErrorBorder: DsTextFieldHelper.borderForVisualState(
                DsInputVisualState.error,
              ),
            ),
            hint: Text(
              widget.hintText,
              style: DsTextFieldHelper.hintStyle(state: effectiveState),
            ),
            style: DsTextFieldHelper.bodyStyle(state: effectiveState),
            items: widget.items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(
                      item.label,
                      style: DsTextFieldHelper.bodyStyle(
                        state: widget.enabled
                            ? DsInputVisualState.filled
                            : DsInputVisualState.inactive,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
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
