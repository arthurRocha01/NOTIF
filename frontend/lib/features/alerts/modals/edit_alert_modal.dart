import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditAlertModal extends StatefulWidget {
  final String initialTitle;
  final String initialSector;
  final String initialType;
  final String initialDescription;

  const EditAlertModal({
    super.key,
    required this.initialTitle,
    required this.initialSector,
    required this.initialType,
    required this.initialDescription,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String sector,
    required String type,
    required String description,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => EditAlertModal(
        initialTitle: title,
        initialSector: sector,
        initialType: type,
        initialDescription: description,
      ),
    );
  }

  @override
  State<EditAlertModal> createState() => _EditAlertModalState();
}

class _EditAlertModalState extends State<EditAlertModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _type;
  late Set<String> _sectors;

  static const _sectorOptions = ['TI', 'Operações', 'RH', 'Financeiro', 'Logística', 'Comercial'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _descCtrl = TextEditingController(text: widget.initialDescription);
    _type = widget.initialType;
    _sectors = {widget.initialSector};
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color get _typeColor {
    if (_type == 'critico') return const Color(0xFFDC2626);
    if (_type == 'alerta') return const Color(0xFFD97706);
    return const Color(0xFF3B5BDB);
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
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
            _warningBanner(),
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(20, 8, 20, kb + 100),
                children: [
                  _fieldLabel('Título do Alerta'),
                  const SizedBox(height: 8),
                  _textField(_titleCtrl, 'Título do alerta'),
                  const SizedBox(height: 20),

                  _fieldLabel('Setor Destinatário'),
                  const SizedBox(height: 8),
                  _sectorChips(),
                  const SizedBox(height: 20),

                  _fieldLabel('Tipo de Alerta'),
                  const SizedBox(height: 8),
                  _typeSelector(),
                  const SizedBox(height: 20),

                  _fieldLabel('Descrição'),
                  const SizedBox(height: 8),
                  _textField(_descCtrl, 'Descrição do alerta...', maxLines: 4),
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
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.pencil, color: Color(0xFFD97706), size: 19),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Alerta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2340),
                  ),
                ),
                Text(
                  'Alterações serão notificadas aos destinatários',
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

  Widget _warningBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ao salvar, os destinatários serão re-notificados com a versão atualizada.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFB45309),
                height: 1.4,
              ),
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
                  gradient: LinearGradient(
                    colors: _type == 'critico'
                        ? [const Color(0xFFDC2626), const Color(0xFFB91C1C)]
                        : [const Color(0xFF3B5BDB), const Color(0xFF6741D9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _typeColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Salvar Alterações',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
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
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
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

  Widget _sectorChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _sectorOptions.map((s) {
        final sel = _sectors.contains(s);
        return GestureDetector(
          onTap: () => setState(() => sel ? _sectors.remove(s) : _sectors.add(s)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF3B5BDB) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? const Color(0xFF3B5BDB) : const Color(0xFFE8EAF0)),
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
      }).toList(),
    );
  }

  Widget _typeSelector() {
    const types = [
      (key: 'comunicado', label: 'COMUNICADO', color: Color(0xFF3B5BDB)),
      (key: 'alerta', label: 'ALERTA', color: Color(0xFFD97706)),
      (key: 'critico', label: 'CRÍTICO', color: Color(0xFFDC2626)),
    ];

    return Row(
      children: types.map((t) {
        final sel = _type == t.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: t.key != 'critico' ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _type = t.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? t.color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? t.color : const Color(0xFFE8EAF0),
                    width: sel ? 0 : 1.5,
                  ),
                  boxShadow: sel
                      ? [BoxShadow(color: t.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      t.key == 'critico'
                          ? Icons.warning_rounded
                          : t.key == 'alerta'
                              ? Icons.notification_important_rounded
                              : Icons.campaign_rounded,
                      color: sel ? Colors.white : t.color,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : t.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
