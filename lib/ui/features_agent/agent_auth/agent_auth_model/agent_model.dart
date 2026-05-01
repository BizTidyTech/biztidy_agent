import 'dart:convert';

AgentModel agentModelFromJson(String str) =>
    AgentModel.fromJson(json.decode(str));

String agentModelToJson(AgentModel data) => json.encode(data.toJson());

// ── Bank details ──────────────────────────────────────────────────────────────
class BankDetails {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;       // verified by Paystack resolve API
  final String? recipientCode;    // Paystack Transfer Recipient code (RCP_xxx)

  BankDetails({
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    this.recipientCode,
  });

  BankDetails copyWith({String? recipientCode}) => BankDetails(
        bankName: bankName,
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
        recipientCode: recipientCode ?? this.recipientCode,
      );

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        bankName: json['bankName'] ?? '',
        bankCode: json['bankCode'] ?? '',
        accountNumber: json['accountNumber'] ?? '',
        accountName: json['accountName'] ?? '',
        recipientCode: json['recipientCode'],
      );

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'bankCode': bankCode,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'recipientCode': recipientCode,
      };
}

// ── Nigerian banks (Paystack codes) ──────────────────────────────────────────
const nigerianBanks = [
  (name: 'Access Bank', code: '044'),
  (name: 'Citibank Nigeria', code: '023'),
  (name: 'Ecobank Nigeria', code: '050'),
  (name: 'Fidelity Bank', code: '070'),
  (name: 'First Bank of Nigeria', code: '011'),
  (name: 'First City Monument Bank (FCMB)', code: '214'),
  (name: 'Globus Bank', code: '00103'),
  (name: 'Guaranty Trust Bank (GTB)', code: '058'),
  (name: 'Heritage Bank', code: '030'),
  (name: 'Jaiz Bank', code: '301'),
  (name: 'Keystone Bank', code: '082'),
  (name: 'Kuda Bank', code: '50211'),
  (name: 'Moniepoint MFB', code: '50515'),
  (name: 'OPay Digital Services', code: '999992'),
  (name: 'PalmPay', code: '999991'),
  (name: 'Polaris Bank', code: '076'),
  (name: 'Providus Bank', code: '101'),
  (name: 'Stanbic IBTC Bank', code: '221'),
  (name: 'Standard Chartered Bank', code: '068'),
  (name: 'Sterling Bank', code: '232'),
  (name: 'Taj Bank', code: '302'),
  (name: 'Union Bank of Nigeria', code: '032'),
  (name: 'United Bank for Africa (UBA)', code: '033'),
  (name: 'Unity Bank', code: '215'),
  (name: 'VFD Microfinance Bank', code: '566'),
  (name: 'Wema Bank', code: '035'),
  (name: 'Zenith Bank', code: '057'),
];

// ── Agent model ───────────────────────────────────────────────────────────────
class AgentModel {
  final String? agentId;
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? address;
  final String? country;
  final String? photoUrl;
  final String? idDocumentUrl;
  final String? idDocumentType;
  final String? status;
  final double? rating;
  final int? totalJobsCompleted;
  final double? totalEarnings;
  final double? pendingPayout;
  final BankDetails? bankDetails;
  final DateTime? timeCreated;
  final bool? isApproved;

  AgentModel({
    this.agentId,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.address,
    this.country,
    this.photoUrl,
    this.idDocumentUrl,
    this.idDocumentType,
    this.status,
    this.rating,
    this.totalJobsCompleted,
    this.totalEarnings,
    this.pendingPayout,
    this.bankDetails,
    this.timeCreated,
    this.isApproved,
  });

  AgentModel copyWith({
    String? agentId,
    String? name,
    String? email,
    String? password,
    String? phoneNumber,
    String? address,
    String? country,
    String? photoUrl,
    String? idDocumentUrl,
    String? idDocumentType,
    String? status,
    double? rating,
    int? totalJobsCompleted,
    double? totalEarnings,
    double? pendingPayout,
    BankDetails? bankDetails,
    DateTime? timeCreated,
    bool? isApproved,
  }) =>
      AgentModel(
        agentId: agentId ?? this.agentId,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        address: address ?? this.address,
        country: country ?? this.country,
        photoUrl: photoUrl ?? this.photoUrl,
        idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
        idDocumentType: idDocumentType ?? this.idDocumentType,
        status: status ?? this.status,
        rating: rating ?? this.rating,
        totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        pendingPayout: pendingPayout ?? this.pendingPayout,
        bankDetails: bankDetails ?? this.bankDetails,
        timeCreated: timeCreated ?? this.timeCreated,
        isApproved: isApproved ?? this.isApproved,
      );

  factory AgentModel.fromJson(Map<String, dynamic> json) => AgentModel(
        agentId: json['agentId'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
        phoneNumber: json['phoneNumber'],
        address: json['address'],
        country: json['country'] ?? 'Nigeria',
        photoUrl: json['photoUrl'],
        idDocumentUrl: json['idDocumentUrl'],
        idDocumentType: json['idDocumentType'],
        status: json['status'] ?? 'offline',
        rating: json['rating']?.toDouble() ?? 5.0,
        totalJobsCompleted: json['totalJobsCompleted'] ?? 0,
        totalEarnings: json['totalEarnings']?.toDouble() ?? 0.0,
        pendingPayout: json['pendingPayout']?.toDouble() ?? 0.0,
        bankDetails: json['bankDetails'] == null
            ? null
            : BankDetails.fromJson(
                json['bankDetails'] as Map<String, dynamic>),
        isApproved: json['isApproved'] ?? false,
        timeCreated: json['timeCreated'] == null
            ? null
            : DateTime.parse(json['timeCreated']),
      );

  Map<String, dynamic> toJson() => {
        'agentId': agentId,
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'address': address,
        'country': country,
        'photoUrl': photoUrl,
        'idDocumentUrl': idDocumentUrl,
        'idDocumentType': idDocumentType,
        'status': status,
        'rating': rating,
        'totalJobsCompleted': totalJobsCompleted,
        'totalEarnings': totalEarnings,
        'pendingPayout': pendingPayout,
        'bankDetails': bankDetails?.toJson(),
        'timeCreated': timeCreated?.toIso8601String(),
        'isApproved': isApproved ?? false,
      };
}
