import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadGrid extends StatefulWidget {
  final Function(List<XFile> images)? onImagesChanged;
  final Function(int index, dynamic removedItem)? onImageRemoved;
  final double spacing;
  final double runSpacing;
  final List<String> imageUser;

  const ImageUploadGrid({
    super.key,
    this.onImagesChanged,
    this.spacing = 12.0,
    this.runSpacing = 50.0,
    this.imageUser = const [],
    this.onImageRemoved,
  });

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  late List<dynamic> _images = List.filled(6, null);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initImages();
  }

  void _initImages() {
    _images = List<dynamic>.filled(6, null);
    for (int i = 0; i < widget.imageUser.length && i < _images.length; i++) {
      final url = widget.imageUser[i];
      if (url.isNotEmpty) {
        _images[i] = url;
      }
    }
  }

  @override
  void didUpdateWidget(covariant ImageUploadGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key) {
      _initImages();
      _notifyParent();
    }
  }

  // ✨ เลือกรูปภาพ - รองรับหลายรูปจากคลัง หรือ 1 รูปจากกล้อง
  Future<void> _pickImage(int index) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    // 🔥 เลือกหลายรูปจากคลัง หรือ 1 รูปจากกล้อง
    // image_picker จัดการ permission ให้เองอัตโนมัติ
    if (source == ImageSource.gallery) {
      await _pickMultipleImages(index);
    } else {
      await _pickSingleImage(index);
    }
  }

  // 📸 ถ่ายรูป 1 รูป
  Future<void> _pickSingleImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      maxWidth: 2600,
    );

    if (image != null) {
      setState(() => _images[index] = image);
      _notifyParent();
    }
  }

  // 🖼️ เลือกหลายรูปจากคลัง
  Future<void> _pickMultipleImages(int startIndex) async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 92,
      maxWidth: 2600,
    );

    if (images.isEmpty) return;

    // หาช่องว่างทั้งหมด
    List<int> emptySlots = [];
    for (int i = 0; i < _images.length; i++) {
      if (_images[i] == null) {
        emptySlots.add(i);
      }
    }

    // เช็คว่ามีช่องว่างพอไหม
    if (emptySlots.isEmpty) {
      if (!mounted) return;
      _showMaxImagesDialog();
      return;
    }

    // คำนวณจำนวนรูปที่สามารถเพิ่มได้
    int availableSlots = emptySlots.length;
    int imagesToAdd = images.length > availableSlots
        ? availableSlots
        : images.length;

    // แจ้งเตือนถ้ารูปเกิน
    if (images.length > availableSlots) {
      if (!mounted) return;
      _showTooManyImagesDialog(availableSlots, images.length);
    }

    // เพิ่มรูปลงในช่องว่าง
    setState(() {
      for (int i = 0; i < imagesToAdd; i++) {
        _images[emptySlots[i]] = images[i];
      }
    });

    _notifyParent();
  }

  // ✨ แสดง Dialog เลือกแหล่งรูป
  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('เลือกจากคลังรูป (หลายรูป)'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('ถ่ายภาพตอนนี้'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ✨ แสดง Dialog เมื่อเต็มแล้ว
  void _showMaxImagesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เต็มแล้ว'),
        content: const Text('คุณเลือกรูปครบ 6 รูปแล้ว กรุณาลบรูปเก่าออกก่อน'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ตรวจสอบ'),
          ),
        ],
      ),
    );
  }

  // ✨ แสดง Dialog เมื่อเลือกรูปเกิน
  void _showTooManyImagesDialog(int available, int selected) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('รูปภาพเกิน'),
        content: Text(
          'คุณเลือก $selected รูป แต่มีช่องว่างเพียง $available ช่อง\nระบบจะเพิ่มเฉพาะ $available รูปแรก',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    final removedItem = _images[index];
    setState(() {
      _images[index] = null;
    });
    widget.onImageRemoved?.call(index, removedItem);
    _notifyParent();
  }

  void _notifyParent() {
    final List<XFile> currentImages = _images
        .whereType<XFile>()
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
            final image = _images[index];
            Widget content;

            if (image == null) {
              content = _AddImageButton(
                onTap: () => _pickImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                iconSize: iconSize,
                padding: internalPadding,
              );
            } else if (image is XFile) {
              content = _ImagePreview(
                imageFile: File(image.path),
                onRemove: () => _removeImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
              );
            } else if (image is String && image.isNotEmpty) {
              content = _ImagePreview(
                imageUrl: image,
                onRemove: () => _removeImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
              );
            } else {
              content = _AddImageButton(
                onTap: () => _pickImage(index),
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                iconSize: iconSize,
                padding: internalPadding,
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
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onRemove;
  final double itemWidth;
  final double itemHeight;

  const _ImagePreview({
    this.imageFile,
    this.imageUrl,
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
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.cover)
                : (imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        )
                      : const SizedBox.shrink()),
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
