part of "../paginated_bloc/exports.dart";

abstract class EnumEvent<T extends Enum> extends Equatable {
  const EnumEvent();

  @override
  List<Object?> get props => [];
}

class SelectEnumValue<T extends Enum> extends EnumEvent<T> {
  final T value;
  const SelectEnumValue(this.value);

  @override
  List<Object?> get props => [value];
}
