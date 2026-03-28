import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
    this.delayedIndices = const {0, 2, 3},
    this.tapAnimationDuration = const Duration(milliseconds: 300),
  });

  final int selectedIndex;
  final Function(int)? onTap;
  final Set<int> delayedIndices;
  final Duration tapAnimationDuration;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _selectedIndex;
  bool _isNavigating = false;

  static const List<_BottomNavItemData> _items = [
    _BottomNavItemData(
      label: 'Home',
      activeIcon: AppAssets.navHomeActive,
      inactiveIcon: AppAssets.navHomeInactive,
    ),
    _BottomNavItemData(
      label: 'Chat',
      activeIcon: AppAssets.navChatActive,
      inactiveIcon: AppAssets.navChatInactive,
    ),
    _BottomNavItemData(
      label: 'Profile',
      activeIcon: AppAssets.navProfileActive,
      inactiveIcon: AppAssets.navProfileInactive,
    ),
    _BottomNavItemData(
      label: 'Setting',
      activeIcon: AppAssets.navSettingActive,
      inactiveIcon: AppAssets.navSettingInactive,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  void _handleTap(int index) {
    if (_isNavigating) return;

    setState(() {
      _selectedIndex = index;
    });

    final bool shouldDelay = widget.delayedIndices.contains(index);
    if (widget.onTap == null) return;

    if (shouldDelay) {
      _isNavigating = true;
      Future.delayed(widget.tapAnimationDuration, () {
        if (!mounted) return;
        _isNavigating = false;
        widget.onTap!(index);
      });
      return;
    }

    widget.onTap!(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final bool isSelected = index == _selectedIndex;
            return _BottomNavButton(
              label: item.label,
              iconPath: isSelected ? item.activeIcon : item.inactiveIcon,
              isSelected: isSelected,
              onTap: () => _handleTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  static const LinearGradient _activeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandPrimary, Color(0xFFFFF1A8)],
  );

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = label == 'Setting'
        ? _buildSettingIcon()
        : SvgPicture.asset(iconPath, fit: BoxFit.contain);

    final Widget labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      style: AppBodyTextStyles.captionBold.copyWith(
        color: isSelected ? Colors.white : AppColors.textOnDark,
        height: 1,
      ),
    );

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: iconWidget,
                ),
                const SizedBox(height: 0),
                if (isSelected)
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => _activeGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: labelWidget,
                  )
                else
                  labelWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingIcon() {
    final Widget icon = const Icon(
      Icons.settings_rounded,
      size: 28,
      color: Colors.white,
    );

    if (!isSelected) {
      return icon;
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _activeGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: icon,
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final String activeIcon;
  final String inactiveIcon;
}
