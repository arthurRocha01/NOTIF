import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alert_provider.dart';
import '../widgets/assignments_body.dart';

class AlertUserScreen extends ConsumerStatefulWidget {
  const AlertUserScreen({super.key});

  @override
  ConsumerState<AlertUserScreen> createState() => _AlertUserScreenState();
}

class _AlertUserScreenState extends ConsumerState<AlertUserScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(alertProvider.notifier).loadAssignments());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertProvider);

    ref.listen<String?>(
      alertProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error),
                backgroundColor: Colors.red.shade700),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: AssignmentsBody(
        assignments: state.assignments,
        isLoading: state.isLoadingAssignments,
        isBlocked: state.isBlocked,
        onRefresh: () => ref.read(alertProvider.notifier).loadAssignments(),
        onAcknowledge: (id) =>
            ref.read(alertProvider.notifier).acknowledge(id),
        onDeny: (id) => ref.read(alertProvider.notifier).deny(id),
      ),
    );
  }
}
