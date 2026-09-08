part of "extensions.dart";
extension BaseStateX<T> on BaseState<T> {
  bool get isInitial => status == Status.initial;

  bool get isLoading => status == Status.loading;

  bool get isSuccess => status == Status.success;

  bool get isFailure => status == Status.failure;

  bool get isLoadingMore => status == Status.isLoadingMore;
  bool get isCustom => status == Status.custom;

  bool get isEmpty => isSuccess && items.isEmpty;

  bool get hasData => data != null;
}