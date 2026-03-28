import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
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
  final GlobalKey _fieldKey = GlobalKey();
  bool _isOpen = false;

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

  Future<void> _openMenu() async {
    if (!widget.enabled || widget.items.isEmpty) return;

    final context = _fieldKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlayBox == null) return;

    final boxOffset = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final boxSize = renderBox.size;
    final menuItemWidth = boxSize.width - 32;
    final selectedValue = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        boxOffset.dx,
        boxOffset.dy + boxSize.height + 8,
        overlayBox.size.width - boxOffset.dx - boxSize.width,
        0,
      ),
      color: AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      items: widget.items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: menuItemWidth,
                  child: Text(
                    item.label,
                    style: (item.value == widget.value
                            ? DsTextFieldHelper.labelStyle()
                            : DsTextFieldHelper.bodyStyle(
                                state: DsInputVisualState.filled,
                              ))
                        .copyWith(
                          color: item.value == widget.value
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          )
          .toList(),
      );

    if (!mounted) return;
    setState(() => _isOpen = false);
    _focusNode.unfocus();

    if (selectedValue != null) {
      widget.onChanged?.call(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;
    final effectiveState = DsTextFieldHelper.normalizeState(
      enabled: widget.enabled,
      hasFocus: _focusNode.hasFocus || _isOpen,
      hasError: widget.state == DsInputVisualState.error,
      hasValue: hasValue,
      explicitState: widget.state,
    );

    final selectedItem = widget.items.cast<DsDropdownItem<T>?>().firstWhere(
      (item) => item?.value == widget.value,
      orElse: () => null,
    );
    final displayText = selectedItem?.label ?? widget.hintText;
    final textStyle = selectedItem == null
        ? DsTextFieldHelper.hintStyle(state: effectiveState)
        : DsTextFieldHelper.bodyStyle(state: effectiveState);

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
      padding: const EdgeInsets.only(left: 12),
      child: DsTextFieldHelper.buildSvgIcon(
        AppAssets.inputDropdownIcon,
        size: 12,
        color: iconColor,
        turns: _isOpen ? 0.5 : 0,
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
                        style: TextStyle(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
        if ((widget.label ?? '').isNotEmpty) const SizedBox(height: 8),
        GestureDetector(
          key: _fieldKey,
          onTap: () {
            setState(() => _isOpen = true);
            _focusNode.requestFocus();
            _openMenu();
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DsTextFieldHelper.fillColorForVisualState(effectiveState),
              borderRadius: BorderRadius.circular(12),
              border: Border.fromBorderSide(
                (DsTextFieldHelper.borderForVisualState(
                  effectiveState == DsInputVisualState.empty && _isOpen
                      ? DsInputVisualState.typing
                      : effectiveState,
                ) as OutlineInputBorder)
                    .borderSide,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                dropdownIcon,
              ],
            ),
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
