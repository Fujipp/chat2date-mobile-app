import 'package:chat2date/components/design_system/v4/buttons/index.dart';
import 'package:chat2date/components/design_system/v4/inputs/index.dart';
import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class UiShowcaseScreen extends StatefulWidget {
  const UiShowcaseScreen({super.key});

  @override
  State<UiShowcaseScreen> createState() => _UiShowcaseScreenState();
}

class _UiShowcaseScreenState extends State<UiShowcaseScreen> {
  final _textController = TextEditingController();
  final _disabledController = TextEditingController(text: '88-888-8888');
  final _selectController = TextEditingController();
  final _areaController = TextEditingController();
  String? _dropdownValue;

  @override
  void dispose() {
    _textController.dispose();
    _disabledController.dispose();
    _selectController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      appBar: AppBar(
        title: const Text('UI Showcase'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _ShowcaseSectionTitle('Buttons'),
          const _ShowcaseCard(child: _ButtonsShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Inputs'),
          _ShowcaseCard(
            child: _InputsShowcase(
              textController: _textController,
              disabledController: _disabledController,
              selectController: _selectController,
              areaController: _areaController,
              dropdownValue: _dropdownValue,
              onDropdownChanged: (value) =>
                  setState(() => _dropdownValue = value),
              onSelectTap: () => setState(
                () => _selectController.text = 'Selected value',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonsShowcase extends StatelessWidget {
  const _ButtonsShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ButtonGroup(
          title: 'Button-Primary-1',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Secondary-1',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.primary,
                width: 231,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.primary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.primary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.primary,
                width: 231,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Mini-Accept',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Mini-Denied',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Reload-1',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonReloadIcon,
                iconSize: 17,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonReloadIcon,
                iconSize: 17,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonReloadIcon,
                iconSize: 17,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Setting-1',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonSettingsIcon,
                iconSize: 20,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonSettingsIcon,
                iconSize: 20,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.outlinePrimary,
                width: 231,
                leadingSvgAsset: AppAssets.buttonSettingsIcon,
                iconSize: 20,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Button-Exit',
          isLast: true,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 310,
                onPressed: () {},
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 310,
                onPressed: () {},
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 310,
                onPressed: () {},
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                variant: DsButtonVariant.error,
                width: 310,
                onPressed: () {},
                visualOverride: DsButtonVisualState.active,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputsShowcase extends StatelessWidget {
  const _InputsShowcase({
    required this.textController,
    required this.disabledController,
    required this.selectController,
    required this.areaController,
    required this.dropdownValue,
    required this.onDropdownChanged,
    required this.onSelectTap,
  });

  final TextEditingController textController;
  final TextEditingController disabledController;
  final TextEditingController selectController;
  final TextEditingController areaController;
  final String? dropdownValue;
  final ValueChanged<String?> onDropdownChanged;
  final VoidCallback onSelectTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ButtonGroup(
          title: 'Input 1',
          child: DsTextField(
            label: 'Text',
            required: true,
            hintText: 'Placeholder',
            controller: textController,
          ),
        ),
        _ButtonGroup(
          title: 'Input 2',
          child: DsTextField(
            label: 'Text',
            enabled: false,
            controller: disabledController,
            prefix: const Text('+66'),
          ),
        ),
        _ButtonGroup(
          title: 'Input 3',
          child: DsTextField(
            label: 'Text',
            required: true,
            readOnly: true,
            controller: selectController,
            hintText: 'Placeholder',
            suffix: GestureDetector(
              onTap: onSelectTap,
              child: SizedBox(
                width: 18,
                height: 18,
                child: SvgPicture.asset(
                  AppAssets.inputSelectMarkerIcon,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  theme: const SvgTheme(currentColor: AppColors.brandPrimary),
                ),
              ),
            ),
          ),
        ),
        _ButtonGroup(
          title: 'Input 4 / 5',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              EditInputField(
                label: 'Text*',
                placeholder: 'Text',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 12),
              EditInputField(
                label: 'Text*',
                placeholder: '88-8888-8888',
                prefixText: '+66',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        _ButtonGroup(
          title: 'Input 6',
          child: const DsOtpField(
            label: 'Text',
            required: true,
            supportText: 'Support text',
          ),
        ),
        _ButtonGroup(
          title: 'Dropdown',
          child: DsDropdownField<String>(
            label: 'Text',
            required: true,
            hintText: 'Placeholder',
            value: dropdownValue,
            items: const [
              DsDropdownItem(value: 'text', label: 'Text'),
              DsDropdownItem(value: 'another', label: 'Another'),
            ],
            onChanged: onDropdownChanged,
          ),
        ),
        _ButtonGroup(
          title: 'Text Area',
          isLast: true,
          child: DsTextAreaField(
            label: 'Text',
            hintText: 'Placeholder',
            controller: areaController,
            minLines: 4,
            maxLines: 4,
          ),
        ),
      ],
    );
  }
}

class _ButtonGroup extends StatelessWidget {
  const _ButtonGroup({
    required this.title,
    required this.child,
    this.isLast = false,
  });

  final String title;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ShowcaseSectionTitle extends StatelessWidget {
  const _ShowcaseSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: child,
    );
  }
}
