import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_getInitialLocale());

  static Locale _getInitialLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'kk') {
      return const Locale('kk');
    }
    if (systemLocale.languageCode == 'ru') {
      return const Locale('ru');
    }
    return const Locale('en');
  }

  void setLocale(Locale locale) => emit(locale);
}
