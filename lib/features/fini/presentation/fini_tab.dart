import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/cubit/fini_inbox_cubit.dart';
import 'package:safini/features/fini/presentation/screens/fini_home_screen.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';

/// The Fini tab in the parent shell (SAF-271). Opening it refreshes the
/// child on screen and the badge; a decision there refreshes the badge.
class FiniTab extends StatelessWidget {
  const FiniTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FiniCubit(
        getIt<FiniRepository>(),
        onInboxChanged: context.read<FiniInboxCubit>().refresh,
      ),
      child: BlocListener<ParentHomeCubit, ParentHomeState>(
        listenWhen: (previous, current) =>
            current.selectedIndex == ParentTab.fini &&
            previous.selectedIndex != ParentTab.fini,
        listener: (context, _) {
          final childId = context.read<FiniCubit>().state.childId;
          if (childId != null) context.read<FiniCubit>().load(childId);
          context.read<FiniInboxCubit>().refresh();
        },
        child: const FiniHomeScreen(),
      ),
    );
  }
}
