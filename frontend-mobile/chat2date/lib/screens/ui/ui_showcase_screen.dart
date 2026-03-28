import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/components/design_system/controls/index.dart';
import 'package:chat2date/components/design_system/feedback/index.dart';
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
  int _levelBarLevel = 1;
  double _levelBarProgress = 0.35;
  DsUserSelectorValue _userSelectorValue = DsUserSelectorValue.single;
  double _sliderValue = 50;
  double _progressRingValue = 0.5;
  final _searchTypingController = TextEditingController(text: 'Text');
  final _searchFilledController = TextEditingController(text: 'Text');
  final _textController = TextEditingController();
  final _disabledController = TextEditingController(text: '88-888-8888');
  final _selectController = TextEditingController();
  final _areaController = TextEditingController();
  final _chatInputFilledController = TextEditingController(text: 'อยากไปเที่ยวจังเลย');
  final _chatInputTypingController = TextEditingController(text: 'อยากไปเที่ยวจังเลย');
  String? _dropdownValue;

  @override
  void dispose() {
    _searchTypingController.dispose();
    _searchFilledController.dispose();
    _textController.dispose();
    _disabledController.dispose();
    _selectController.dispose();
    _areaController.dispose();
    _chatInputFilledController.dispose();
    _chatInputTypingController.dispose();
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
          const _ShowcaseSectionTitle('Status Modal'),
          _ShowcaseCard(
            child: _StatusModalShowcase(
              onShowSuccess: () => DsStatusModal.show(
                context,
                type: DsStatusModalType.success,
                title: 'บันทึกเสร็จสิ้น',
                message:
                    'วันและเวลาออกเดตของคุณคือ 15 มกราคม 2026\nเวลา 12.00 น. ที่อควาเรียมบางแสน',
                trailingMessage:
                    'เราจะแจ้งเตือนคุณอีกครั้งล่วงหน้าก่อนวันเดต 1 วัน',
              ),
              onShowWarning: () => DsStatusModal.show(
                context,
                type: DsStatusModalType.warning,
                title: 'ติดคูลดาวน์การหาสถานที่เดต 7 วัน',
                message: 'สามารถกดที่',
                trailingMessage: 'เพื่อดูข้อมูลเพิ่มเติมได้',
                bodyMode: DsStatusModalBodyMode.inlineIcon,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Action Modal'),
          const _ShowcaseCard(child: _ActionModalShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Slider'),
          _ShowcaseCard(
            child: _SliderShowcase(
              value: _sliderValue,
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Progress Ring'),
          _ShowcaseCard(
            child: _ProgressRingShowcase(
              value: _progressRingValue,
              onChanged: (value) => setState(() => _progressRingValue = value),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Level Bar'),
          _ShowcaseCard(
            child: _LevelBarShowcase(
              level: _levelBarLevel,
              progress: _levelBarProgress,
              onLevelChanged: (value) => setState(() => _levelBarLevel = value),
              onProgressChanged: (value) =>
                  setState(() => _levelBarProgress = value),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Spin Wheel'),
          const _ShowcaseCard(child: _SpinWheelShowcase()),
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
          const _ShowcaseSectionTitle('Chat Card'),
          const _ShowcaseCard(child: _ChatCardShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Chat'),
          const _ShowcaseCard(child: _ChatThreadShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Chat Bot'),
          const _ShowcaseCard(child: _BotChatShowcase()),
          const SizedBox(height: 24),
          const _ShowcaseSectionTitle('Chat Input'),
          _ShowcaseCard(
            child: _ChatMessageInputShowcase(
              filledController: _chatInputFilledController,
              typingController: _chatInputTypingController,
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

class _ProgressRingShowcase extends StatelessWidget {
  const _ProgressRingShowcase({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            DsProgressRing(value: 0),
            DsProgressRing(value: 0.25),
            DsProgressRing(value: 0.5),
            DsProgressRing(value: 0.75),
            DsProgressRing(value: 1),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: DsProgressRing(value: value),
        ),
        const SizedBox(height: 12),
        Slider(
          min: 0,
          max: 1,
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.brandPrimary,
          inactiveColor: AppColors.divider,
        ),
      ],
    );
  }
}

class _StatusModalShowcase extends StatelessWidget {
  const _StatusModalShowcase({
    required this.onShowSuccess,
    required this.onShowWarning,
  });

  final VoidCallback onShowSuccess;
  final VoidCallback onShowWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DsStatusModal(
              type: DsStatusModalType.success,
              title: 'บันทึกเสร็จสิ้น',
              message:
                  'วันและเวลาออกเดตของคุณคือ 15 มกราคม 2026\nเวลา 12.00 น. ที่อควาเรียมบางแสน',
              trailingMessage:
                  'เราจะแจ้งเตือนคุณอีกครั้งล่วงหน้าก่อนวันเดต 1 วัน',
            ),
            DsStatusModal(
              type: DsStatusModalType.warning,
              title: 'ติดคูลดาวน์การหาสถานที่เดต 7 วัน',
              message: 'สามารถกดที่',
              trailingMessage: 'เพื่อดูข้อมูลเพิ่มเติมได้',
              bodyMode: DsStatusModalBodyMode.inlineIcon,
            ),
            DsStatusModal(
              type: DsStatusModalType.ban,
              title: 'คุณถูกแบน',
              message:
                  'เนื่องจากคุณโดนรายงาน และตรวจสอบแล้วว่าผิดจริง\nทำให้คะแนนความประพฤติต่ำกว่าเกณฑ์ที่กำหนด',
              trailingMessage:
                  'คุณจะไม่สามารถใช้บัญชีนี้ได้อีกต่อไปและไม่สามารถสร้างบัญชีใหม่ของคุณได้อีก',
            ),
            DsStatusModal(
              type: DsStatusModalType.congrats,
              title: 'ยินดีด้วย',
              message: 'คุณทั้งคู่มีความเห็นตรงกัน\nหวังว่าการเดินทางครั้งนี้',
              trailingMessage:
                  'จะเป็นก้าวแรกของความสัมพันธ์ที่ดีขึ้นไปอีก',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DsButton(
              label: 'Show Success',
              variant: DsButtonVariant.primary,
              onPressed: onShowSuccess,
            ),
            DsButton(
              label: 'Show Warning',
              variant: DsButtonVariant.outlinePrimary,
              onPressed: onShowWarning,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionModalShowcase extends StatefulWidget {
  const _ActionModalShowcase();

  @override
  State<_ActionModalShowcase> createState() => _ActionModalShowcaseState();
}

class _ActionModalShowcaseState extends State<_ActionModalShowcase> {
  final _rateController = TextEditingController();
  final _deleteController = TextEditingController();
  int? _choiceAnswer;
  int _rating = 0;

  @override
  void dispose() {
    _rateController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsActionModal(
          title: 'Unlock Your Date',
          description: 'เตรียมตัวไปสร้างเดตสุดพิเศษ\nกับคู่ของคุณกัน',
          minHeight: 283,
          decoration: DsActionModalDecoration.unlock,
          topVisual: SizedBox(
            width: 75,
            height: 92,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.headerSecondaryChat3CenterAction,
                width: 74,
                height: 74,
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: DsButton(
            label: 'ไปเดตกันเลย',
            variant: DsButtonVariant.primary,
            width: 231,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        DsActionModal(
          title: 'Unlock Your Calendar',
          description: 'ไปนัดหมายวันเวลาเดตสุดพิเศษ\nพร้อมกับคู่ของคุณกัน',
          minHeight: 283,
          decoration: DsActionModalDecoration.unlock,
          topVisual: SizedBox(
            width: 74,
            height: 82.22,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.headerSecondaryChat4LeftAction,
                width: 74,
                height: 74,
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: DsButton(
            label: 'ไปกันเลย',
            variant: DsButtonVariant.primary,
            width: 231,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        DsActionModal(
          title: 'ขอบคุณสำหรับการรายงาน',
          description: 'ระบบได้รับข้อมูลของคุณเรียบร้อยแล้ว',
          minHeight: 190,
          actions: DsButton(
            label: 'ปิด',
            variant: DsButtonVariant.primary,
            width: 231,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        DsChoiceModal(
          title: 'ยืนยันที่จะลบวันเดตหรือไม่',
          description:
              'การลบวันเดต สถานที่เดตวันนั้นจะหายไปด้วย\nคุณจะต้อง สุ่มเดตใหม่ หากต้องการเดตอีกครั้ง',
          negativeLabel: 'ยกเลิก',
          positiveLabel: 'ยืนยัน',
          onNegativePressed: () => setState(() => _choiceAnswer = 0),
          onPositivePressed: () => setState(() => _choiceAnswer = 1),
        ),
        const SizedBox(height: 16),
        DsChoiceModal(
          title: 'ยืนยันที่จะลบวันเดตหรือไม่',
          description:
              'การลบวันเดต สถานที่เดตวันนั้นจะหายไปด้วย\nคุณจะต้อง สุ่มเดตใหม่ หากต้องการเดตอีกครั้ง',
          negativeLabel: 'ยกเลิก',
          positiveLabel: 'ยืนยัน',
          negativeEnabled: _choiceAnswer != 1,
          positiveEnabled: _choiceAnswer != 0,
          onNegativePressed: () => setState(() => _choiceAnswer = 0),
          onPositivePressed: () => setState(() => _choiceAnswer = 1),
        ),
        const SizedBox(height: 16),
        DsChoiceModal(
          title: 'มีฝ่ายหนึ่งรู้สึกไม่พอใจกับการเดินทางครั้งนี้',
          description:
              'คุณต้องการเปิดโอกาสพูดคุยเพื่อทำความเข้าใจและ ไปต่อกับคู่ของคุณหรือไม่?',
          negativeLabel: 'ไม่ต้องการ',
          positiveLabel: 'ต้องการ',
          minHeight: 240,
          topVisual: SizedBox(
            width: 77,
            height: 78,
            child: SvgPicture.asset(
              AppAssets.unmatchWarningIcon,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DsChoiceModal(
          title: 'เสียใจที่การเดินทางครั้งนี้ไม่เป็นไปตามที่หวัง',
          description: 'ต้องการ ยกเลิกการจับคู่ (Unmatch)\nกับคู่ของคุณหรือไม่?',
          negativeLabel: 'ไม่ต้องการ',
          positiveLabel: 'ต้องการ',
          minHeight: 240,
          topVisual: SizedBox(
            width: 77.27,
            height: 78,
            child: SvgPicture.asset(
              AppAssets.unmatchBrokenHeartIcon,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DsAvatarDecisionModal(
          title: 'ประเมินคู่เดตของคุณ',
          name: 'Name',
          description: 'คุณพึงพอใจกับคู่เดตของคุณหรือไม่',
          warningLines: const [
            'การเลือกจะมีผลต่อความสัมพันธ์คู่ของคุณ',
            'พึงพอใจทั้งคู่ ถือว่าทั้งคู่ประสบความสำเร็จ',
            'ไม่พึงพอใจทั้งคู่ จะมีให้เลือกว่าจะ unmatch หรือไม่',
            'ไม่พอใจฝ่ายใดฝ่ายหนึ่ง จะมีให้เลือกไปต่อหรือพอแค่นี้',
            'หากฝ่ายใดฝ่ายหนึ่งเลือก unmatch หรือ พอแค่นี้ จะจบทันที',
          ],
          negativeLabel: 'ไม่พอใจ',
          positiveLabel: 'พอใจ',
          avatarImage: const AssetImage(AppAssets.placeholderFemale),
        ),
        const SizedBox(height: 16),
        DsRateAppModal(
          rating: _rating,
          controller: _rateController,
          onRatingChanged: (value) => setState(() => _rating = value),
        ),
        const SizedBox(height: 16),
        DsGuideBookModal(
          pages: [
            DsGuideBookPageData(
              image: _GuideBookImage(
                icon: 'assets/icons/ui/icon_chat2date_full.svg',
                caption: 'หน้าแชท',
              ),
              title: 'ยินดีต้อนรับเข้าสู่หน้าแชท',
              description:
                  'ระบบความสัมพันธ์จะคำนวณจากการพูดคุย\nสม่ำเสมอ เพื่อปลดล็อกสิ่งใหม่ๆ ไปพร้อมกัน',
            ),
            DsGuideBookPageData(
              image: _GuideBookImage(
                icon: AppAssets.spinwheelIcon,
                caption: 'วงล้อสุ่มเดต',
              ),
              title: 'สุ่มเดตได้ภายในหน้าแชท',
              description:
                  'กดวงล้อเพื่อสุ่มสถานที่เดตใหม่ และชวนคู่ของคุณออกไปเปิดประสบการณ์ร่วมกัน',
            ),
            DsGuideBookPageData(
              image: _GuideBookImage(
                icon: AppAssets.calendarIcon,
                caption: 'ปฏิทินเดต',
              ),
              title: 'จัดการวันเดตได้ทันที',
              description:
                  'เลือกวัน เวลา และดูข้อมูลเดตได้ในปฏิทิน เมื่อครบหน้าสุดท้ายปุ่มจะเปลี่ยนเป็นปิด',
            ),
          ],
        ),
        const SizedBox(height: 16),
        DsDeleteAccountModal(
          controller: _deleteController,
        ),
      ],
    );
  }
}

class _LevelBarShowcase extends StatelessWidget {
  const _LevelBarShowcase({
    required this.level,
    required this.progress,
    required this.onLevelChanged,
    required this.onProgressChanged,
  });

  final int level;
  final double progress;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DsLevelProgressBar(level: 0, progress: 0),
        const SizedBox(height: 12),
        const DsLevelProgressBar(level: 0, progress: 0.35),
        const SizedBox(height: 12),
        const DsLevelProgressBar(level: 1, progress: 0.50),
        const SizedBox(height: 12),
        const DsLevelProgressBar(level: 2, progress: 0.74),
        const SizedBox(height: 12),
        const DsLevelProgressBar(level: 3, progress: 1),
        const SizedBox(height: 16),
        DsLevelProgressBar(
          level: level,
          progress: progress,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Level',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            for (final item in [0, 1, 2, 3]) ...[
              ChoiceChip(
                label: Text('$item'),
                selected: level == item,
                onSelected: (_) => onLevelChanged(item),
              ),
              if (item != 3) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: progress,
          min: 0,
          max: 1,
          onChanged: level == 3 ? null : onProgressChanged,
        ),
      ],
    );
  }
}

class _GuideBookImage extends StatelessWidget {
  const _GuideBookImage({
    required this.icon,
    required this.caption,
  });

  final String icon;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon.endsWith('.svg'))
            SvgPicture.asset(
              icon,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            )
          else
            Image.asset(
              icon,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinWheelShowcase extends StatelessWidget {
  const _SpinWheelShowcase();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsSpinWheelCard(
        userALabel: 'User A',
        userBLabel: 'User B',
        items: const [
          DsSpinWheelItem(
            label: 'A',
            imageProvider: AssetImage(AppAssets.placeholderFemale),
          ),
          DsSpinWheelItem(
            label: 'B',
            imageProvider: AssetImage(AppAssets.placeholderMale),
          ),
          DsSpinWheelItem(
            label: 'C',
            imageProvider: AssetImage(AppAssets.placeholderMajiko),
          ),
          DsSpinWheelItem(
            label: 'D',
            imageProvider: AssetImage(AppAssets.placeholderFemale),
          ),
          DsSpinWheelItem(
            label: 'E',
            imageProvider: AssetImage(AppAssets.placeholderMale),
          ),
          DsSpinWheelItem(
            label: 'F',
            imageProvider: AssetImage(AppAssets.placeholderMajiko),
          ),
          DsSpinWheelItem(
            label: 'G',
            imageProvider: AssetImage(AppAssets.placeholderFemale),
          ),
          DsSpinWheelItem(
            label: 'H',
            imageProvider: AssetImage(AppAssets.placeholderMale),
          ),
          DsSpinWheelItem(
            label: 'I',
            imageProvider: AssetImage(AppAssets.placeholderMajiko),
          ),
          DsSpinWheelItem(
            label: 'J',
            imageProvider: AssetImage(AppAssets.placeholderFemale),
          ),
        ],
      ),
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

class _ChatCardShowcase extends StatelessWidget {
  const _ChatCardShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        DsChatCard(
          title: 'Title',
          subtitle: 'ข้อความล่าสุด',
          avatarImage: AssetImage(AppAssets.placeholderFemale),
        ),
        SizedBox(height: 16),
        DsChatCard(
          title: 'Title',
          subtitle: 'ข้อความล่าสุด',
          variant: DsChatCardVariant.highlighted,
          avatarImage: AssetImage(AppAssets.placeholderMale),
          unreadCount: 14,
        ),
      ],
    );
  }
}

class _ChatThreadShowcase extends StatelessWidget {
  const _ChatThreadShowcase();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsChatThread(
        now: DateTime(2026, 3, 22, 15, 0),
        messages: [
          DsChatMessage(
            id: 'old-day',
            text: 'text message',
            sentAt: DateTime(2025, 9, 22, 22, 0),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.single,
          ),
          DsChatMessage(
            id: 'send-time',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 13, 55),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.single,
          ),
          DsChatMessage(
            id: 'send-1',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 5),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.single,
          ),
          DsChatMessage(
            id: 'send-2-a',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 10),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.first,
          ),
          DsChatMessage(
            id: 'send-2-b',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 11),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.last,
          ),
          DsChatMessage(
            id: 'send-3-a',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 15),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.first,
          ),
          DsChatMessage(
            id: 'send-3-b',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 16),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.middle,
          ),
          DsChatMessage(
            id: 'send-3-c',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 17),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.last,
          ),
          DsChatMessage(
            id: 'receive-1',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 30),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.single,
            avatar: _DemoChatAvatar(),
          ),
          DsChatMessage(
            id: 'receive-2-a',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 34),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.first,
            avatar: _DemoChatAvatar(),
          ),
          DsChatMessage(
            id: 'receive-2-b',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 35),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.last,
          ),
          DsChatMessage(
            id: 'receive-3-a',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 40),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.first,
            avatar: _DemoChatAvatar(),
          ),
          DsChatMessage(
            id: 'receive-3-b',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 41),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.middle,
          ),
          DsChatMessage(
            id: 'receive-3-c',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 42),
            isSender: false,
            groupPosition: DsChatBubbleGroupPosition.last,
            avatar: _DemoChatAvatar(),
          ),
          DsChatMessage(
            id: 'send-latest-seen',
            text: 'text message',
            sentAt: DateTime(2026, 3, 22, 14, 50),
            isSender: true,
            groupPosition: DsChatBubbleGroupPosition.single,
          ),
        ],
      ),
    );
  }
}

class _BotChatShowcase extends StatelessWidget {
  const _BotChatShowcase();

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime(2026, 3, 27, 15, 43, 31);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsBotChat(
          type: DsBotChatType.minigame,
          createdAt: createdAt,
          now: createdAt.add(const Duration(hours: 2, minutes: 13, seconds: 8)),
          onActionPressed: () {},
        ),
        const SizedBox(height: 20),
        DsBotChat(
          type: DsBotChatType.minigameFail,
          createdAt: createdAt,
          now: createdAt.add(const Duration(hours: 24, minutes: 1)),
        ),
        const SizedBox(height: 20),
        DsBotChat(
          type: DsBotChatType.ask,
          answeredCount: 0,
          totalCount: 2,
          onDeclinePressed: () {},
          onAcceptPressed: () {},
        ),
        const SizedBox(height: 20),
        DsBotChat(
          type: DsBotChatType.askAnswer,
          answeredCount: 1,
          totalCount: 2,
        ),
        const SizedBox(height: 20),
        const DsBotChat(
          type: DsBotChatType.askSuccess,
        ),
        const SizedBox(height: 20),
        const DsBotChat(
          type: DsBotChatType.askFail,
        ),
      ],
    );
  }
}

class _ChatMessageInputShowcase extends StatelessWidget {
  const _ChatMessageInputShowcase({
    required this.filledController,
    required this.typingController,
  });

  final TextEditingController filledController;
  final TextEditingController typingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DsChatMessageInput(
          enabled: false,
        ),
        const SizedBox(height: 20),
        const DsChatMessageInput(),
        const SizedBox(height: 20),
        DsChatMessageInput(
          controller: filledController,
          onSend: () {},
        ),
        const SizedBox(height: 20),
        DsChatMessageInput(
          controller: typingController,
          autofocus: true,
          onSend: () {},
        ),
      ],
    );
  }
}

class _DemoChatAvatar extends StatelessWidget {
  const _DemoChatAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.all(8),
      child: SvgPicture.asset(
        AppAssets.headerSecondaryAvatar,
        fit: BoxFit.contain,
      ),
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
