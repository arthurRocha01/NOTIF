import 'package:flutter/material.dart';
import 'package:notif_app/shared/widgets/status_badge.dart';
import '../models/alert_status.dart';

class AlertLevelChip extends StatelessWidget {
  final AlertLevel level;
  const AlertLevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) => StatusBadge(
        label: level.label,
        color: level.color,
      );
}
