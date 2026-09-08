import 'package:equatable/equatable.dart';

/// ناتج `request-otp` و `resend-otp` — الرسالة ووقت انتهاء صلاحية الرمز.
class OtpRequestResult extends Equatable {
  /// رسالة السيرفر بالعربي — بتتعرض للمستخدم زي ما هي.
  final String message;

  /// وقت انتهاء صلاحية الرمز (UTC) — منها بنحسب العد التنازلي.
  final DateTime? expiresAtUtc;

  const OtpRequestResult({this.message = '', this.expiresAtUtc});

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    // `fetchResult`/`postData` بيبعتوا الـ `data` مع حقن `message` جوّاها.
    return OtpRequestResult(
      message: json['message']?.toString() ?? '',
      expiresAtUtc: _parseUtc(json['expiresAtUtc']),
    );
  }

  static DateTime? _parseUtc(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return null;
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  /// الثواني المتبقية لحد انتهاء الرمز — صفر لو خلص أو مش معروف.
  int get secondsUntilExpiry {
    final expiry = expiresAtUtc;
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now().toUtc()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  List<Object?> get props => [message, expiresAtUtc];
}
