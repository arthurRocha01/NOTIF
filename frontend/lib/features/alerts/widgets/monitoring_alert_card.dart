import 'package:flutter/material.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import '../../alerts/models/alert_model.dart';

class MonitoringAlertCard extends StatelessWidget {
  final AlertModel alert;

  const MonitoringAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    // Define a cor baseada no nível do alerta
    final bool isCritical = alert.level == AlertLevel.critical;
    final Color mainColor = isCritical ? Colors.red : Colors.blue;
    final IconData icon = isCritical ? Icons.notifications_active : Icons.info_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: mainColor, width: 6), // A borda lateral da imagem
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: mainColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(alert.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text("Há 15 min", // Aqui você usaria o alert.createdAt formatado
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Adesão em tempo real:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text("${(alert.readRate * 100).toInt()}% Lido", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            // Barra de Progresso com Gradiente conforme a imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: alert.readRate,
                minHeight: 12,
                backgroundColor: Colors.grey.shade100,
                // Se for crítico, faz o gradiente vermelho/amarelo, se não, azul sólido
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // Abriria lista de quem leu
                child: const Text("Ver detalhes", style: TextStyle(color: Colors.blue)),
              ),
            )
          ],
        ),
      ),
    );
  }
}