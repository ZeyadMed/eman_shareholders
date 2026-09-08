part of '../widgets.dart';
abstract interface class Gaps {
  const Gaps._();

  static SizedBox v(double value) => SizedBox(height: value);
  static SizedBox h(double value) => SizedBox(width: value);
  static SizedBox square(double size) => SizedBox(width: size, height: size);
  static SizedBox v4() => const SizedBox(height: 4);
  static SizedBox v10() => const SizedBox(height: 10);
  static SizedBox v12() => const SizedBox(height: 12);
  static SizedBox v18() => const SizedBox(height: 18);
  static SizedBox h4() => const SizedBox(width: 4);
  static SizedBox h10() => const SizedBox(width: 10);
  static SizedBox h12() => const SizedBox(width: 12);
  static SizedBox h18() => const SizedBox(width: 18);
  static SizedBox h25() => const SizedBox(width: 25);
  static SizedBox v25() => const SizedBox(height: 25);
  static SizedBox h50() => const SizedBox(width: 50);
  static SizedBox v50() => const SizedBox(height: 50);
  static SizedBox square10() => const SizedBox(width: 10, height: 10);

}