import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum NivelAlerta { normal, critico }

class AlertModel {
  final String setorDestinado;
  final String setorResponsavel;
  final String titulo;
  final String descricao;
  final DateTime data;
  final NivelAlerta nivel;
  bool lido;

  AlertModel({
    required this.setorDestinado,
    required this.setorResponsavel,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.nivel,
    this.lido = false,
  });
}

class AlertsUserScreen extends StatefulWidget {
  const AlertsUserScreen({super.key});

  @override
  State<AlertsUserScreen> createState() => _AlertsUserScreenState();
}

class _AlertsUserScreenState extends State<AlertsUserScreen> {

  List<AlertModel> alertas = [
    AlertModel(
      setorDestinado: "TI",
      setorResponsavel: "Infraestrutura",
      titulo: "Falha no Servidor Central",
      descricao: "Reiniciar os serviços imediatamente e verificar logs do sistema.",
      data: DateTime.now().subtract(const Duration(hours: 1)),
      nivel: NivelAlerta.critico,
    ),
    AlertModel(
      setorDestinado: "Financeiro",
      setorResponsavel: "Contabilidade",
      titulo: "Atualização de Sistema",
      descricao: "Executar atualização obrigatória até 23h59.",
      data: DateTime(2026, 1, 11, 23, 59),
      nivel: NivelAlerta.normal,
      lido: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          "Alertas",
          style: GoogleFonts.inter(
            color: const Color.fromARGB(221, 255, 255, 255),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: alertas.length,
        itemBuilder: (context, index) {
          return _buildEnterpriseCard(alertas[index]);
        },
      ),
    );
  }

  Widget _buildEnterpriseCard(AlertModel alert) {
    final bool isCritico = alert.nivel == NivelAlerta.critico;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: isCritico ? Colors.red : Colors.blueGrey,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER INSTITUCIONAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badgeNivel(alert.nivel),
              Text(
                DateFormat("dd/MM/yyyy • HH:mm").format(alert.data),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// TÍTULO
          Text(
            alert.titulo,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          /// INSTRUÇÕES
          Text(
            alert.descricao,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          /// INFORMAÇÕES ORGANIZACIONAIS
          Row(
            children: [
              Expanded(
                child: _infoBlock("Setor Destinado", alert.setorDestinado),
              ),
              Expanded(
                child: _infoBlock("Responsável", alert.setorResponsavel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeNivel(NivelAlerta nivel) {
    final bool isCritico = nivel == NivelAlerta.critico;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCritico ? Colors.red.shade50 : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCritico ? "CRÍTICO" : "NORMAL",
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCritico ? Colors.red : Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}