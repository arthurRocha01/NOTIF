import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/dashboard/dashboard_screen.dart';
import 'package:notif_app/features/comunicado/notice_screen.dart';

enum NivelAlerta { normal, critico }

class AlertsAdminScreen extends StatefulWidget {
  const AlertsAdminScreen({super.key});

  @override
  State<AlertsAdminScreen> createState() => _AlertsAdminScreenState();
}

class _AlertsAdminScreenState extends State<AlertsAdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // 1. Controladores criados
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  NivelAlerta _nivelSelecionado = NivelAlerta.critico;
  bool _exigirConfirmacao = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 2. Dispose dos controladores adicionado
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _abrirModalCriacao() {
    // Resetar os campos toda vez que o modal for aberto do zero (opcional, mas recomendado)
    _tituloController.clear();
    _descricaoController.clear();
    _nivelSelecionado = NivelAlerta.critico;
    _exigirConfirmacao = true;

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
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Novo Alerta",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // 3. Lógica do botão Limpar implementada aqui
                            setModalState(() {
                              _tituloController.clear();
                              _descricaoController.clear();
                              _nivelSelecionado = NivelAlerta.critico; // Voltando pro padrão
                              _exigirConfirmacao = true; // Voltando pro padrão
                            });
                          },
                          child: const Text(
                            "Limpar",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 15),

                    /// CLASSIFICAÇÃO
                    const Text("Classificação",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A))),
                    const Text("Nível de Urgência",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 15),

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
                            _buildUrgencyOption(
                              "Normal",
                              _nivelSelecionado ==
                                  NivelAlerta.normal,
                              Colors.white,
                              const Color(0xFF1E3A8A),
                              () {
                                setModalState(() {
                                  _nivelSelecionado =
                                      NivelAlerta.normal;
                                });
                              },
                            ),
                            _buildUrgencyOption(
                              "Crítico",
                              _nivelSelecionado ==
                                  NivelAlerta.critico,
                              Colors.red,
                              Colors.white,
                              () {
                                setModalState(() {
                                  _nivelSelecionado =
                                      NivelAlerta.critico;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// CONTEÚDO
                    const Text("Conteúdo",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A))),
                    // 4. Controladores adicionados aos TextFields
                    TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: "Título do Alerta*",
                      ),
                    ),
                    TextField(
                      controller: _descricaoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Descrição e Instruções",
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// SWITCH CONDICIONAL
                    if (_nivelSelecionado == NivelAlerta.normal)
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exigir confirmação de leitura?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Usuários deverão clicar em \"ciente\" para ter acesso ao app.",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _exigirConfirmacao,
                            activeColor:
                                const Color(0xFF1E3A8A),
                            onChanged: (val) =>
                                setModalState(() =>
                                    _exigirConfirmacao = val),
                          ),
                        ],
                      ),

                    const SizedBox(height: 30),

                    /// BOTÃO
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // AQUI VOCÊ PODE PEGAR OS VALORES PARA ENVIAR PARA API
                          // print(_tituloController.text);
                          // print(_descricaoController.text);
                          // print(_nivelSelecionado);
                          
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "ENVIAR ALERTA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUrgencyOption(String label, bool isSelected,
      Color activeBg, Color activeText, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeText : Colors.grey,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
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
              const DashboardScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE2E8F0),
            Color(0xFFCBD5E1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,

        //  INDICADOR MODERNO COM GRADIENTE
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        //  HOVER ESTILO DASHBOARD
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFF1E293B).withOpacity(0.07);
            }
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFF1E293B).withOpacity(0.15);
            }
            return null;
          },
        ),

        mouseCursor: SystemMouseCursors.click,

        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),

        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF475569),

        tabs: const [
          Tab(text: "Alertas"),
          Tab(text: "Painel"),
        ],
      ),
    );
  }

  Widget _buildAlertsContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Olá Roberta.\n(Gestora de operações)",
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _buildActionCard("Novo Alerta",
                LucideIcons.bell, const Color(0xFFDC2626),
                _abrirModalCriacao),
            const SizedBox(width: 15),
            _buildActionCard("Novo Comunicado", LucideIcons.megaphone, const Color(0xFF2D4689), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoticeScreen()),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon,
      Color color, VoidCallback onTap) {
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
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}