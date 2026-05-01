// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_bank_details/agent_bank_details_screen.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_home/agent_home_controller/agent_home_controller.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _fmt     = NumberFormat('#,###');
final _dateFmt = DateFormat('MMM d, y');
final _progressColor = AlwaysStoppedAnimation<Color>(AppColors.primaryThemeColor);
final _cardShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))];
final _tileShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))];

class AgentEarningsView extends StatelessWidget {
  const AgentEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AgentHomeController>(
      id: 'jobs',
      builder: (ctrl) {
        final totalEarnings = ctrl.agentData?.totalEarnings ?? 0.0;
        final pendingPayout = ctrl.agentData?.pendingPayout ?? 0.0;
        final totalJobs     = ctrl.agentData?.totalJobsCompleted ?? 0;
        final rating        = ctrl.agentData?.rating ?? 0.0;
        final isNigeria     = ctrl.agentData?.country != 'USA';
        final bankDetails   = ctrl.agentData?.bankDetails;
        final completedJobs = ctrl.completedJobs;

        // ── Fixed layout: header (never collapses) + scrollable body ──────
        return Column(
          children: [
            // ── Static teal header — does NOT scroll ─────────────────────
            Container(
              width: double.infinity,
              color: AppColors.primaryThemeColor,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  Text('Total Earned',
                      style: AppStyles.subStringStyle(
                          14, AppColors.plainWhite.withValues(alpha: 0.8))),
                  verticalSpacer(4),
                  Text(
                    isNigeria
                        ? '₦${_fmt.format(totalEarnings)}'
                        : '\$${totalEarnings.toStringAsFixed(2)}',
                    style: AppStyles.keyStringStyle(36, AppColors.plainWhite),
                  ),
                  verticalSpacer(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statPill(Icons.check_circle_outline,
                          '$totalJobs', 'Jobs Done'),
                      const SizedBox(width: 16),
                      _statPill(
                          Icons.star_outline,
                          totalJobs == 0 ? '--' : rating.toStringAsFixed(1),
                          'Rating'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Payout card ───────────────────────────────────────
                    _payoutCard(
                      context,
                      pendingPayout: pendingPayout,
                      isNigeria: isNigeria,
                      bankDetails: bankDetails,
                      agentData: ctrl.agentData,
                    ),
                    verticalSpacer(16),

                    // ── Rating card ───────────────────────────────────────
                    _ratingCard(rating, totalJobs),
                    verticalSpacer(20),

                    // ── Earnings history ──────────────────────────────────
                    Text('Earnings History',
                        style: AppStyles.keyStringStyle(16, AppColors.fullBlack)),
                    verticalSpacer(12),
                    if (completedJobs.isEmpty)
                      _emptyState()
                    else
                      ...completedJobs.map((j) => _earningsTile(j, isNigeria)),
                    verticalSpacer(20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Stat pill ─────────────────────────────────────────────────────────────
  Widget _statPill(IconData icon, String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.plainWhite.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.plainWhite, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppStyles.keyStringStyle(15, AppColors.plainWhite)),
                Text(label,
                    style: AppStyles.subStringStyle(
                        11, AppColors.plainWhite.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      );

  // ── Payout + bank card ────────────────────────────────────────────────────
  Widget _payoutCard(
    BuildContext context, {
    required double pendingPayout,
    required bool isNigeria,
    required bankDetails,
    required agentData,
  }) {
    final hasPending    = pendingPayout > 0;
    final hasBankDetails = bankDetails != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Balance row ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasPending
                  ? const Color(0xFFFFF8EC)
                  : const Color(0xFFF0FAF4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: hasPending
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : AppColors.normalGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: hasPending
                        ? const Color(0xFFF59E0B)
                        : AppColors.normalGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasPending ? 'Available to withdraw' : 'Available balance',
                        style: AppStyles.subStringStyle(
                          12,
                          hasPending ? const Color(0xFFB45309) : AppColors.darkGray,
                        ),
                      ),
                      verticalSpacer(2),
                      Text(
                        isNigeria
                            ? '₦${_fmt.format(pendingPayout)}'
                            : '\$${pendingPayout.toStringAsFixed(2)}',
                        style: AppStyles.keyStringStyle(
                          26,
                          hasPending
                              ? const Color(0xFF92400E)
                              : AppColors.darkGray,
                        ),
                      ),
                      if (!hasPending)
                        Text(
                          'Complete jobs and get rated to earn',
                          style: AppStyles.subStringStyle(11, AppColors.darkGray),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Bank account section ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Icon(Icons.account_balance_outlined,
                        color: AppColors.darkGray, size: 16),
                    const SizedBox(width: 6),
                    Text('Payout Account',
                        style: AppStyles.subStringStyle(12, AppColors.darkGray)),
                    const Spacer(),
                    if (hasBankDetails)
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AgentBankDetailsScreen(
                                  existing: bankDetails),
                            ),
                          );
                          await Get.find<AgentHomeController>().refreshAgentData();
                        },
                        child: Text('Change',
                            style: AppStyles.subStringStyle(
                                13, AppColors.primaryThemeColor)),
                      ),
                  ],
                ),
                verticalSpacer(10),

                if (hasBankDetails) ...[
                  // ── Saved bank account details ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryThemeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.credit_card_rounded,
                              color: AppColors.primaryThemeColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bankDetails.bankName,
                                  style: AppStyles.regularStringStyle(
                                      14, AppColors.fullBlack)),
                              Text(
                                '${bankDetails.accountNumber}',
                                style: AppStyles.subStringStyle(
                                    13, AppColors.darkGray),
                              ),
                              Text(
                                bankDetails.accountName,
                                style: AppStyles.regularStringStyle(
                                    13, AppColors.primaryThemeColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.verified_rounded,
                            color: AppColors.normalGreen, size: 20),
                      ],
                    ),
                  ),
                  verticalSpacer(14),

                  // ── Withdraw button — always visible, disabled at ₦0 ───
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        hasPending
                            ? Icons.send_rounded
                            : Icons.account_balance_wallet_outlined,
                        size: 18,
                      ),
                      label: Text(
                        hasPending
                            ? 'Withdraw ${isNigeria ? '₦${_fmt.format(pendingPayout)}' : '\$${pendingPayout.toStringAsFixed(2)}'}'
                            : 'No balance to withdraw',
                      ),
                      onPressed: hasPending
                          ? () => _confirmWithdrawal(
                              context, agentData, pendingPayout, isNigeria)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryThemeColor,
                        foregroundColor: AppColors.plainWhite,
                        disabledBackgroundColor:
                            AppColors.lightGray.withValues(alpha: 0.5),
                        disabledForegroundColor: AppColors.darkGray,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  if (!hasPending) ...[
                    verticalSpacer(8),
                    Center(
                      child: Text(
                        'Your balance updates after a client rates your job.',
                        textAlign: TextAlign.center,
                        style: AppStyles.subStringStyle(12, AppColors.darkGray),
                      ),
                    ),
                  ],

                ] else ...[
                  // ── No bank account saved yet ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: const Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Add a bank account to receive your earnings. '
                            'Payouts are processed every Friday.',
                            style: AppStyles.subStringStyle(13, AppColors.darkGray),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacer(12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Bank Account'),
                      onPressed: () async {
                        final added = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgentBankDetailsScreen(),
                          ),
                        );
                        if (added == true) {
                          await Get.find<AgentHomeController>().refreshAgentData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryThemeColor,
                        foregroundColor: AppColors.plainWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Withdrawal confirmation dialog ────────────────────────────────────────
  void _confirmWithdrawal(
      BuildContext context, agentData, double amount, bool isNigeria) {
    final formatted = isNigeria
        ? '₦${_fmt.format(amount)}'
        : '\$${amount.toStringAsFixed(2)}';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Withdrawal',
            style: AppStyles.keyStringStyle(17, AppColors.fullBlack)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are requesting a withdrawal of:',
                style: AppStyles.subStringStyle(13, AppColors.darkGray)),
            verticalSpacer(8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryThemeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatted,
                      style: AppStyles.keyStringStyle(
                          22, AppColors.primaryThemeColor)),
                  verticalSpacer(4),
                  Text(
                    'To: ${agentData?.bankDetails?.accountName ?? ''}',
                    style: AppStyles.subStringStyle(12, AppColors.darkGray),
                  ),
                  Text(
                    '${agentData?.bankDetails?.bankName ?? ''} — '
                    '${agentData?.bankDetails?.accountNumber ?? ''}',
                    style: AppStyles.subStringStyle(12, AppColors.darkGray),
                  ),
                ],
              ),
            ),
            verticalSpacer(10),
            Text(
              'Your admin will process this within the week.',
              style: AppStyles.subStringStyle(12, AppColors.darkGray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppStyles.regularStringStyle(14, AppColors.darkGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (agentData?.agentId == null || agentData?.bankDetails == null) return;
              await AgentFirebaseService().requestPayout(
                agentId: agentData!.agentId!,
                agentName: agentData!.name ?? 'Agent',
                amount: amount,
                bankDetails: agentData!.bankDetails!.toJson(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryThemeColor,
              foregroundColor: AppColors.plainWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Confirm',
                style: AppStyles.regularStringStyle(14, AppColors.plainWhite)),
          ),
        ],
      ),
    );
  }

  // ── Rating card ────────────────────────────────────────────────────────────
  Widget _ratingCard(double rating, int totalJobs) {
    final hasRating = totalJobs > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded,
                  color: hasRating ? Colors.amber : AppColors.darkGray, size: 22),
              const SizedBox(width: 8),
              Text('Your Rating',
                  style: AppStyles.keyStringStyle(15, AppColors.fullBlack)),
              const Spacer(),
              Text(
                hasRating ? rating.toStringAsFixed(1) : '--',
                style: AppStyles.keyStringStyle(
                    22,
                    hasRating ? AppColors.primaryThemeColor : AppColors.darkGray),
              ),
              if (hasRating)
                Text(' / 5.0',
                    style: AppStyles.subStringStyle(13, AppColors.darkGray)),
            ],
          ),
          verticalSpacer(12),
          if (hasRating) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rating / 5.0,
                minHeight: 10,
                backgroundColor:
                    AppColors.primaryThemeColor.withValues(alpha: 0.1),
                valueColor: _progressColor,
              ),
            ),
            verticalSpacer(8),
          ],
          Text(
            hasRating
                ? 'Based on $totalJobs completed '
                  '${totalJobs == 1 ? 'job' : 'jobs'}. '
                  'Customers rate you after each job.'
                : 'Complete your first job to start receiving ratings.',
            style: AppStyles.subStringStyle(12, AppColors.darkGray),
          ),
          if (hasRating) ...[
            verticalSpacer(10),
            Row(
              children: List.generate(5, (i) {
                final filled = i < rating.floor();
                final half   = !filled && i < rating;
                return Icon(
                  half ? Icons.star_half_rounded : Icons.star_rounded,
                  color: filled || half ? Colors.amber : Colors.grey.shade300,
                  size: 24,
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ── Per-job earnings tile ─────────────────────────────────────────────────
  Widget _earningsTile(AgentJobModel job, bool isNigeria) {
    final booking   = job.booking;
    final rawAmount = job.agentEarnings ??
        (isNigeria
            ? ((booking?.service?.baseCost ?? 0) * 0.60) - 500
            : (booking?.service?.usdCost ?? 0) * 0.60);
    final amount    = (rawAmount as double).clamp(0.0, double.infinity);
    final formatted = isNigeria
        ? '₦${_fmt.format(amount)}'
        : '\$${amount.toStringAsFixed(2)}';
    final date = booking?.dateTime != null
        ? _dateFmt.format(booking!.dateTime!)
        : 'Date unknown';
    final review = job.clientReview;
    final stars  = job.rating?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _tileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.normalGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.normalGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${booking?.service?.name ?? 'Cleaning'} Service',
                        style: AppStyles.regularStringStyle(
                            14, AppColors.fullBlack)),
                    Text(date,
                        style: AppStyles.subStringStyle(12, AppColors.darkGray)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatted,
                      style: AppStyles.keyStringStyle(
                          15, AppColors.primaryThemeColor)),
                  if (stars > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(stars,
                        (_) => const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 12)),
                    ),
                ],
              ),
            ],
          ),
          if (review != null && review.isNotEmpty) ...[
            verticalSpacer(10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: AppColors.darkGray, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(review,
                        style: AppStyles.subStringStyle(12, AppColors.darkGray)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 56, color: AppColors.lightGray),
              verticalSpacer(12),
              Text('No earnings yet',
                  style: AppStyles.subStringStyle(15, AppColors.darkGray)),
              verticalSpacer(6),
              Text('Complete jobs to start earning',
                  style: AppStyles.subStringStyle(13, AppColors.darkGray)),
            ],
          ),
        ),
      );
}
