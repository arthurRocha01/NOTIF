import 'package:flutter/material.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import '../../alerts/models/alert_model.dart';
import '../../../core/utils/date_formatter.dart';

class MonitoringAlertCard extends StatelessWidget {
  final AlertModel alert;

  const MonitoringAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final bool isCritical = alert.level == AlertLevel.critical;
    final Color mainColor = alert.level.color;
    final IconData icon = alert.level.icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: mainColor, width: 6),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: mainColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: alert.level.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    alert.level.label.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.relative(alert.createdAt),
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                if (alert.isGlobal)
                  Row(
                    children: [
                      Icon(Icons.public, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('Global',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.groups, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        alert.targetSectorId ?? '',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                if (isCritical) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver detalhes',
                        style: TextStyle(color: Colors.blue, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
