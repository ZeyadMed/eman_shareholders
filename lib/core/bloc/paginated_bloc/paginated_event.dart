part of 'exports.dart';
abstract class PaginatedEvent<T> extends Equatable {
  const PaginatedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFirstPage<T> extends PaginatedEvent<T> {
  final dynamic params;
  final Map<String, dynamic>? query;

  const LoadFirstPage({this.params, this.query});

  @override
  List<Object?> get props => [params, query];
}

class LoadNextPage<T> extends PaginatedEvent<T> {
  final Map<String, dynamic>? query;

  const LoadNextPage({this.query});

  @override
  List<Object?> get props => [query];
}

