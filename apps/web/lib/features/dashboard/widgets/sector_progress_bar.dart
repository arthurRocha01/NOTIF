import 'package:flutter/material.dart';

class SectorProgressBar extends StatelessWidget {
  final String label;
  final double value;

  const SectorProgressBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    Color barColor = const Color(0xFF1E3A8A); // Azul escuro
    if (label == "TI") barColor = const Color(0xFF991B1B); // Vermelho escuro
    if (label == "Operações") barColor = const Color(0xFFD97706); // Dourado

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 85, child: Text(label, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                color: barColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text("${(value * 100).toInt()}%", 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}