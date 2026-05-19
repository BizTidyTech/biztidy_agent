// ignore_for_file: prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_home/agent_home_controller/agent_home_controller.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _scheduleCardShadow = [
  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
];

class AgentScheduleView extends StatefulWidget {
  const AgentScheduleView({super.key});

  @override
  State<AgentScheduleView> createState() => _AgentScheduleViewState();
}

class _AgentScheduleViewState extends State<AgentScheduleView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Cached formatters — created once, not on every rebuild
  static final _monthYearFmt = DateFormat('MMMM yyyy');
  static final _monthDayFmt  = DateFormat('MMMM d');
  static final _timeFmt      = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: GetBuilder<AgentHomeController>(
        id: 'jobs', // rebuilds when job stream fires
        builder: (controller) {
          final allUpcoming = [
            ...controller.pendingJobs,
            ...controller.activeJobs,
          ];
          final jobsOnSelected = _jobsForDate(allUpcoming, _selectedDate);
          final datesWithJobs = _getDatesWithJobs(allUpcoming);

          // No Scaffold — lives inside the outer IndexedStack Scaffold
          return Container(
            color: const Color(0xFFF5F6FA),
            child: Column(
              children: [
                // ── Custom AppBar ─────────────────────────────────────────
                Material(
                  color: AppColors.primaryThemeColor,
                  elevation: 0,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Center(
                        child: Text('Schedule',
                            style: AppStyles.keyStringStyle(
                                18, AppColors.plainWhite)),
                      ),
                    ),
                  ),
                ),
                // ── Calendar header ───────────────────────────────────────
                Container(
                  color: AppColors.primaryThemeColor,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left,
                                color: AppColors.plainWhite),
                            onPressed: () => setState(() {
                              _focusedMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month - 1);
                            }),
                          ),
                          Text(
                            _monthYearFmt.format(_focusedMonth),
                            style: AppStyles.keyStringStyle(
                                16, AppColors.plainWhite),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right,
                                color: AppColors.plainWhite),
                            onPressed: () => setState(() {
                              _focusedMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month + 1);
                            }),
                          ),
                        ],
                      ),
                      Row(
                        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                            .map((d) => Expanded(
                                  child: Center(
                                    child: Text(d,
                                        style: AppStyles.subStringStyle(
                                            11,
                                            AppColors.plainWhite
                                                .withValues(alpha: 0.7))),
                                  ),
                                ))
                            .toList(),
                      ),
                      verticalSpacer(6),
                      _buildCalendarGrid(datesWithJobs),
                    ],
                  ),
                ),
                // ── Jobs for selected date ────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSameDay(_selectedDate, DateTime.now())
                              ? 'Today\'s Jobs'
                              : 'Jobs on ${_monthDayFmt.format(_selectedDate)}',
                          style: AppStyles.keyStringStyle(
                              15, AppColors.fullBlack),
                        ),
                        verticalSpacer(12),
                        Expanded(
                          child: jobsOnSelected.isEmpty
                              ? _emptyState()
                              : ListView.builder(
                                  itemCount: jobsOnSelected.length,
                                  itemBuilder: (_, i) =>
                                      _scheduleJobCard(jobsOnSelected[i]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(Set<String> datesWithJobs) {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startOffset = firstDay.weekday % 7;
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNum = cellIndex - startOffset + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 36));
            }
            final date = DateTime(
                _focusedMonth.year, _focusedMonth.month, dayNum);
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final hasJob =
                datesWithJobs.contains(_dateKey(date));

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.plainWhite
                        : isToday
                            ? AppColors.plainWhite.withValues(alpha: 0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: AppStyles.regularStringStyle(
                          13,
                          isSelected
                              ? AppColors.primaryThemeColor
                              : AppColors.plainWhite,
                        ),
                      ),
                      if (hasJob)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryThemeColor
                                  : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _scheduleJobCard(AgentJobModel job) {
    final booking = job.booking;
    final time = booking?.dateTime != null
        ? _timeFmt.format(booking!.dateTime!)
        : 'Time TBD';
    final isActive = job.status == 'in_progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.plainWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primaryThemeColor.withValues(alpha: 0.4)
              : Colors.grey.shade200,
        ),
        boxShadow: _scheduleCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryThemeColor.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive ? Icons.play_circle_outline : Icons.pending_outlined,
              color:
                  isActive ? AppColors.primaryThemeColor : Colors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking?.service?.name ?? 'Cleaning'} Service',
                  style:
                      AppStyles.regularStringStyle(14, AppColors.fullBlack),
                ),
                verticalSpacer(2),
                Text(
                  booking?.customer?.name ?? 'Client',
                  style: AppStyles.subStringStyle(12, AppColors.darkGray),
                ),
                verticalSpacer(2),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: AppColors.darkGray),
                    const SizedBox(width: 4),
                    Text(time,
                        style: AppStyles.subStringStyle(
                            12, AppColors.darkGray)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryThemeColor.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Pending',
              style: AppStyles.subStringStyle(
                  11,
                  isActive
                      ? AppColors.primaryThemeColor
                      : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined,
                size: 56, color: AppColors.darkGray),
            verticalSpacer(12),
            Text('No jobs on this day',
                style: AppStyles.subStringStyle(15, AppColors.darkGray)),
          ],
        ),
      );

  List<AgentJobModel> _jobsForDate(
      List<AgentJobModel> jobs, DateTime date) {
    return jobs.where((job) {
      final dt = job.booking?.dateTime;
      if (dt == null) return false;
      return _isSameDay(dt, date);
    }).toList();
  }

  Set<String> _getDatesWithJobs(List<AgentJobModel> jobs) {
    return jobs
        .where((j) => j.booking?.dateTime != null)
        .map((j) => _dateKey(j.booking!.dateTime!))
        .toSet();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
