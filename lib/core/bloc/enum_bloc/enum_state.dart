part of "../paginated_bloc/exports.dart";
class EnumState<T extends Enum> extends Equatable {
  final List<T> values;
  final T selected;

  const EnumState({
    required this.values,
    required this.selected,
  });

  EnumState<T> copyWith({
    List<T>? values,
    T? selected,
  }) {
    return EnumState(
      values: values ?? this.values,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object> get props => [values, selected];
}