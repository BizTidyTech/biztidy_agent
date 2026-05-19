import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_controller/agent_jobs_controller.dart';
import 'package:biztidy_agent_app/ui/features_agent/agent_jobs/agent_jobs_model/agent_job_model.dart';
import 'package:biztidy_agent_app/ui/shared/custom_button.dart';
import 'package:biztidy_agent_app/ui/shared/loading_widget.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

final _activeJobDateFmt = DateFormat('MMM d, y \u2022 h:mm a');
final _activeJobCurrencyFmt = NumberFormat('#,###');

class AgentActiveJobView extends StatefulWidget {
  const AgentActiveJobView({super.key, required this.job});
  final AgentJobModel job;

  @override
  State<AgentActiveJobView> createState() => _AgentActiveJobViewState();
}

class _AgentActiveJobViewState extends State<AgentActiveJobView> {
  final controller = Get.put(AgentJobsController());

  @override
  void initState() {
    super.initState();
    controller.selectJob(widget.job);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryThemeColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: GetBuilder<AgentJobsController>(
        builder: (_) {
          final job = controller.selectedJob;
          final booking = job?.booking;
          final isInProgress = job?.status == 'in_progress';

          return Scaffold(
            backgroundColor: AppColors.plainWhite,
            appBar: AppBar(
              backgroundColor: AppColors.primaryThemeColor,
              iconTheme: IconThemeData(color: AppColors.plainWhite),
              title: Text('Active Job',
                  style:
                      AppStyles.keyStringStyle(18, AppColors.plainWhite)),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Job info card ────────────────────────────────────────
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking?.service?.name ?? 'Cleaning'} Service',
                          style: AppStyles.regularStringStyle(
                              17, AppColors.fullBlack),
                        ),
                        verticalSpacer(12),
                        _infoRow('Client', booking?.customer?.name ?? '-'),
                        _infoRow('Phone',
                            booking?.customer?.phoneNumber ?? '-'),
                        _infoRow(
                            'Address', booking?.locationAddress ?? '-'),
                        _infoRow(
                          'Date & Time',
                          booking?.dateTime != null
                              ? _activeJobDateFmt.format(booking!.dateTime!)
                              : '-',
                        ),
                        _infoRow(
                          'Payment',
                          booking?.country == 'USA'
                              ? '\$${booking?.service?.usdCost ?? 0}'
                              : '₦${_activeJobCurrencyFmt.format(booking?.service?.baseCost ?? 0)}',
                        ),
                        _infoRow('Rooms', '${booking?.rooms ?? '-'}'),
                        _infoRow('Duration',
                            '${booking?.duration ?? '-'} hrs'),
                        if (booking?.additionalInfo?.isNotEmpty == true)
                          _infoRow('Notes', booking!.additionalInfo!),
                      ],
                    ),
                  ),
                  verticalSpacer(20),

                  // ── Step 1: Clock In ─────────────────────────────────────
                  if (!isInProgress) ...[
                    Text('Step 1: Clock In',
                        style: AppStyles.regularStringStyle(
                            15, AppColors.fullBlack)),
                    verticalSpacer(8),
                    Text(
                      'When you arrive at the client\'s location, tap Start Job to clock in.',
                      style:
                          AppStyles.subStringStyle(13, AppColors.darkGray),
                    ),
                    verticalSpacer(12),
                    controller.showLoading
                        ? loadingWidget()
                        : CustomButton(
                            buttonText: 'Start Job (Clock In)',
                            width: screenWidth(context),
                            color: AppColors.primaryThemeColor,
                            textcolor: AppColors.plainWhite,
                            onPressed: controller.startJob,
                          ),
                  ],

                  // ── Steps 2-4 (in progress) ──────────────────────────────
                  if (isInProgress) ...[
                    _mediaSection(
                      stepNumber: 2,
                      title: 'Before Photos & Videos',
                      subtitle:
                          'Capture key areas before cleaning — kitchen, bedroom, living room. '
                          'Videos up to 60 seconds.',
                      photoUrls: controller.beforePhotoUrls,
                      videoUrls: controller.beforeVideoUrls,
                      isBefore: true,
                    ),
                    verticalSpacer(20),

                    _mediaSection(
                      stepNumber: 3,
                      title: 'After Photos & Videos',
                      subtitle:
                          'Capture the same areas after cleaning to show the difference.',
                      photoUrls: controller.afterPhotoUrls,
                      videoUrls: controller.afterVideoUrls,
                      isBefore: false,
                    ),
                    verticalSpacer(28),

                    // ── Step 4: Complete ──────────────────────────────────
                    Text('Step 4: Complete Job',
                        style: AppStyles.regularStringStyle(
                            15, AppColors.fullBlack)),
                    verticalSpacer(8),
                    Text(
                      'Ensure the client is satisfied and after photos are uploaded before completing.',
                      style:
                          AppStyles.subStringStyle(13, AppColors.darkGray),
                    ),
                    verticalSpacer(12),
                    controller.showLoading
                        ? loadingWidget()
                        : CustomButton(
                            buttonText: 'Complete Job (Clock Out)',
                            width: screenWidth(context),
                            color: AppColors.normalGreen,
                            borderColor: AppColors.normalGreen,
                            textcolor: AppColors.plainWhite,
                            onPressed: () =>
                                controller.completeJob(context),
                          ),
                  ],
                  verticalSpacer(40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Media section (photos + videos) ─────────────────────────────────────────
  Widget _mediaSection({
    required int stepNumber,
    required String title,
    required String subtitle,
    required List<String> photoUrls,
    required List<String> videoUrls,
    required bool isBefore,
  }) {
    final allMedia = [
      ...photoUrls.map((u) => (url: u, isVideo: false)),
      ...videoUrls.map((u) => (url: u, isVideo: true)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step $stepNumber: $title',
            style: AppStyles.regularStringStyle(15, AppColors.fullBlack)),
        verticalSpacer(4),
        Text(subtitle,
            style: AppStyles.subStringStyle(13, AppColors.darkGray)),
        verticalSpacer(12),

        // ── Thumbnail row ────────────────────────────────────────────────
        if (allMedia.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allMedia.length,
              itemBuilder: (_, i) {
                final item = allMedia[i];
                return GestureDetector(
                  onTap: () => _openMedia(context, item.url,
                      isVideo: item.isVideo),
                  child: Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black12,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.isVideo
                              ? _MiniVideoThumb(url: item.url)
                              : Image.network(item.url,
                                  fit: BoxFit.cover,
                                  cacheWidth: 180,
                                  cacheHeight: 180,
                                  gaplessPlayback: true,
                                  loadingBuilder: (_, child, prog) =>
                                      prog == null
                                          ? child
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2))),
                        ),
                        if (item.isVideo)
                          const Center(
                              child: Icon(Icons.play_circle_fill_rounded,
                                  color: Colors.white, size: 28)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        verticalSpacer(10),

        // ── Upload buttons ───────────────────────────────────────────────
        GetBuilder<AgentJobsController>(
          builder: (c) => c.uploadingPhotos
              ? loadingWidget()
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined,
                            size: 18),
                        label: Text(photoUrls.isEmpty
                            ? 'Add Photo'
                            : 'Add Another'),
                        onPressed: () =>
                            c.pickAndUploadPhoto(isBefore: isBefore),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryThemeColor,
                          side: BorderSide(
                              color: AppColors.primaryThemeColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.videocam_outlined,
                            size: 18),
                        label: Text(videoUrls.isEmpty
                            ? 'Add Video'
                            : 'Add Another'),
                        onPressed: () =>
                            c.pickAndUploadVideo(isBefore: isBefore),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.deepBlue,
                          side: BorderSide(color: AppColors.deepBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openMedia(BuildContext context, String url,
      {bool isVideo = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenMedia(url: url, isVideo: isVideo),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primaryThemeColor.withValues(alpha: 0.2)),
        ),
        child: child,
      );

  Widget _infoRow(String key, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text('$key:',
                  style: AppStyles.subStringStyle(13, AppColors.darkGray)),
            ),
            Expanded(
              child: Text(value,
                  style: AppStyles.regularStringStyle(
                      13, AppColors.fullBlack)),
            ),
          ],
        ),
      );
}

// ── Mini video thumbnail ───────────────────────────────────────────────────────
class _MiniVideoThumb extends StatefulWidget {
  const _MiniVideoThumb({required this.url});
  final String url;

  @override
  State<_MiniVideoThumb> createState() => _MiniVideoThumbState();
}

class _MiniVideoThumbState extends State<_MiniVideoThumb> {
  late VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
          color: Colors.black26,
          child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.white70)));
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _c.value.size.width,
        height: _c.value.size.height,
        child: VideoPlayer(_c),
      ),
    );
  }
}

// ── Full-screen media viewer ───────────────────────────────────────────────────
class _FullScreenMedia extends StatefulWidget {
  const _FullScreenMedia({required this.url, required this.isVideo});
  final String url;
  final bool isVideo;

  @override
  State<_FullScreenMedia> createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<_FullScreenMedia> {
  VideoPlayerController? _vc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _vc = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (mounted) setState(() => _initialized = true);
          _vc!.play();
        });
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: widget.isVideo
          ? (!_initialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Center(
                  child: AspectRatio(
                    aspectRatio: _vc!.value.aspectRatio,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _vc!.value.isPlaying
                            ? _vc!.pause()
                            : _vc!.play();
                      }),
                      child: VideoPlayer(_vc!),
                    ),
                  ),
                ))
          : InteractiveViewer(
              child: Center(
                child: Image.network(widget.url, fit: BoxFit.contain),
              ),
            ),
    );
  }
}
