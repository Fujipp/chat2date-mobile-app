import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';

class DsOtpField extends StatefulWidget {
  const DsOtpField({
    super.key,
    this.length = 6,
    required this.label,
    this.required = false,
    this.supportText,
    this.autoFocus = false,
    this.obscure = false,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final String label;
  final bool required;
  final String? supportText;
  final bool autoFocus;
  final bool obscure;

  /// ยิงทุกครั้งที่มีการเปลี่ยนค่า (รวมกรณีวาง paste)
  final ValueChanged<String>? onChanged;

  /// ยิงเมื่อกรอกครบทุกช่อง
  final ValueChanged<String>? onCompleted;

  @override
  State<DsOtpField> createState() => _DsOtpFieldState();
}

class _DsOtpFieldState extends State<DsOtpField> {
  late final List<TextEditingController> _ctls;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctls = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    if (widget.autoFocus && _nodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _ctls.map((c) => c.text).join();

  void _notify() {
    final v = _value;
    widget.onChanged?.call(v);
    if (v.length == widget.length && _ctls.every((c) => c.text.isNotEmpty)) {
      widget.onCompleted?.call(v);
    }
  }

  void _handlePaste(String pasted, int startIndex) {
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    final chars = digits.split('');
    int i = startIndex;
    for (final ch in chars) {
      if (i >= widget.length) break;
      _ctls[i].text = ch;
      i++;
    }
    if (i <= widget.length - 1) {
      _nodes[i].requestFocus();
    } else {
      _nodes.last.unfocus();
    }
    setState(() {});
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    const boxSize = 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + required
        RichText(
          text: TextSpan(
            text: widget.label,
            style: DefaultTextStyle.of(context).style.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            children: widget.required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),

        // OTP Inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: boxSize,
              height: boxSize,
              child: _OtpBox(
                controller: _ctls[index],
                focusNode: _nodes[index],
                obscure: widget.obscure,
                onChanged: (val) {
                  if (val.length > 1) {
                    _handlePaste(val, index);
                    return;
                  }
                  if (val.isNotEmpty && index < widget.length - 1) {
                    _nodes[index + 1].requestFocus();
                  }
                  if (_ctls.every((c) => c.text.isNotEmpty)) {
                    _nodes.last.unfocus();
                  }
                  _notify();
                },
                onBackspaceOnEmpty: () {
                  if (index > 0) {
                    _ctls[index - 1].clear();
                    _nodes[index - 1].requestFocus();
                    setState(() {});
                    _notify();
                  }
                },
                onPasteIntent: (clip) => _handlePaste(clip, index),
              ),
            );
          }),
        ),

        if (widget.supportText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.supportText!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceOnEmpty,
    required this.onPasteIntent,
    this.obscure = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceOnEmpty;
  final ValueChanged<String> onPasteIntent;

  @override
  Widget build(BuildContext context) {
    // ใช้ Shortcuts/Actions จับ Cmd/Ctrl+V
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyV, meta: true): PasteTextIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, control: true):
            PasteTextIntent(),
      },
      child: Actions(
        actions: {
          PasteTextIntent: CallbackAction<PasteTextIntent>(
            onInvoke: (intent) async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text case final text?) {
                onPasteIntent(text);
              }
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // คำนวณฟอนต์ให้ “พอดีช่อง” โดยดูด้านสั้นสุดของกล่อง
            final shortest = constraints.biggest.shortestSide;
            // ค่า 0.58 กำลังดีสำหรับตัวเลข/น้ำหนัก bold ในช่องมีขอบ/ระยะหายใจ
            final fontSize = shortest * 0.58;

            return TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center, // กลางแกน Y
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                height: 1.0, // line-height กระชับ ไม่ดันออกนอก
              ),

              // === คีย์บอร์ดตัวเลขล้วน + ปิดลูกเล่นที่ไม่จำเป็น ===
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 1,
              showCursor: true,
              obscureText: obscure,
              enableSuggestions: false,
              autocorrect: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              autofillHints: const [AutofillHints.oneTimeCode],

              // formatter: เฉพาะตัวเลข + จำกัด 1 ตัว + จับ backspace ตอนว่าง
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              // ใช้ RawKey handler แทน formatter สำหรับ backspace-ตอนว่าง
              onChanged: onChanged,

              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding:
                    EdgeInsets.zero, // ไม่มี padding เพื่อให้พอดีช่องจริง
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // เลือกทั้งหมดเมื่อแตะ เพื่อพิมพ์ทับง่าย
              onTap: () {
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
              onEditingComplete: () {}, // กันปิดคีย์บอร์ดเวลา “Done”
              onSubmitted: (_) {},
            );
          },
        ),
      ),
    );
  }
}

/// Intent สำหรับจับ Paste (ใช้กับ Shortcuts/Actions)
class PasteTextIntent extends Intent {
  const PasteTextIntent();
}
