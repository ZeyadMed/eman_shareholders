import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../local_storage/local_storage.dart';

part 'theme_events.dart';
part 'theme_states.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeCache _themeCache;

  ThemeBloc({required IThemeCache themeCache})
      : _themeCache = themeCache,
        super(const ThemeState()) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final cachedTheme = _themeCache.getThemeMode();

    if (cachedTheme != null) {
      final themeMode = _stringToThemeMode(cachedTheme);
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final themeModeString = _themeModeToString(event.themeMode);
    await _themeCache.saveThemeMode(themeModeString);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
