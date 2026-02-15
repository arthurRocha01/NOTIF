import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AlertsAdminScreen extends StatefulWidget {
  const AlertsAdminScreen({super.key});

  @override
  State<AlertsAdminScreen> createState() => _AlertsAdminScreenState();
}

class _AlertsAdminScreenState extends State<AlertsAdminScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Estados para o Modal
  bool _isCritico = true; 
  bool _exigirConfirmacao = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Abre o modal de criação conforme a imagem fornecida
  void _abrirModalCriacao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Novo Alerta",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Limpar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 15),

                  // Classificação
                  const Text("Classificação", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const Text("Nível de Urgência", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 15),
                  
                  // Seletor de Urgência (Pill design)
                  Center(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUrgencyOption("Normal", !_isCritico, Colors.white, const Color(0xFF1E3A8A), () {
                            setModalState(() => _isCritico = false);
                          }),
                          _buildUrgencyOption("Critico", _isCritico, Colors.red, Colors.white, () {
                            setModalState(() => _isCritico = true);
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Campos de Texto
                  const Text("Conteúdo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Título do Alerta*",
                      labelStyle: TextStyle(fontSize: 13),
                      floatingLabelStyle: TextStyle(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                  const TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Descrição e Instruções",
                      labelStyle: TextStyle(fontSize: 13),
                      floatingLabelStyle: TextStyle(color: Color(0xFF1E3A8A)),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Destinatários
                  const Text("Destinarios", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const Text("Enviar para:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Chip(
                          label: const Text("Todos os Setores", style: TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {},
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        const Spacer(),
                        const Text("+ Adicionar", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Toggle de Confirmação
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Exigir confirmação de leitura?", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              "Usuários deverão clicar em \"ciente\" para ter acesso ao app.",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _exigirConfirmacao,
                        activeColor: const Color(0xFF1E3A8A),
                        onChanged: (val) => setModalState(() => _exigirConfirmacao = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botão Final
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Lógica de envio aqui futuramente
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "ENVIAR ALERTA",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Helper para o seletor de urgência
  Widget _buildUrgencyOption(String label, bool isSelected, Color activeBg, Color activeText, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeText : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildCustomTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAlertsContent(),
              const Center(child: Text("Painel de Controle")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        tabs: const [Tab(text: "Alertas"), Tab(text: "Painel")],
      ),
    );
  }

  Widget _buildAlertsContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Olá Roberta.\n(Gestora de operações)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _buildActionCard("Novo Alerta", LucideIcons.bell, const Color(0xFFDC2626), _abrirModalCriacao),
            const SizedBox(width: 15),
            _buildActionCard("Novo Comunicado", LucideIcons.megaphone, const Color(0xFF2D4689), () {}),
          ],
        ),
        const SizedBox(height: 30),
        const Text("Monitoramento Ativo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 15),
        _buildMiniStatusCard("Protocolo Incêndio", "85% Lido", Colors.orange),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatusCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}