import 'dart:io';

import 'package:chat2date/components/design_system/feedback/ds_status_modal.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadGrid extends StatefulWidget {
  final Function(List<XFile> images)? onImagesChanged;
  final Function(int index, dynamic removedItem)? onImageRemoved;
  final double spacing;
  final double runSpacing;
  final List<String> imageUser;
  final int maxImages;
  final double itemWidth;
  final double itemHeight;
  final bool isHorizontal;
  final Color addTileColor;
  final Color addIconColor;
  final double tileRadius;
  final bool allowEditing;

  const ImageUploadGrid({
    super.key,
    this.isHorizontal = false,
    this.maxImages = 6,
    this.itemWidth = 119,
    this.itemHeight = 120,
    this.onImagesChanged,
    this.spacing = 12.0,
    this.runSpacing = 50.0,
    this.imageUser = const [],
    this.onImageRemoved,
    this.addTileColor = const Color(0xFFF7FAFE),
    this.addIconColor = const Color(0xFF94A3B8),
    this.tileRadius = 10,
    this.allowEditing = true,
  });

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  late List<dynamic> _images = List.filled(widget.maxImages, null);
  final ImagePicker _picker = ImagePicker();
  int? _draggingIndex;
  int? _pressedIndex;

  int get _filledCount => _images.where((image) => image != null).length;
  int get _remainingSlots => widget.maxImages - _filledCount;

  @override
  void initState() {
    super.initState();
    _initImages();
  }

  void _initImages() {
    _images = _buildImagesWithServerPhotos(
      widget.imageUser,
      preserveLocalFiles: false,
    );
  }

  @override
  void didUpdateWidget(covariant ImageUploadGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imageUser, widget.imageUser)) {
      setState(() {
        _images = _buildImagesWithServerPhotos(
          widget.imageUser,
          preserveLocalFiles: true,
        );
      });
      _notifyParent();
    }
  }

  List<dynamic> _buildImagesWithServerPhotos(
    List<String> serverPhotos, {
    required bool preserveLocalFiles,
  }) {
    final List<XFile> localFiles = preserveLocalFiles
        ? _images.whereType<XFile>().toList()
        : <XFile>[];

    final List<dynamic> nextImages = List<dynamic>.filled(widget.maxImages, null);
    int slot = 0;

    for (final url in serverPhotos) {
      if (slot >= nextImages.length) break;
      if (url.isNotEmpty) {
        nextImages[slot] = url;
        slot++;
      }
    }

    for (final file in localFiles) {
      if (slot >= nextImages.length) break;
      nextImages[slot] = file;
      slot++;
    }

    return nextImages;
  }

  // ✨ เลือกรูปภาพ - รองรับหลายรูปจากคลัง หรือ 1 รูปจากกล้อง
  Future<void> _pickImage(int index) async {
    if (!widget.allowEditing) return;
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
    final remainingSlots = _remainingSlots;

    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'เลือกรูปภาพได้อีก $remainingSlots/${widget.maxImages}',
                  style: const TextStyle(
                    color: TextColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 22 / 16,
                  ),
                ),
                const SizedBox(height: 16),
                _ImageSourceActionTile(
                  icon: Icons.photo_library_rounded,
                  label: 'เลือกจากคลังรูป',
                  subtitle: remainingSlots == 1
                      ? 'เหลือเพิ่มได้อีก 1 รูป'
                      : 'เหลือเพิ่มได้อีก $remainingSlots รูป',
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                const SizedBox(height: 10),
                _ImageSourceActionTile(
                  icon: Icons.photo_camera_rounded,
                  label: 'ถ่ายภาพตอนนี้',
                  subtitle: 'เพิ่มได้ครั้งละ 1 รูป',
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✨ แสดง Dialog เมื่อเต็มแล้ว
  void _showMaxImagesDialog() {
    DsStatusModal.show(
      context,
      type: DsStatusModalType.warning,
      title: 'เลือกรูปครบแล้ว',
      message: 'คุณเลือกครบ ${widget.maxImages} รูปแล้ว กรุณาลบรูปเก่าออกก่อน',
    );
  }

  // ✨ แสดง Dialog เมื่อเลือกรูปเกิน
  void _showTooManyImagesDialog(int available, int selected) {
    DsStatusModal.show(
      context,
      type: DsStatusModalType.warning,
      title: 'เลือกรูปเกิน ${widget.maxImages} รูป',
      message:
          'คุณเลือกมา $selected รูป แต่เหลือได้อีก $available รูป ระบบจะใช้ $available รูปแรกจากชุดล่าสุดเท่านั้น',
      duration: const Duration(seconds: 3),
    );
  }

  void _removeImage(int index) {
    if (!widget.allowEditing) return;
    final removedItem = _images[index];
    setState(() {
      _images[index] = null;
      _images = [
        ..._images.where((image) => image != null),
        ...List<dynamic>.filled(widget.maxImages - (_images.where((image) => image != null).length), null),
      ];
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

  void _reorderImage(int from, int to) {
    if (!widget.allowEditing || from == to) return;
    final filledImages = _images.where((image) => image != null).toList();
    if (from < 0 || from >= filledImages.length) return;

    final movedItem = filledImages.removeAt(from);
    final insertIndex = to.clamp(0, filledImages.length);
    filledImages.insert(insertIndex, movedItem);

    setState(() {
      _images = [
        ...filledImages,
        ...List<dynamic>.filled(widget.maxImages - filledImages.length, null),
      ];
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    double itemWidth = widget.itemWidth;
    double itemHeight = widget.itemHeight;
    double iconSize = 32;
    double internalPadding = widget.isHorizontal ? 0 : 40;
    double spacing = widget.isHorizontal ? 36.7 : widget.spacing;
    double runSpacing = widget.isHorizontal ? 16.0 : widget.runSpacing;

    if (isTablet) {
      itemWidth = 180;
      itemHeight = 182;
      iconSize = 48;
      internalPadding = 60;
      spacing = 20;
      runSpacing = 70;
    }

    final int crossAxisCount = widget.isHorizontal ? 3 : 2;
    final double calculatedWidth =
        (itemWidth * crossAxisCount) + (spacing * (crossAxisCount - 1));

    return Center(
      child: SizedBox(
        width: calculatedWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: WrapAlignment.start,
          children: List.generate(widget.maxImages, (index) {
            final image = _images[index];
            Widget content;

            if (image == null) {
              content = _AddImageButton(
                onTap: widget.allowEditing ? () => _pickImage(index) : null,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                iconSize: iconSize,
                padding: internalPadding,
                tileColor: widget.addTileColor,
                iconColor: widget.addIconColor,
                radius: widget.tileRadius,
                enabled: widget.allowEditing,
              );
            } else if (image is XFile) {
              content = _ImagePreview(
                imageFile: File(image.path),
                onRemove: widget.allowEditing ? () => _removeImage(index) : null,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                radius: widget.tileRadius,
                onOpen: () => _showImagePreview(file: File(image.path)),
              );
            } else if (image is String && image.isNotEmpty) {
              content = _ImagePreview(
                imageUrl: image,
                onRemove: widget.allowEditing ? () => _removeImage(index) : null,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                radius: widget.tileRadius,
                onOpen: () => _showImagePreview(imageUrl: image),
              );
            } else {
              content = _AddImageButton(
                onTap: widget.allowEditing ? () => _pickImage(index) : null,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                iconSize: iconSize,
                padding: internalPadding,
                tileColor: widget.addTileColor,
                iconColor: widget.addIconColor,
                radius: widget.tileRadius,
                enabled: widget.allowEditing,
              );
            }
            Widget slotChild = SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: content,
            );

            if (image != null && widget.allowEditing) {
              slotChild = Draggable<int>(
                data: index,
                onDragStarted: () => setState(() {
                  _draggingIndex = index;
                  _pressedIndex = null;
                }),
                onDragEnd: (_) => setState(() {
                  _draggingIndex = null;
                  _pressedIndex = null;
                }),
                onDraggableCanceled: (_, __) =>
                    setState(() {
                      _draggingIndex = null;
                      _pressedIndex = null;
                    }),
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: Opacity(opacity: 0.92, child: content),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: content,
                  ),
                ),
                child: Listener(
                  onPointerDown: (_) => setState(() => _pressedIndex = index),
                  onPointerUp: (_) => setState(() => _pressedIndex = null),
                  onPointerCancel: (_) => setState(() => _pressedIndex = null),
                  child: AnimatedScale(
                    scale: _pressedIndex == index ? 0.96 : 1,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    child: slotChild,
                  ),
                ),
              );
            }

            return DragTarget<int>(
              onWillAcceptWithDetails: (details) =>
                  widget.allowEditing &&
                  details.data != index &&
                  _images[details.data] != null,
              onAcceptWithDetails: (details) {
                _reorderImage(details.data, index);
                setState(() => _draggingIndex = null);
              },
              builder: (context, candidateData, rejectedData) {
                final isActiveTarget =
                    candidateData.isNotEmpty &&
                    widget.allowEditing &&
                    _draggingIndex != null &&
                    _draggingIndex != index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  width: itemWidth,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.tileRadius),
                    border: isActiveTarget
                        ? Border.all(
                            color: AppColors.brandPrimary,
                            width: 1.5,
                          )
                        : null,
                  ),
                  padding: isActiveTarget ? const EdgeInsets.all(2) : EdgeInsets.zero,
                  child: slotChild,
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showImagePreview({File? file, String? imageUrl}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Stack(
              children: [
                InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: file != null
                        ? Image.file(file, fit: BoxFit.contain)
                        : Image.network(imageUrl!, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageSourceActionTile extends StatefulWidget {
  const _ImageSourceActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_ImageSourceActionTile> createState() => _ImageSourceActionTileState();
}

class _ImageSourceActionTileState extends State<_ImageSourceActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.brandPrimary.withValues(alpha: 0.06)
                  : InputColors.backgroundDisabled,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pressed ? AppColors.brandPrimary : InputColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: TextColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: TextColors.supportText,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _pressed
                      ? AppColors.brandPrimary
                      : TextColors.supportText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double itemWidth;
  final double itemHeight;
  final double iconSize;
  final double padding;
  final Color tileColor;
  final Color iconColor;
  final double radius;
  final bool enabled;

  const _AddImageButton({
    required this.onTap,
    required this.itemWidth,
    required this.itemHeight,
    required this.iconSize,
    required this.padding,
    required this.tileColor,
    required this.iconColor,
    required this.radius,
    required this.enabled,
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
          color: enabled
              ? tileColor
              : tileColor.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Icon(
          Icons.add,
          color: enabled ? iconColor : TextColors.disabled,
          size: iconSize,
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback? onRemove;
  final VoidCallback onOpen;
  final double itemWidth;
  final double itemHeight;
  final double radius;

  const _ImagePreview({
    this.imageFile,
    this.imageUrl,
    required this.onRemove,
    required this.onOpen,
    required this.itemWidth,
    required this.itemHeight,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: itemWidth,
      height: itemHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
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
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              ignoring: onRemove == null,
              child: AnimatedOpacity(
                opacity: onRemove == null ? 0 : 1,
                duration: const Duration(milliseconds: 120),
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
            ),
          ),
        ],
      ),
    );
  }
}
