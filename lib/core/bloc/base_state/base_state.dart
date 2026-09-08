part of "../paginated_bloc/exports.dart";

class BaseState<T> extends Equatable {
  final Status status;
  final String? errorMessage;
  final T? data;
  final List<T> items;
  final Map<String, dynamic> metadata;
  final Failure? failure;
  // final int statusCode;
  const BaseState({
    this.status = Status.initial,
    this.failure,
    this.errorMessage,
    this.data,
    this.items = const [],
    this.metadata = const {},
    // this.statusCode = 200,
  });

  BaseState<T> copyWith({
    Status? status,
    String? errorMessage,
    Failure? failure,
    T? data,
    List<T>? items,
    // int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return BaseState<T>(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      items: items ?? this.items,
      // statusCode: statusCode ?? this.statusCode,
      metadata: metadata ?? this.metadata, // Copy metadata
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        data,
        items,
        metadata,
        failure,
        // statusCode,
      ];
}
