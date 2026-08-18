import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeadersWithStyles extends StatelessWidget {
  final List<Map<String, dynamic>> headers;

  const HeadersWithStyles({super.key, required this.headers});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(headers.length, (headerIndex) {
        final header = headers[headerIndex];
        final title = header['title'] as String;

        final allStyle = List<String>.from((header['style'] ?? []) as List);

        final style = allStyle.take(5).toList();

        final range = (header['range'] ?? 0.0) as double;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 94,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 3,
                      color: AppColors.brandPrimary200,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                constraints: BoxConstraints(minWidth: title == "สไตล์การท่องเที่ยว" ? 170 : 90, maxHeight: 48),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.lightPrimary,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              if (style.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(style.length, (tagIndex) {
                      final styleName = style[tagIndex];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.surfaceMuted,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: AppColors.nonSelected,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        constraints: const BoxConstraints(minWidth: 40),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/ui/icon_tag.svg',
                              width: 2,
                              height: 2,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              styleName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

              // Tags Wrap
              if (range != 0.0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minWidth: 60),
                    height: 48,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$range",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "km.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
