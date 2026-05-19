import 'dart:convert';

ServiceModel serviceModelFromJson(String str) =>
    ServiceModel.fromJson(json.decode(str));

String serviceModelToJson(ServiceModel data) => json.encode(data.toJson());

class ServiceModel {
  final String? imageUrl;
  final String? name;
  final double? baseCost;   // Naira price
  final double? usdCost;    // USD price

  ServiceModel({
    this.imageUrl,
    this.name,
    this.baseCost,
    this.usdCost,
  });

  ServiceModel copyWith({
    String? imageUrl,
    String? name,
    double? baseCost,
    double? usdCost,
  }) =>
      ServiceModel(
        imageUrl: imageUrl ?? this.imageUrl,
        name: name ?? this.name,
        baseCost: baseCost ?? this.baseCost,
        usdCost: usdCost ?? this.usdCost,
      );

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        imageUrl: json["imageUrl"],
        name: json["name"],
        baseCost: json["baseCost"]?.toDouble(),
        usdCost: json["usdCost"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "name": name,
        "baseCost": baseCost,
        "usdCost": usdCost,
      };
}
