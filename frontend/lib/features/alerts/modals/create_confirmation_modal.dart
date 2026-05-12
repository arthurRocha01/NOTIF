import 'package:flutter/material.dart';

class CreateConfirmationModal extends StatefulWidget {
  const CreateConfirmationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const CreateConfirmationModal(),
    );
  }

  @override
  State<CreateConfirmationModal> createState() => _CreateConfirmationModalState();
}

class _CreateConfirmationModalState extends State<CreateConfirmationModal> {
  final _questionCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  String _responseType = 'boolean';
  final Set<String> _sectors = {};
  int _deadlineHours = 2;

  static const _sectorOptions = [
    'TI',
    'Operações',
    'RH',
    'Financeiro',
    'Logística',
    'Comercial',
  ];

  static const _deadlineOptions = [1, 2, 4, 8, 24];

  @override
  void dispose() {
    _questionCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _handle(),
            _header(context),
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(20, 8, 20, kb + 100),
                children: [
                  _infoBanner(),
                  const SizedBox(height: 20),

                  _fieldLabel('Pergunta da Confirmação'),
                  const SizedBox(height: 8),
                  _textField(
                    _questionCtrl,
                    'Ex: Você recebeu o comunicado sobre a manutenção?',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _fieldLabel('Contexto / Informação adicional'),
                  const SizedBox(height: 8),
                  _textField(
                    _contextCtrl,
                    'Descreva o contexto ou informações extras (opcional)...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  _fieldLabel('Tipo de Resposta'),
                  const SizedBox(height: 8),
                  _responseTypeSelector(),
                  const SizedBox(height: 20),

                  _fieldLabel('Setores Destinatários'),
                  const SizedBox(height: 8),
                  _sectorChips(),
                  const SizedBox(height: 20),

                  _fieldLabel('Prazo para Resposta'),
                  const SizedBox(height: 8),
                  _deadlineSelector(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  // ── Structure ─────────────────────────────────────────────────────────────────

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sensors_rounded, color: Color(0xFF3B5BDB), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova Confirmação em Massa',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2340),
                  ),
                ),
                Text(
                  'Acompanhe as respostas em tempo real no Radar',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B5BDB).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.radar_rounded, size: 18, color: Color(0xFF3B5BDB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'As respostas serão exibidas no Radar de Respostas em tempo real, com o layout físico do setor.',
              style: TextStyle(fontSize: 12, color: Color(0xFF3B5BDB), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAF0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFFE8EAF0), width: 1.5),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B5BDB), Color(0xFF6741D9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B5BDB).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Enviar Confirmação',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form fields ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2340),
        ),
      );

  Widget _textField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _responseTypeSelector() {
    const types = [
      (key: 'boolean', label: 'Sim / Não', icon: Icons.check_circle_outline_rounded, desc: 'Resposta binária'),
      (key: 'multi', label: 'Múltipla Escolha', icon: Icons.list_rounded, desc: 'Opções personalizadas'),
      (key: 'presence', label: 'Presença', icon: Icons.person_pin_circle_outlined, desc: 'Check-in de local'),
    ];

    return Column(
      children: types.map((t) {
        final sel = _responseType == t.key;
        return GestureDetector(
          onTap: () => setState(() => _responseType = t.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFFEFF3FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? const Color(0xFF3B5BDB) : const Color(0xFFE8EAF0),
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF3B5BDB).withValues(alpha: 0.15)
                        : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    t.icon,
                    size: 18,
                    color: sel ? const Color(0xFF3B5BDB) : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: sel ? const Color(0xFF3B5BDB) : const Color(0xFF1A2340),
                        ),
                      ),
                      Text(
                        t.desc,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                if (sel)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF3B5BDB), size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectorChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (_sectors.length == _sectorOptions.length) {
              _sectors.clear();
            } else {
              _sectors.addAll(_sectorOptions);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _sectors.length == _sectorOptions.length
                  ? const Color(0xFF059669)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _sectors.length == _sectorOptions.length
                    ? const Color(0xFF059669)
                    : const Color(0xFFE8EAF0),
              ),
            ),
            child: Text(
              'Todos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _sectors.length == _sectorOptions.length
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        ..._sectorOptions.map((s) {
          final sel = _sectors.contains(s);
          return GestureDetector(
            onTap: () => setState(() => sel ? _sectors.remove(s) : _sectors.add(s)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF3B5BDB) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? const Color(0xFF3B5BDB) : const Color(0xFFE8EAF0),
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _deadlineSelector() {
    return Row(
      children: _deadlineOptions.map((h) {
        final sel = _deadlineHours == h;
        final label = h == 1 ? '1h' : h == 24 ? '1d' : '${h}h';
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _deadlineHours = h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: h != 24 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF3B5BDB) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? const Color(0xFF3B5BDB) : const Color(0xFFE8EAF0),
                  width: sel ? 0 : 1.5,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B5BDB).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
