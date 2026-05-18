import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Const-constructable loading indicator. Flutter reuses the same element tree
/// across rebuilds when it sees the identical const instance — no allocation.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryThemeColor,
        strokeWidth: 3,
      ),
    );
  }
}

// Backward-compatible function alias so existing call sites compile unchanged.
// Prefer `const LoadingWidget()` at new call sites.
Widget loadingWidget() => const LoadingWidget();
