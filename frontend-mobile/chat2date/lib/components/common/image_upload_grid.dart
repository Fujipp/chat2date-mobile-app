import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadGrid extends StatefulWidget {
  final Function(List<XFile> images)? onImagesChanged;
  final double spacing;
  final double runSpacing;

  const ImageUploadGrid({
    super.key,
    this.onImagesChanged,
    this.spacing = 12.0,
    this.runSpacing = 50.0,
  });

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  final List<XFile?> _images = List.filled(6, null);
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _images[index] = image);
      _notifyParent();
    }
  }

  void _removeImage(int index) {
    setState(() => _images[index] = null);
    _notifyParent();
  }

  void _notifyParent() {
    final List<XFile> currentImages = _images
        .where((img) => img != null)
        .cast<XFile>()
        .toList();
    widget.onImagesChanged?.call(currentImages);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isTablet = screenWidth > 600;

    double itemWidth = 119;
    double itemHeight = 120;
    double iconSize = 32;
    double internalPadding = 40;
    double spacing = widget.spacing;
    double runSpacing = widget.runSpacing;

    if (isTablet) {
      itemWidth = 180;
      itemHeight = 182;
      iconSize = 48;
      internalPadding = 60;
      spacing = 20;
      runSpacing = 70;
    }

    const int crossAxisCount = 2;

    final double calculatedWidth =
        (itemWidth * crossAxisCount) + (spacing * (crossAxisCount - 1));

    return Center(
      child: SizedBox(
        width: calculatedWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: WrapAlignment.start,
          children: List.generate(6, (index) {
            final XFile? image = _images[index];
            Widget content;

            if (image == null) {
              content = _AddImageButton(
                onTap: () => _pickImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                iconSize: iconSize,
                padding: internalPadding,
              );
            } else {
              content = _ImagePreview(
                imageFile: File(image.path),
                onRemove: () => _removeImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
              );
            }

            return SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: content,
            );
          }),
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final double itemWidth;
  final double itemHeight;
  final double iconSize;
  final double padding;

  const _AddImageButton({
    required this.onTap,
    required this.itemWidth,
    required this.itemHeight,
    required this.iconSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        height: itemHeight,
        padding: EdgeInsets.all(padding),
        decoration: ShapeDecoration(
          color: const Color(0xFFF7FAFE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(Icons.add, color: const Color(0xFF94A3B8), size: iconSize),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRemove;
  final double itemWidth;
  final double itemHeight;

  const _ImagePreview({
    required this.imageFile,
    required this.onRemove,
    required this.itemWidth,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: itemWidth,
      height: itemHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
