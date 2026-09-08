// paginated_bloc.dart

part of 'exports.dart';

typedef FetchPage<T> = Future<Either<Failure, List<T>>> Function(
  int page,
  int limit,
  Map<String, dynamic>? query,
  dynamic params,
);

abstract class PaginatedBloc<T> extends Bloc<PaginatedEvent<T>, BaseState<T>> {
  final SyncManager _syncManager = getIt<SyncManager>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  late final PaginationHandler<T, PaginatedBloc<T>> _paginationHandler;
  late final FetchPage<T> fetchPage;
  final int pageSize;
  String Function(dynamic params, Map<String, dynamic>? query)? cacheKeyBuilder;

  dynamic lastParams;
  Map<String, dynamic>? lastQuery;
  StreamSubscription<bool>? _connectivitySubscription;

  PaginatedBloc({
    required this.fetchPage,
    this.cacheKeyBuilder,
    this.pageSize = 15,
  }) : super(BaseState<T>()) {
    _syncManager.registerSyncCallback(_syncData);

    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((hasInternet) {
      if (hasInternet) _syncManager.syncAll();
    });

    assert(
      cacheKeyBuilder != null,
      'cacheKeyBuilder must be provided when using PaginatedBloc',
    );

    _paginationHandler = PaginationHandler<T, PaginatedBloc<T>>(
      bloc: this,
      pageSize: pageSize,
    );

    on<LoadFirstPage<T>>(_onLoadFirstPage);
    on<LoadNextPage<T>>(_onFetchNextPage);
  }

  // ✅ الكود الكامل لـ _onLoadFirstPage بعد التعديل
FutureOr<void> _onLoadFirstPage(
  LoadFirstPage<T> event,
  Emitter<BaseState<T>> emit,
) async {
  lastParams = event.params;
  lastQuery = event.query;

  _paginationHandler.items.clear();
  _paginationHandler.currentPage = 1;
  _paginationHandler.hasMoreData = true;
  _paginationHandler.isLoadingMore = false;

  emit(state.copyWith(status: Status.loading, items: []));

  final result = await fetchPage(1, pageSize, event.query, event.params);

  result.fold(
    (failure) => emit(state.copyWith(
      status: Status.failure,
      errorMessage: failure.message,
    )),
    (items) {
      _paginationHandler.items.addAll(items);

      if (items.length >= pageSize) {
        _paginationHandler.currentPage++;
      } else {
        _paginationHandler.hasMoreData = false;
      }

      if (cacheKeyBuilder != null && getIt.isRegistered<IPaginatedCache<T>>()) {
        final key = cacheKeyBuilder!.call(event.params, event.query);
        getIt<IPaginatedCache<T>>().cachePage(
          _paginationHandler.items,
          cacheKey: key,
        );
      }

      emit(state.copyWith(
        status: Status.success,
        items: List.from(_paginationHandler.items),
      ));
    },
  );
}
  FutureOr<void> _onFetchNextPage(
    LoadNextPage<T> event,
    Emitter<BaseState<T>> emit,
  ) async {
    if (!_paginationHandler.hasMoreData || _paginationHandler.isLoadingMore) {
      return;
    }

    lastQuery = event.query ?? lastQuery;
    _paginationHandler.isLoadingMore = true;

    emit(state.copyWith(status: Status.isLoadingMore));

    final result = await fetchPage(
      _paginationHandler.currentPage,
      pageSize,
      lastQuery,
      lastParams,
    );

    result.fold(
      (failure) {
        _paginationHandler.isLoadingMore = false;
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
        ));
      },
      (items) {
        _paginationHandler.items.addAll(items);

        if (items.length >= pageSize) {
          _paginationHandler.currentPage++;
        } else {
          _paginationHandler.hasMoreData = false;
        }

        _paginationHandler.isLoadingMore = false;

        emit(state.copyWith(
          status: Status.success,
          items: List.from(_paginationHandler.items),
        ));
      },
    );
  }

  bool _isSyncing = false;

  Future<void> _syncData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      add(LoadFirstPage<T>(params: lastParams, query: lastQuery));
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isSyncing = false;
    }
  }

  @override
  Future<void> close() {
    _syncManager.unregisterSyncCallback(_syncData);
    _connectivitySubscription?.cancel();
    return super.close();
  }
}