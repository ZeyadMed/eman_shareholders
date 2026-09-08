import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'user_token.g.dart';

@HiveType(typeId: 0)
class UserToken extends Equatable {
  @HiveField(0)
  final String accessToken;
  @HiveField(1)
  final String refreshToken;
  @HiveField(2)
  final String message;
  @HiveField(3)
  final String userType;
  @HiveField(4)
  final String userId;
  @HiveField(5)
  final String email;
  @HiveField(6)
  final String userName;
  @HiveField(7)
  final DateTime expiresAtUtc;

  const UserToken({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.userType,
    required this.userId,
    required this.email,
    required this.userName,
    required this.expiresAtUtc,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    // لو `accessToken` في الجذر يبقى إحنا واصلنا الـ `data` نفسها،
    // غير كده بندوّر على مفتاح `data`.
    final raw = json.containsKey('accessToken') ? json : json['data'];
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};

    return UserToken(
      accessToken: data['accessToken']?.toString() ?? "",
      refreshToken: data['refreshToken']?.toString() ?? "",
      message: (json['message'] ?? data['message'])?.toString() ?? "",
      userType: data['userType']?.toString() ?? "",
      userId: data['userId']?.toString() ?? "",
      email: data['email']?.toString() ?? "",
      userName: data['userName']?.toString() ?? "",
      // السيرفر بيرجع الوقت UTC بدون `Z` أحيانًا — بنجبره UTC عشان
      // المقارنة مع `DateTime.now().toUtc()` تبقى صح.
      expiresAtUtc: _parseUtc(data['expiresAtUtc']),
    );
  }

  static DateTime _parseUtc(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return DateTime.now().toUtc();
    return parsed.isUtc ? parsed : DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }

  /// فيه توكن فعلي محفوظ؟
  bool get isValid => accessToken.isNotEmpty;

  bool get hasRefreshToken => refreshToken.isNotEmpty;

  /// انتهت صلاحية الـ access token؟ بنسيب هامش دقيقة عشان ما نبعتش
  /// ريكوست بتوكن هيقع على السيرفر وهو في السكة.
  bool get isExpired =>
      DateTime.now().toUtc().isAfter(
        expiresAtUtc.subtract(const Duration(minutes: 1)),
      );

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "message": message,
      "userType": userType,
      "userId": userId,
      "email": email,
      "userName": userName,
      "expiresAtUtc": expiresAtUtc.toIso8601String(),
    };
  }

  UserToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? message,
    String? userType,
    String? userId,
    String? email,
    String? userName,
    DateTime? expiresAtUtc,
  }) {
    return UserToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      message: message ?? this.message,
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        message,
        userType,
        userId,
        email,
        userName,
        expiresAtUtc,
      ];
}
