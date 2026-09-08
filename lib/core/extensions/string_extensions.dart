part of 'extensions.dart';
extension StringExtensions on String {
  num get numerate => num.tryParse(this)??0;
}


