import 'package:flutter/material.dart';
import 'package:chat2date/theme/app_colors.dart';

class TagAutocomplete extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onChanged;

  const TagAutocomplete({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onChanged,
  });

  @override
  State<TagAutocomplete> createState() => _TagAutocompleteState();
}

class _TagAutocompleteState extends State<TagAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<String> suggestions = [];
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        setState(() => suggestions = []);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _updateSuggestions(String input) {
    final text = input.toLowerCase().trim();
    if (text.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    setState(() {
      suggestions = widget.allTags
          .where(
            (tag) =>
                tag.toLowerCase().contains(text) &&
                !widget.selectedTags.contains(tag),
          )
          .toList();
    });
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() => _selectedTags.add(tag));
      widget.onChanged(_selectedTags);
      _controller.clear();
      _updateSuggestions('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = _selectedTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "tags(ไม่บังคับ)",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),

        // ================= Chips + Input =================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...tags.map(
                (tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _selectedTags.remove(tag));
                    widget.onChanged(_selectedTags);
                  },
                ),
              ),
              SizedBox(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 40),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "เพิ่ม Tag",
                      hintStyle: TextStyle(color: AppColors.inputPlaceholder),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                    ),
                    onChanged: _updateSuggestions,
                    onSubmitted: (text) {
                      final newTag = text.trim();
                      if (newTag.isNotEmpty) {
                        _addTag(newTag);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // ================= Suggestion List =================
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: suggestions
                  .map(
                    (tag) => ListTile(
                      title: Text(tag),
                      onTap: () => _addTag(tag),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
