// ignore_for_file: must_be_immutable

import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';

Widget keyTextValue(
  BuildContext context,
  String keyText,
  String vaueText,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            "$keyText:",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.floatingHintStringStyleColored(
                16, AppColors.deepBlue),
          ),
        ),
        SizedBox(
          width: screenWidth(context) - 195,
          child: SelectableText(
            vaueText,
            style: AppStyles.regularStringStyle(16, AppColors.reviewValueColor),
          ),
        ),
      ],
    ),
  );
}
