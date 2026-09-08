part of 'http.dart';

abstract class ApiConsumer {
  Future<Either<Failure, Map<String, dynamic>>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool skipAuthRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> postFormData(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool formData = false,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, String>> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> head(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String url, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  void addInterceptor(Interceptor interceptor);
  void removeAllInterceptors();
  void updateHeader(Map<String, dynamic> headers);

  Future<Either<Failure, Map<String, dynamic>>> retryApiCall(
    Future<Either<Failure, Map<String, dynamic>>> Function() apiCall, {
    int retryCount = 0,
  });
}
