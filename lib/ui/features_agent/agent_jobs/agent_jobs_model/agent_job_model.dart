import 'package:biztidy_agent_app/ui/features_user/booking/booking_model/booking_model.dart';

class AgentJobModel {
  final String? jobId;
  final String? agentId;
  final String? bookingId;
  final BookingModel? booking;
  final String? status;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<String>? beforePhotoUrls;
  final List<String>? afterPhotoUrls;
  final List<String>? beforeVideoUrls;
  final List<String>? afterVideoUrls;
  final double? rating;
  final String? clientReview;
  final double? agentEarnings;

  AgentJobModel({
    this.jobId,
    this.agentId,
    this.bookingId,
    this.booking,
    this.status,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.beforePhotoUrls,
    this.afterPhotoUrls,
    this.beforeVideoUrls,
    this.afterVideoUrls,
    this.rating,
    this.clientReview,
    this.agentEarnings,
  });

  AgentJobModel copyWith({
    String? jobId,
    String? agentId,
    String? bookingId,
    BookingModel? booking,
    String? status,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    List<String>? beforePhotoUrls,
    List<String>? afterPhotoUrls,
    List<String>? beforeVideoUrls,
    List<String>? afterVideoUrls,
    double? rating,
    String? clientReview,
    double? agentEarnings,
  }) =>
      AgentJobModel(
        jobId: jobId ?? this.jobId,
        agentId: agentId ?? this.agentId,
        bookingId: bookingId ?? this.bookingId,
        booking: booking ?? this.booking,
        status: status ?? this.status,
        assignedAt: assignedAt ?? this.assignedAt,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        beforePhotoUrls: beforePhotoUrls ?? this.beforePhotoUrls,
        afterPhotoUrls: afterPhotoUrls ?? this.afterPhotoUrls,
        beforeVideoUrls: beforeVideoUrls ?? this.beforeVideoUrls,
        afterVideoUrls: afterVideoUrls ?? this.afterVideoUrls,
        rating: rating ?? this.rating,
        clientReview: clientReview ?? this.clientReview,
        agentEarnings: agentEarnings ?? this.agentEarnings,
      );

  factory AgentJobModel.fromJson(Map<String, dynamic> json) => AgentJobModel(
        jobId: json['jobId'],
        agentId: json['agentId'],
        bookingId: json['bookingId'],
        booking: json['booking'] == null
            ? null
            : BookingModel.fromJson(json['booking']),
        status: json['status'] ?? 'pending',
        assignedAt: json['assignedAt'] == null
            ? null
            : DateTime.parse(json['assignedAt']),
        startedAt: json['startedAt'] == null
            ? null
            : DateTime.parse(json['startedAt']),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt']),
        beforePhotoUrls: json['beforePhotoUrls'] == null
            ? []
            : List<String>.from(json['beforePhotoUrls']),
        afterPhotoUrls: json['afterPhotoUrls'] == null
            ? []
            : List<String>.from(json['afterPhotoUrls']),
        beforeVideoUrls: json['beforeVideoUrls'] == null
            ? []
            : List<String>.from(json['beforeVideoUrls']),
        afterVideoUrls: json['afterVideoUrls'] == null
            ? []
            : List<String>.from(json['afterVideoUrls']),
        rating: json['rating']?.toDouble(),
        clientReview: json['clientReview'],
        agentEarnings: json['agentEarnings']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'agentId': agentId,
        'bookingId': bookingId,
        'booking': booking?.toJson(),
        'status': status,
        'assignedAt': assignedAt?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'beforePhotoUrls': beforePhotoUrls,
        'afterPhotoUrls': afterPhotoUrls,
        'beforeVideoUrls': beforeVideoUrls,
        'afterVideoUrls': afterVideoUrls,
        'rating': rating,
        'clientReview': clientReview,
        'agentEarnings': agentEarnings,
      };
}
