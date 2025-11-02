import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LifestylesSelectionScreen extends StatefulWidget {
  const LifestylesSelectionScreen({super.key});

  @override
  State<LifestylesSelectionScreen> createState() =>
      _LifestylesSelectionScreenState();
}

class _LifestylesSelectionScreenState extends State<LifestylesSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ResponsiveContainer.form(
            children: [
              SizedBox(height: 70),
              DsTextField(
                supportText: 'ไลฟ์สไตล์',
                required: true,
                suffixIcon: Icons.search,
                onSuffixTap: () {
                  Navigator.pushNamed(context, '/lifestylesSelection');
                },
              ),
            ],
          ),

          Positioned(
            top: 50,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brandSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
