import 'package:eman_shareholders/core/bloc/paginated_bloc/exports.dart';
import 'package:eman_shareholders/core/enum/status.dart';
import 'package:eman_shareholders/core/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_source/auth_data_source.dart';
import '../../../data/models/otp_request_result.dart';

/// كيوبت تسجيل الدخول — بيبعت رمز التحقق لرقم الهاتف.
class LoginCubit extends Cubit<BaseState<OtpRequestResult>> {
  final AuthDataSource _dataSource;

  LoginCubit(this._dataSource) : super(const BaseState<OtpRequestResult>());

  Future<void> requestOtp(String phoneNumber) async {
    if (state.isLoading) return;

    emit(const BaseState<OtpRequestResult>(status: Status.loading));

    final result = await _dataSource.requestOtp(phoneNumber);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        BaseState<OtpRequestResult>(
          status: Status.failure,
          failure: failure,
          errorMessage: failure.message,
        ),
      ),
      (otpResult) => emit(
        BaseState<OtpRequestResult>(status: Status.success, data: otpResult),
      ),
    );
  }
}
