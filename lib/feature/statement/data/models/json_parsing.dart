part of 'statement_model.dart';

/// دوال صغيرة لتحويل قيم الـ JSON بأمان — الـ API بيرجع أرقام كـ int أو
/// double أو String، وبعض الحقول بترجع null، فالتحويل المباشر بيقع.

/// double أو 0 لو القيمة null / نوعها غلط.
double _asDouble(Object? value) => _asDoubleOrNull(value) ?? 0;

/// double أو null — للحقول اللي null فيها معناها "مش موجود" مش "صفر"
/// زي `companyShare` و `shareholderShare`.
double? _asDoubleOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// int أو 0 لو القيمة null / نوعها غلط.
int _asInt(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

/// int أو null.
int? _asIntOrNull(Object? value) => value == null ? null : _asInt(value);

/// String أو نص فاضي لو القيمة null.
String _asString(Object? value) => value?.toString() ?? '';

/// تاريخ أو null لو القيمة null / صيغتها غلط.
DateTime? _asDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

/// Map أو Map فاضية — بتخلي الـ `fromJson` تشتغل على القيم الناقصة.
Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

/// List أو List فاضية.
List<dynamic> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}
