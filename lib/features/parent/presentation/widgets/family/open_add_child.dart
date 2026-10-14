import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

/// The "Add" circle of the child selector: the add-child flow, then a fresh
/// family so the new child shows up in every tab.
Future<void> openAddChild(BuildContext context) async {
  final family = context.read<ParentFamilyCubit>();
  final added = await context.router.push<bool>(const NamedRoute('addChild'));
  if (added == true) await family.loadCurrentFamily(refresh: true);
}
