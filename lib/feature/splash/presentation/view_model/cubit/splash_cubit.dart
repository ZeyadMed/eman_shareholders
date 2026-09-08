import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<String> {
  final SessionManager _session;

  SplashCubit(this._session) : super('');

  Future<void> startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (isClosed) return;

    // `SessionManager` هو المصدر الوحيد لحالة الدخول — التوكن المنتهي
    // بيتجدد أوتوماتيك في أول ريكوست، فوجود جلسة محفوظة كفاية.
    emit(_session.isLoggedIn ? 'home' : 'login');
  }
}
