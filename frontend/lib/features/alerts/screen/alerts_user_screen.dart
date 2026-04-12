import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_status.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(alertProvider.notifier);
      await notifier.loadAssignments();
      _markPendingAsViewed();
    });
  }

  void _markPendingAsViewed() {
    final pending = ref
        .read(alertProvider)
        .assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .toList();
    for (final a in pending) {
      ref.read(alertProvider.notifier).markAsViewed(assignmentId: a.id);
    }
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: AssignmentsBody(
        assignments: state.assignments,
        isLoading: state.isLoadingAssignments,
        isBlocked: state.isBlocked,
        onRefresh: () => ref.read(alertProvider.notifier).loadAssignments(),
        onAcknowledge: (id) =>
            ref.read(alertProvider.notifier).acknowledge(assignmentId: id),
      ),
    );
  }
}
