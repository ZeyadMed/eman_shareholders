import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/feature/statement/data/data_source/statement_data_source.dart';
import 'package:eman_shareholders/feature/statement/presentation/view_model/statement_cubit.dart';
import 'package:get_it/get_it.dart';

class StatementServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    getIt.registerLazySingleton<StatementDataSource>(
      () => StatementDataSourceImpl(getIt<GenericDataSource>()),
    );
    getIt.registerFactory<StatementCubit>(
      () => StatementCubit(getIt<StatementDataSource>()),
    );
  }
}
