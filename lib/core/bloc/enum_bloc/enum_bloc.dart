part of "../paginated_bloc/exports.dart";
abstract class EnumBloc<T extends Enum> extends Bloc<EnumEvent<T>, EnumState<T>> {
  EnumBloc(
      List<T> values, {
        required T initial,
      }) : super(EnumState(values: values, selected: initial)) {
    on<SelectEnumValue<T>>((event, emit) {
      emit(state.copyWith(selected: event.value));
    });
  }
}