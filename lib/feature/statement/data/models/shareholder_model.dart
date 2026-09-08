part of 'statement_model.dart';

/// بيانات المساهم نفسه — الجزء `shareholder` من الريسبونس.
class ShareholderModel extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String address;

  /// المبلغ المساهَم به (رأس المال الحالي).
  final double contributedAmount;

  /// نسبة المساهم من رأس المال.
  final double ownedPercentage;

  /// نسبة الشركة.
  final double companyPercentage;

  /// إجمالي الأرباح المستلمة.
  final double totalProfitReceived;

  /// الأرباح المستحقة (غير المستلمة).
  final double accruedProfit;

  final int? capitalTreasuryId;
  final String capitalTreasuryName;
  final String notes;
  final DateTime? createdAt;

  const ShareholderModel({
    this.id = 0,
    this.name = '',
    this.phoneNumber = '',
    this.address = '',
    this.contributedAmount = 0,
    this.ownedPercentage = 0,
    this.companyPercentage = 0,
    this.totalProfitReceived = 0,
    this.accruedProfit = 0,
    this.capitalTreasuryId,
    this.capitalTreasuryName = '',
    this.notes = '',
    this.createdAt,
  });

  factory ShareholderModel.fromJson(Map<String, dynamic> json) {
    return ShareholderModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phoneNumber: _asString(json['phoneNumber']),
      address: _asString(json['address']),
      contributedAmount: _asDouble(json['contributedAmount']),
      ownedPercentage: _asDouble(json['ownedPercentage']),
      companyPercentage: _asDouble(json['companyPercentage']),
      totalProfitReceived: _asDouble(json['totalProfitReceived']),
      accruedProfit: _asDouble(json['accruedProfit']),
      capitalTreasuryId: _asIntOrNull(json['capitalTreasuryId']),
      capitalTreasuryName: _asString(json['capitalTreasuryName']),
      notes: _asString(json['notes']),
      createdAt: _asDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'contributedAmount': contributedAmount,
      'ownedPercentage': ownedPercentage,
      'companyPercentage': companyPercentage,
      'totalProfitReceived': totalProfitReceived,
      'accruedProfit': accruedProfit,
      'capitalTreasuryId': capitalTreasuryId,
      'capitalTreasuryName': capitalTreasuryName,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    address,
    contributedAmount,
    ownedPercentage,
    companyPercentage,
    totalProfitReceived,
    accruedProfit,
    capitalTreasuryId,
    capitalTreasuryName,
    notes,
    createdAt,
  ];
}
