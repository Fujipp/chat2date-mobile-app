import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/components/design_system/controls/index.dart';
import 'package:chat2date/components/design_system/feedback/ds_toast.dart';
import 'package:chat2date/components/design_system/inputs/index.dart';
import 'package:chat2date/components/design_system/navigation/index.dart';
import 'package:chat2date/components/design_system/organisms/index.dart';
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
  bool _homeHeaderTapped = false;
  String? _secondaryHeaderEvent;
  int _bottomNavIndex = 0;
  int _switcherIndex = 0;
  DsUserSelectorValue _userSelectorValue = DsUserSelectorValue.single;
  double _sliderValue = 50;
  final _searchTypingController = TextEditingController(text: 'Text');
  final _searchFilledController = TextEditingController(text: 'Text');
  final _textController = TextEditingController();
  final _disabledController = TextEditingController(text: '88-888-8888');
  final _selectController = TextEditingController();
  final _areaController = TextEditingController();
  String? _dropdownValue;

  @override
  void dispose() {
    _searchTypingController.dispose();
    _searchFilledController.dispose();
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
              searchTypingController: _searchTypingController,
              searchFilledController: _searchFilledController,
              dropdownValue: _dropdownValue,
              onDropdownChanged: (value) =>
                  setState(() => _dropdownValue = value),
              onSelectTap: () => setState(
                () => _selectController.text = 'Selected value',
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Toasts'),
          const _ShowcaseCard(child: _ToastShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Slider'),
          _ShowcaseCard(
            child: _SliderShowcase(
              value: _sliderValue,
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Switcher'),
          _ShowcaseCard(
            child: _SwitcherShowcase(
              selectedIndex: _switcherIndex,
              onChanged: (index) => setState(() => _switcherIndex = index),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Switcher Icon'),
          _ShowcaseCard(
            child: _IconSwitcherShowcase(
              value: _userSelectorValue,
              onChanged: (value) =>
                  setState(() => _userSelectorValue = value),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Navbar'),
          _NavbarShowcase(
            actionTapped: _homeHeaderTapped,
            onActionTap: () =>
                setState(() => _homeHeaderTapped = !_homeHeaderTapped),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Secondary Header'),
          _SecondaryHeaderShowcase(
            lastEvent: _secondaryHeaderEvent,
            onBackTap: () => setState(() => _secondaryHeaderEvent = 'Back tapped'),
            onPrimaryActionTap: () => setState(
              () => _secondaryHeaderEvent = 'Primary action tapped',
            ),
            onSecondaryActionTap: () => setState(
              () => _secondaryHeaderEvent = 'Secondary action tapped',
            ),
            onTertiaryActionTap: () => setState(
              () => _secondaryHeaderEvent = 'Tertiary action tapped',
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Bottom Navbar'),
          _ShowcaseCard(
            child: _BottomNavShowcase(
              selectedIndex: _bottomNavIndex,
              onTap: (index) => setState(() => _bottomNavIndex = index),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Reaction Buttons'),
          const _ShowcaseCard(child: _ReactionButtonsShowcase()),
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
    required this.searchTypingController,
    required this.searchFilledController,
    required this.textController,
    required this.disabledController,
    required this.selectController,
    required this.areaController,
    required this.dropdownValue,
    required this.onDropdownChanged,
    required this.onSelectTap,
  });

  final TextEditingController searchTypingController;
  final TextEditingController searchFilledController;
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
        const _ButtonGroup(
          title: 'Search Bar / Empty',
          child: DsSearchBar(),
        ),
        _ButtonGroup(
          title: 'Search Bar / Typing',
          child: DsSearchBar(
            controller: searchTypingController,
            state: DsInputVisualState.typing,
          ),
        ),
        _ButtonGroup(
          title: 'Search Bar / Filled',
          child: DsSearchBar(
            controller: searchFilledController,
            state: DsInputVisualState.filled,
          ),
        ),
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
                label: 'Text',
                required: true,
                placeholder: 'Text',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 12),
              EditInputField(
                label: 'Text',
                required: true,
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

class _ToastShowcase extends StatelessWidget {
  const _ToastShowcase();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Toast(
          type: ToastType.info,
          title: 'Title',
          message: 'Description. Lorem ipsum dolor sit amet.',
          onClose: _noop,
        ),
        SizedBox(height: 16),
        Toast(
          type: ToastType.success,
          title: 'Title',
          message: 'Description. Lorem ipsum dolor sit amet.',
          onClose: _noop,
        ),
        SizedBox(height: 16),
        Toast(
          type: ToastType.warning,
          title: 'Title',
          message: 'Description. Lorem ipsum dolor sit amet.',
          onClose: _noop,
        ),
        SizedBox(height: 16),
        Toast(
          type: ToastType.error,
          title: 'Title',
          message: 'Description. Lorem ipsum dolor sit amet.',
          onClose: _noop,
        ),
      ],
    );
  }

  static void _noop() {}
}

class _SliderShowcase extends StatelessWidget {
  const _SliderShowcase({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return DsSlider(
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SwitcherShowcase extends StatelessWidget {
  const _SwitcherShowcase({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DsSegmentedSwitcher(
      width: 332,
      items: const ['Section 1', 'Section 2'],
      selectedIndex: selectedIndex,
      onChanged: onChanged,
    );
  }
}

class _IconSwitcherShowcase extends StatelessWidget {
  const _IconSwitcherShowcase({
    required this.value,
    required this.onChanged,
  });

  final DsUserSelectorValue value;
  final ValueChanged<DsUserSelectorValue> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 120,
        height: 45,
        child: DsUserSelector(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NavbarShowcase extends StatelessWidget {
  const _NavbarShowcase({
    required this.actionTapped,
    required this.onActionTap,
  });

  final bool actionTapped;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 390,
          child: DsAppHomeHeader(
            onActionTap: onActionTap,
          ),
        ),
        if (actionTapped) ...[
          const SizedBox(height: 8),
          Text(
            'Right action tapped',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _ReactionButtonsShowcase extends StatelessWidget {
  const _ReactionButtonsShowcase();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        DsReactionButton(
          type: DsReactionButtonType.match,
        ),
        DsReactionButton(
          type: DsReactionButtonType.pass,
        ),
      ],
    );
  }
}

class _SecondaryHeaderShowcase extends StatelessWidget {
  const _SecondaryHeaderShowcase({
    required this.lastEvent,
    required this.onBackTap,
    required this.onPrimaryActionTap,
    required this.onSecondaryActionTap,
    required this.onTertiaryActionTap,
  });

  final String? lastEvent;
  final VoidCallback onBackTap;
  final VoidCallback onPrimaryActionTap;
  final VoidCallback onSecondaryActionTap;
  final VoidCallback onTertiaryActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 390,
          child: DsAppSecondaryHeader(
            variant: DsAppSecondaryHeaderVariant.base,
            onBackTap: onBackTap,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 390,
          child: DsAppSecondaryHeader(
            variant: DsAppSecondaryHeaderVariant.baseText,
            title: 'Text',
            onBackTap: onBackTap,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 390,
          child: DsAppSecondaryHeader(
            variant: DsAppSecondaryHeaderVariant.chat3,
            name: 'Name',
            onBackTap: onBackTap,
            onPrimaryActionTap: onPrimaryActionTap,
            onSecondaryActionTap: onSecondaryActionTap,
            onTertiaryActionTap: onTertiaryActionTap,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 390,
          child: DsAppSecondaryHeader(
            variant: DsAppSecondaryHeaderVariant.chat4,
            name: 'Name',
            cooldownText: '7',
            onBackTap: onBackTap,
            onPrimaryActionTap: onPrimaryActionTap,
            onSecondaryActionTap: onSecondaryActionTap,
            onTertiaryActionTap: onTertiaryActionTap,
          ),
        ),
        if (lastEvent != null) ...[
          const SizedBox(height: 8),
          Text(
            lastEvent!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _BottomNavShowcase extends StatelessWidget {
  const _BottomNavShowcase({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: SizedBox(
          width: 400,
          child: CustomBottomNavBar(
            selectedIndex: selectedIndex,
            delayedIndices: const {},
            onTap: onTap,
          ),
        ),
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
