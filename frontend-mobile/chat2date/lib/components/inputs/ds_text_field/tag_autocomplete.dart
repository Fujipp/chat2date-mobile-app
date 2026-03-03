import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
        // Clear suggestions when focus is lost
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
                !_selectedTags.contains(
                  tag,
                ), // Check against local selected tags
          )
          .toList();
    });
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() => _selectedTags.add(tag));
      widget.onChanged(_selectedTags);
      _controller.clear();
      // Update suggestions again after adding a tag
      _updateSuggestions('');
      // Keep focus after adding from suggestion list
      FocusScope.of(context).requestFocus(_focus);
    }
  }

  void _removeTag(String tag) {
    setState(() => _selectedTags.remove(tag));
    widget.onChanged(_selectedTags);
    // After removing, we might want to refresh suggestions if the input field has text
    _updateSuggestions(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
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

        // ================= Chips + Input Container =================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Add a subtle shadow to the input box
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Wrap(
            spacing: 8, // Increased spacing
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Use AnimatedSwitcher for a nice transition when adding/removing chips
              ..._selectedTags.map(
                (tag) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Chip(
                    key: ValueKey(tag), // Key is important for AnimatedSwitcher
                    label: Text(tag),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor:
                        AppColors.surfaceLight, // Use primary color
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white70,
                    ),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    onDeleted: () => _removeTag(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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
                      hintText: "เพิ่มแท็กที่นี่",
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
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Add a stronger shadow to lift the suggestion box
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 180,
            ), // Slightly taller
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: suggestions
                  .map(
                    (tag) => ListTile(
                      title: Text(
                        tag,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () => _addTag(tag),
                      dense: true,
                      hoverColor: AppColors.brandSecondary.withOpacity(
                        0.1,
                      ), // Nice hover effect
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, // More padding
                        vertical: 0,
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
