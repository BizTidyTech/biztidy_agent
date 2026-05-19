import 'dart:convert';

import 'package:biztidy_agent_app/ui/features_user/home/home_model/services_model.dart';

BookingModel bookingModelFromJson(String str) =>
    BookingModel.fromJson(json.decode(str));

String bookingModelToJson(BookingModel data) => json.encode(data.toJson());

class BookingModel {
  final String? bookingId;
  final String? userId;
  final DateTime? dateTime;
  final String? locationName;
  final String? locationAddress;
  final String? country;
  final int? rooms;
  final int? duration;
  final double? roomSqFt;
  final double? totalCalculatedServiceCharge;
  final String? additionalInfo;
  final ServiceModel? service;
  final Customer? customer;
  final PaymentDetails? depositPayment;
  final PaymentDetails? finalPayment;

  BookingModel({
    this.bookingId,
    this.userId,
    this.dateTime,
    this.locationName,
    this.locationAddress,
    this.country,
    this.rooms,
    this.duration,
    this.roomSqFt,
    this.additionalInfo,
    this.service,
    this.customer,
    this.depositPayment,
    this.finalPayment,
    this.totalCalculatedServiceCharge,
  });

  BookingModel copyWith({
    String? bookingId,
    final String? userId,
    DateTime? dateTime,
    String? locationName,
    String? locationAddress,
    String? country,
    int? rooms,
    int? duration,
    double? roomSqFt,
    String? additionalInfo,
    ServiceModel? service,
    Customer? customer,
    PaymentDetails? depositPayment,
    PaymentDetails? finalPayment,
    double? totalCalculatedServiceCharge,
  }) =>
      BookingModel(
        bookingId: bookingId ?? this.bookingId,
        userId: userId ?? this.userId,
        dateTime: dateTime ?? this.dateTime,
        locationName: locationName ?? this.locationName,
        locationAddress: locationAddress ?? this.locationAddress,
        country: country ?? this.country,
        rooms: rooms ?? this.rooms,
        duration: duration ?? this.duration,
        roomSqFt: roomSqFt ?? this.roomSqFt,
        service: service ?? this.service,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        customer: customer ?? this.customer,
        depositPayment: depositPayment ?? this.depositPayment,
        finalPayment: finalPayment ?? this.finalPayment,
        totalCalculatedServiceCharge:
            totalCalculatedServiceCharge ?? this.totalCalculatedServiceCharge,
      );

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        bookingId: json["bookingId"],
        userId: json["userId"],
        dateTime:
            json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
        locationName: json["locationName"],
        locationAddress: json["locationAddress"],
        country: json["country"],
        rooms: json["rooms"],
        duration: json["duration"],
        roomSqFt: json["roomSqFt"]?.toDouble(),
        additionalInfo: json["additionalInfo"],
        totalCalculatedServiceCharge: json["totalCalculatedServiceCharge"],
        service: json["service"] == null
            ? null
            : ServiceModel.fromJson(json["service"]),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        depositPayment: json["depositPayment"] == null
            ? null
            : PaymentDetails.fromJson(json["depositPayment"]),
        finalPayment: json["finalPayment"] == null
            ? null
            : PaymentDetails.fromJson(json["finalPayment"]),
      );

  Map<String, dynamic> toJson() => {
        "bookingId": bookingId,
        "userId": userId,
        "dateTime": dateTime?.toIso8601String(),
        "locationName": locationName,
        "locationAddress": locationAddress,
        "country": country,
        "rooms": rooms,
        "duration": duration,
        "roomSqFt": roomSqFt,
        "totalCalculatedServiceCharge": totalCalculatedServiceCharge,
        "additionalInfo": additionalInfo,
        "service": service?.toJson(),
        "customer": customer?.toJson(),
        "depositPayment": depositPayment?.toJson(),
        "finalPayment": finalPayment?.toJson(),
      };
}

class Customer {
  final String? userId;
  final String? name;
  final String? email;
  final String? phoneNumber;

  Customer({
    this.userId,
    this.name,
    this.email,
    this.phoneNumber,
  });

  Customer copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
  }) =>
      Customer(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        userId: json["userId"],
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
      };
}

class PaymentDetails {
  final String? paymentId;
  final String? payerId;
  final String? status;
  final String? payerEmail;
  final String? payerName;
  final String? amount;
  final DateTime? paidAt;

  PaymentDetails({
    this.paymentId,
    this.payerId,
    this.status,
    this.payerEmail,
    this.payerName,
    this.amount,
    this.paidAt,
  });

  PaymentDetails copyWith({
    String? paymentId,
    String? payerId,
    String? status,
    String? payerEmail,
    String? payerName,
    String? amount,
    DateTime? paidAt,
  }) =>
      PaymentDetails(
        paymentId: paymentId ?? this.paymentId,
        payerId: payerId ?? this.payerId,
        status: status ?? this.status,
        payerEmail: payerEmail ?? this.payerEmail,
        payerName: payerName ?? this.payerName,
        amount: amount ?? this.amount,
        paidAt: paidAt ?? this.paidAt,
      );

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
        paymentId: json["paymentId"],
        payerId: json["payerId"],
        status: json["status"],
        payerEmail: json["payerEmail"],
        payerName: json["payerName"],
        amount: json["amount"],
        paidAt:
            json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
      );

  Map<String, dynamic> toJson() => {
        "paymentId": paymentId,
        "payerId": payerId,
        "status": status,
        "payerEmail": payerEmail,
        "payerName": payerName,
        "amount": amount,
        "paid_at": paidAt?.toIso8601String(),
      };
}
