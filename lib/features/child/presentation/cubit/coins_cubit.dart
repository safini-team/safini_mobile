import 'package:flutter_bloc/flutter_bloc.dart';

/// Single source of truth for the child's coin wallet across all screens.
/// Provided at the root (above MaterialApp.router) so every screen shares it.
class CoinsCubit extends Cubit<int> {
  /// Starts at 115 — matching the 6 pre-completed tasks (20+10+15+25+15+30).
  CoinsCubit() : super(115);

  void add(int amount) => emit((state + amount).clamp(0, 999999));

  void subtract(int amount) => emit((state - amount).clamp(0, 999999));

  void set(int amount) => emit(amount.clamp(0, 999999));
}
