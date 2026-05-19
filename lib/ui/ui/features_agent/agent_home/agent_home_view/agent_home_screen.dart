// ignore_for_file: prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_earnings/agent_earnings_view/agent_earnings_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_home/agent_home_controller/agent_home_controller.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_view/agent_active_job_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_notifications/agent_notifications_controller/agent_notifications_controller.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_notifications/agent_notifications_view/agent_notifications_view.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_profile/agent_profile_view/agent_profile_screen.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_schedule/agent_schedule_view/agent_schedule_view.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Static empty-state widgets declared as top-level constants — Flutter
// short-circuits diffing when it sees the identical const instance.
const _emptyPending = _EmptyState(
  icon: Icons.inbox_outlined,
  message: 'No new jobs right now',
  sub: 'Go online to receive jobs',
);
const _emptyActive = _EmptyState(icon: Icons.inbox_outlined, message: 'No active jobs');
const _emptyCompleted = _EmptyState(icon: Icons.inbox_outlined, message: 'No completed jobs yet');
final _dateFmt = DateFormat('MMM d, y • h:mm a');
final _currencyFmt = NumberFormat('#,###');
final _bottomNavShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))];

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(AgentHomeController());
  final notifController = Get.put(AgentNotificationsController());
  late TabController _tabController;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cached greeting — only recomputed when agent name changes, not on every stream event
  String? _cachedGreeting;
  String? _cachedGreetingName;

  String _greeting() {
    final name = controller.agentData?.name?.split(' ').first ?? 'Agent';
    if (_cachedGreetingName != name) {
      _cachedGreetingName = name;
      final hour = DateTime.now().hour;
      if (hour < 12) {
        _cachedGreeting = 'Good morning, $name! 👋';
      } else if (hour < 17) {
        _cachedGreeting = 'Good afternoon, $name! 👋';
      } else {
        _cachedGreeting = 'Good evening, $name! 👋';
      }
    }
    return _cachedGreeting!;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.plainWhite,
      ),
      child: Scaffold(
        backgroundColor: AppColors.plainWhite,
        // IndexedStack keeps all tabs alive — no teardown/rebuild on tab switch
        body: IndexedStack(
          index: _currentNavIndex,
          children: [
            GetBuilder<AgentHomeController>(builder: (_) => _jobsBody()),
            const AgentEarningsView(),
            const AgentScheduleView(),
            const AgentProfileScreen(),
          ],
        ),
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _bottomNav() {
    return GetBuilder<AgentNotificationsController>(
      builder: (notif) {
        return Container(
          decoration: BoxDecoration(boxShadow: _bottomNavShadow),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: (index) => setState(() => _currentNavIndex = index),
            selectedItemColor: AppColors.primaryThemeColor,
            unselectedItemColor: AppColors.darkGray,
            backgroundColor: AppColors.plainWhite,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: AppStyles.subStringStyle(
                11, AppColors.primaryThemeColor),
            unselectedLabelStyle:
                AppStyles.subStringStyle(11, AppColors.darkGray),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'Jobs',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'Earnings',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: _profileNavIcon(active: false),
                activeIcon: _profileNavIcon(active: true),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileNavIcon({required bool active}) {
    final photo = controller.agentData?.photoUrl;
    if (photo != null && photo.isNotEmpty) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: active
              ? Border.all(color: AppColors.primaryThemeColor, width: 2)
              : null,
        ),
        child: ClipOval(
          // Use cacheWidth to avoid decoding a full-res image for a 26px icon
          child: Image.network(
            photo,
            fit: BoxFit.cover,
            cacheWidth: 80,
            cacheHeight: 80,
            gaplessPlayback: true, // prevents flicker on rebuild
          ),
        ),
      );
    }
    return Icon(active ? Icons.person : Icons.person_outline);
  }

  // ── Jobs Body ─────────────────────────────────────────────────────────────
  Widget _jobsBody() {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          // Custom AppBar (avoids nested Scaffold)
          Material(
            color: AppColors.primaryThemeColor,
            elevation: 0,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: controller.showLoading
                          ? Text('BizTidy Agent',
                              style: AppStyles.keyStringStyle(18, AppColors.plainWhite))
                          : Text(
                              _greeting(),
                              style: AppStyles.regularStringStyle(16, AppColors.plainWhite),
                            ),
                    ),
                    GetBuilder<AgentNotificationsController>(
                      builder: (notif) => Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_outlined,
                                color: AppColors.plainWhite),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => DraggableScrollableSheet(
                                  initialChildSize: 0.75,
                                  maxChildSize: 0.95,
                                  minChildSize: 0.4,
                                  builder: (ctx, scroll) => Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF5F6FA),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: const AgentNotificationsView(),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (notif.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.coolRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${notif.unreadCount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (controller.showLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            // Header only rebuilds when agentData changes (toggle, background refresh)
            GetBuilder<AgentHomeController>(
              id: 'header',
              builder: (_) => _headerCard(),
            ),
            // New job alert banner
            GetBuilder<AgentHomeController>(
              id: 'jobs',
              builder: (_) => _newJobBanner(),
            ),
            // Tab bar and content rebuild when jobs stream fires
            GetBuilder<AgentHomeController>(
              id: 'jobs',
              builder: (_) => _tabBar(),
            ),
            Expanded(
              child: GetBuilder<AgentHomeController>(
                id: 'jobs',
                builder: (_) => _tabContent(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _newJobBanner() {
    final pending = controller.pendingJobs;
    if (pending.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _tabController.animateTo(0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF1B8A2E),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${pending.length} new job${pending.length > 1 ? 's' : ''} available — tap to view',
              style: AppStyles.regularStringStyle(13, Colors.white),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white, size: 18),
        ]),
      ),
    );
  }

  Widget _headerCard() {
    final rating = controller.agentData?.rating ?? 5.0;
    final totalJobs = controller.agentData?.totalJobsCompleted ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 3),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.plainWhite,
                  backgroundImage: (controller.agentData?.photoUrl != null &&
                          controller.agentData!.photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(controller.agentData!.photoUrl!)
                      : null,
                  child: (controller.agentData?.photoUrl == null ||
                          controller.agentData!.photoUrl!.isEmpty)
                      ? Icon(Icons.person,
                          color: AppColors.primaryThemeColor, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating row — only show if agent has completed jobs
                    if (totalJobs > 0)
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < rating.floor()
                                  ? Icons.star_rounded
                                  : (i < rating
                                      ? Icons.star_half_rounded
                                      : Icons.star_outline_rounded),
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${rating.toStringAsFixed(1)} ($totalJobs ${totalJobs == 1 ? 'job' : 'jobs'})',
                            style: AppStyles.subStringStyle(
                                12, AppColors.plainWhite),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No ratings yet',
                        style: AppStyles.subStringStyle(
                            12, AppColors.plainWhite.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
              ),
              // Online/Offline toggle
              GestureDetector(
                onTap: controller.toggleOnlineStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.isOnline
                        ? AppColors.normalGreen.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.isOnline
                          ? AppColors.normalGreen
                          : AppColors.plainWhite,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.isOnline
                              ? AppColors.normalGreen
                              : AppColors.plainWhite,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.isOnline ? 'Online' : 'Offline',
                        style: AppStyles.subStringStyle(
                            13, AppColors.plainWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          verticalSpacer(20),
          // Stats row
          Row(
            children: [
              _statBox(Icons.check_circle_outline,
                  '${controller.agentData?.totalJobsCompleted ?? 0}',
                  'Jobs Done'),
              const SizedBox(width: 10),
              _statBox(
                  Icons.account_balance_wallet_outlined,
                  controller.agentData?.totalEarnings != null
                      ? '₦${_currencyFmt.format(controller.agentData!.totalEarnings)}'
                      : '₦0',
                  'Total Earned'),
              const SizedBox(width: 10),
              _statBox(Icons.work_outline,
                  '${controller.pendingJobs.length}', 'Pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.plainWhite.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.plainWhite, size: 22),
            verticalSpacer(6),
            Text(value,
                style:
                    AppStyles.keyStringStyle(16, AppColors.plainWhite)),
            verticalSpacer(2),
            Text(label,
                style:
                    AppStyles.subStringStyle(11, AppColors.plainWhite)),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      color: AppColors.plainWhite,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryThemeColor,
        labelColor: AppColors.primaryThemeColor,
        unselectedLabelColor: AppColors.darkGray,
        labelStyle: AppStyles.regularStringStyle(
            13, AppColors.primaryThemeColor),
        tabs: [
          Tab(text: 'New (${controller.pendingJobs.length})'),
          Tab(text: 'Active (${controller.activeJobs.length})'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _tabContent() {
    return TabBarView(
      controller: _tabController,
      physics: const ClampingScrollPhysics(), // prevents overscroll fighting with ListViews inside
      children: [
        _jobsList(controller.pendingJobs, isPending: true),
        _jobsList(controller.activeJobs, isActive: true),
        _jobsList(controller.completedJobs),
      ],
    );
  }

  Widget _jobsList(List<AgentJobModel> jobs,
      {bool isPending = false, bool isActive = false}) {
    if (jobs.isEmpty) {
      if (isPending) {
        return controller.isOnline ? _emptyPending : const _EmptyState(
          icon: Icons.inbox_outlined,
          message: 'No new jobs right now',
          sub: 'Go online to receive jobs',
        );
      }
      if (isActive) return _emptyActive;
      return _emptyCompleted;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) =>
          _jobCard(jobs[index], isPending: isPending, isActive: isActive),
    );
  }

  Widget _jobCard(AgentJobModel job,
      {bool isPending = false, bool isActive = false}) {
    final booking = job.booking;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${booking?.service?.name ?? 'Cleaning'} Service',
                    style: AppStyles.regularStringStyle(
                        15, AppColors.fullBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _statusBadge(job.status ?? 'pending'),
              ],
            ),
            verticalSpacer(8),
            _jobInfoRow(Icons.person_outline,
                booking?.customer?.name ?? 'Client'),
            verticalSpacer(4),
            _jobInfoRow(Icons.location_on_outlined,
                booking?.locationAddress ?? 'Address not set'),
            verticalSpacer(4),
            _jobInfoRow(
              Icons.calendar_today_outlined,
              booking?.dateTime != null
                  ? _dateFmt.format(booking!.dateTime!)
                  : 'Date not set',
            ),
            verticalSpacer(4),
            _jobInfoRow(
              Icons.payments_outlined,
              booking?.country == 'USA'
                  ? '\$${booking?.service?.usdCost ?? 0}'
                  : '₦${_currencyFmt.format(booking?.service?.baseCost ?? 0)}',
            ),
            if (isPending) ...[
              verticalSpacer(14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.declineJob(job),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coolRed,
                        side: BorderSide(color: AppColors.coolRed),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.acceptJob(job),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryThemeColor,
                        foregroundColor: AppColors.plainWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
            if (isActive) ...[
              verticalSpacer(14),
              SizedBox(
                width: screenWidth(context),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Open Active Job'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AgentActiveJobView(job: job)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThemeColor,
                    foregroundColor: AppColors.plainWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _jobInfoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: AppColors.darkGray),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: AppStyles.subStringStyle(13, AppColors.darkGray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'New';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'in_progress':
        color = AppColors.primaryThemeColor;
        label = 'In Progress';
        break;
      case 'completed':
        color = AppColors.normalGreen;
        label = 'Completed';
        break;
      default:
        color = AppColors.darkGray;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: AppStyles.subStringStyle(11, color)),
    );
  }
}

/// Const-constructable empty state — Flutter reuses the exact same element
/// tree when it sees the same const instance, skipping rebuild entirely.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? sub;
  const _EmptyState({required this.icon, required this.message, this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.darkGray),
          const SizedBox(height: 12),
          Text(message,
              style: AppStyles.subStringStyle(15, AppColors.darkGray)),
          if (sub != null) ...[
            const SizedBox(height: 8),
            Text(sub!, style: AppStyles.subStringStyle(13, AppColors.darkGray)),
          ],
        ],
      ),
    );
  }
}
