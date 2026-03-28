import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsChatBubbleGroupPosition { single, first, middle, last }

class DsChatMessage {
  const DsChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isSender,
    this.groupPosition = DsChatBubbleGroupPosition.single,
    this.avatarImage,
    this.avatar,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final bool isSender;
  final DsChatBubbleGroupPosition groupPosition;
  final ImageProvider<Object>? avatarImage;
  final Widget? avatar;
}

class DsChatThread extends StatefulWidget {
  const DsChatThread({
    super.key,
    required this.messages,
    this.width = 360,
    this.maxBubbleWidth = 122,
    this.now,
    this.seenText = 'เห็นแล้ว',
  });

  final List<DsChatMessage> messages;
  final double width;
  final double maxBubbleWidth;
  final DateTime? now;
  final String seenText;

  @override
  State<DsChatThread> createState() => _DsChatThreadState();
}

class _DsChatThreadState extends State<DsChatThread> {
  static const List<String> _thaiWeekdays = <String>[
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์',
  ];

  static const List<String> _thaiMonths = <String>[
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  String? _selectedMessageId;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(widget.messages);
    final latestMessage = widget.messages.isEmpty
        ? null
        : ([...widget.messages]..sort((a, b) => a.sentAt.compareTo(b.sentAt))).last;

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            switch (entry) {
              _DsChatSeparatorEntry() => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.spacingAfter,
                ),
                child: _SeparatorLabel(
                  text: entry.label,
                ),
              ),
              _DsChatMessageEntry() => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChatMessageRow(
                  message: entry.message,
                  groupPosition: entry.groupPosition,
                  isLatestSenderMessage:
                      latestMessage != null &&
                      latestMessage.isSender &&
                      entry.message.id == latestMessage.id,
                  isSelected: _selectedMessageId == entry.message.id,
                  maxBubbleWidth: widget.maxBubbleWidth,
                  seenText: widget.seenText,
                  onTap: () {
                    setState(() {
                      _selectedMessageId = _selectedMessageId == entry.message.id
                          ? null
                          : entry.message.id;
                    });
                  },
                ),
              ),
            },
        ],
      ),
    );
  }

  List<_DsChatEntry> _buildEntries(List<DsChatMessage> messages) {
    final sorted = [...messages]..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final entries = <_DsChatEntry>[];
    DateTime? lastDay;
    String? lastHourKey;

    for (final message in sorted) {
      final currentDay = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      final isToday = _isSameDay(currentDay, DateTime(_now.year, _now.month, _now.day));

      if (lastDay == null || !_isSameDay(lastDay, currentDay)) {
        final label = isToday
            ? _formatHourlySeparator(message.sentAt)
            : _formatDateSeparator(message.sentAt);
        entries.add(
          _DsChatSeparatorEntry(
            label: label,
            spacingAfter: 10,
          ),
        );
        lastDay = currentDay;
        lastHourKey = isToday ? _hourKey(message.sentAt) : null;
      } else if (isToday) {
        final hourKey = _hourKey(message.sentAt);
        if (lastHourKey != hourKey) {
          entries.add(
            _DsChatSeparatorEntry(
              label: _formatHourlySeparator(message.sentAt),
              spacingAfter: 10,
            ),
          );
          lastHourKey = hourKey;
        }
      }

      entries.add(
        _DsChatMessageEntry(
          message,
          _resolveGroupPosition(
            sorted: sorted,
            index: sorted.indexOf(message),
            bucketKey: _messageBucketKey(message),
          ),
        ),
      );
    }

    return entries;
  }

  DsChatBubbleGroupPosition _resolveGroupPosition({
    required List<DsChatMessage> sorted,
    required int index,
    required String bucketKey,
  }) {
    final current = sorted[index];
    final previous = index > 0 ? sorted[index - 1] : null;
    final next = index < sorted.length - 1 ? sorted[index + 1] : null;

    final hasPreviousSibling =
        previous != null &&
        previous.isSender == current.isSender &&
        _messageBucketKey(previous) == bucketKey;
    final hasNextSibling =
        next != null &&
        next.isSender == current.isSender &&
        _messageBucketKey(next) == bucketKey;

    if (hasPreviousSibling && hasNextSibling) {
      return DsChatBubbleGroupPosition.middle;
    }
    if (hasPreviousSibling) {
      return DsChatBubbleGroupPosition.last;
    }
    if (hasNextSibling) {
      return DsChatBubbleGroupPosition.first;
    }
    return DsChatBubbleGroupPosition.single;
  }

  String _messageBucketKey(DsChatMessage message) {
    final day = DateTime(message.sentAt.year, message.sentAt.month, message.sentAt.day);
    final isToday = _isSameDay(day, DateTime(_now.year, _now.month, _now.day));
    if (isToday) {
      return 'hour:${_hourKey(message.sentAt)}';
    }
    return 'day:${message.sentAt.year}-${message.sentAt.month}-${message.sentAt.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _hourKey(DateTime value) => '${value.year}-${value.month}-${value.day}-${value.hour}';

  String _formatDateSeparator(DateTime value) {
    final weekday = _thaiWeekdays[value.weekday - 1];
    final month = _thaiMonths[value.month - 1];
    return '$weekday ${value.day} $month, ${value.year}';
  }

  String _formatHourlySeparator(DateTime value) {
    final weekday = _thaiWeekdays[value.weekday - 1];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$weekday $hour:$minute';
  }
}

sealed class _DsChatEntry {}

class _DsChatSeparatorEntry extends _DsChatEntry {
  _DsChatSeparatorEntry({
    required this.label,
    required this.spacingAfter,
  });

  final String label;
  final double spacingAfter;
}

class _DsChatMessageEntry extends _DsChatEntry {
  _DsChatMessageEntry(this.message, this.groupPosition);

  final DsChatMessage message;
  final DsChatBubbleGroupPosition groupPosition;
}

class _SeparatorLabel extends StatelessWidget {
  const _SeparatorLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppBodyTextStyles.caption.copyWith(
          color: AppColors.textSupport,
        ),
      ),
    );
  }
}

class _ChatMessageRow extends StatelessWidget {
  const _ChatMessageRow({
    required this.message,
    required this.groupPosition,
    required this.isLatestSenderMessage,
    required this.isSelected,
    required this.maxBubbleWidth,
    required this.seenText,
    required this.onTap,
  });

  final DsChatMessage message;
  final DsChatBubbleGroupPosition groupPosition;
  final bool isLatestSenderMessage;
  final bool isSelected;
  final double maxBubbleWidth;
  final String seenText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (message.isSender) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _Bubble(
              text: message.text,
              backgroundColor: AppColors.brandPrimary,
              textColor: AppColors.textOnDark,
              borderRadius: _senderRadius(groupPosition),
              maxWidth: maxBubbleWidth,
              onTap: onTap,
            ),
          ),
          const SizedBox(height: 5),
          _MessageMeta(
            alignRight: true,
            showSeen: isLatestSenderMessage && !isSelected,
            showTimestamp: isSelected,
            seenText: seenText,
            timestamp: message.sentAt,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          avatar: message.avatar,
          avatarImage: message.avatarImage,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bubble(
              text: message.text,
              backgroundColor: AppColors.divider,
              textColor: AppColors.textBlack,
              borderRadius: _receiverRadius(groupPosition),
              maxWidth: maxBubbleWidth,
              onTap: onTap,
            ),
            if (isSelected) ...[
              const SizedBox(height: 5),
              _MessageMeta(
                alignRight: false,
                showSeen: false,
                showTimestamp: true,
                seenText: seenText,
                timestamp: message.sentAt,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.maxWidth,
    required this.onTap,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Text(
            text,
            style: AppBodyTextStyles.body.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    this.avatar,
    this.avatarImage,
  });

  final Widget? avatar;
  final ImageProvider<Object>? avatarImage;

  @override
  Widget build(BuildContext context) {
    if (avatar != null) {
      return SizedBox(
        width: 50,
        height: 50,
        child: ClipOval(child: avatar!),
      );
    }

    if (avatarImage != null) {
      return ClipOval(
        child: Image(
          image: avatarImage!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }

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

class _MessageMeta extends StatelessWidget {
  const _MessageMeta({
    required this.alignRight,
    required this.showSeen,
    required this.showTimestamp,
    required this.seenText,
    required this.timestamp,
  });

  final bool alignRight;
  final bool showSeen;
  final bool showTimestamp;
  final String seenText;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    if (!showSeen && !showTimestamp) {
      return const SizedBox.shrink();
    }

    final text = showTimestamp
        ? _formatTimestamp(timestamp)
        : seenText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppBodyTextStyles.overline.copyWith(
            color: AppColors.textSupport,
          ),
        ),
        if (showSeen) ...[
          const SizedBox(width: 4),
          SvgPicture.asset(
            AppAssets.seenIcon,
            width: 13,
            height: 7,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.textSupport,
              BlendMode.srcIn,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

BorderRadius _senderRadius(DsChatBubbleGroupPosition position) {
  return switch (position) {
    DsChatBubbleGroupPosition.single => BorderRadius.circular(20),
    DsChatBubbleGroupPosition.first => const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(5),
    ),
    DsChatBubbleGroupPosition.middle => const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(5),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(5),
    ),
    DsChatBubbleGroupPosition.last => const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(5),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  };
}

BorderRadius _receiverRadius(DsChatBubbleGroupPosition position) {
  return switch (position) {
    DsChatBubbleGroupPosition.single => BorderRadius.circular(20),
    DsChatBubbleGroupPosition.first => const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(5),
      bottomRight: Radius.circular(20),
    ),
    DsChatBubbleGroupPosition.middle => const BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(5),
      bottomRight: Radius.circular(20),
    ),
    DsChatBubbleGroupPosition.last => const BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  };
}
