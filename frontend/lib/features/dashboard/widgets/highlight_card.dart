import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  final String sector;
  final double rate;

  const HighlightCard({super.key, required this.sector, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade700, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 50, color: Colors.orangeAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Setor Mais Atento", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B))),
                Text(sector, style: const TextStyle(fontSize: 15, color: Color(0xFF475569))),
                Text("${(rate * 100).toInt()}% de Leitura", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                const Text("Tempo médio de resposta: 2 minutos", 
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}