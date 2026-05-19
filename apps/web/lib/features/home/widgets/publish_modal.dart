import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/core/constants/app_colors.dart';
import 'package:notif_app/core/constants/app_spacing.dart';

class PublishModal extends StatefulWidget {
  final Function(String title, String content) onPublish;
  const PublishModal({super.key, required this.onPublish});

  @override
  State<PublishModal> createState() => _PublishModalState();
}

class _PublishModalState extends State<PublishModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get _canPublish =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2340),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.messageSquarePlus,
                  color: AppColors.accentLight, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Nova discussão',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.x,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.60)),
              ),
            ),
          ]),

          Divider(height: 28, color: Colors.white.withValues(alpha: 0.10)),

          // Título label
          Text(
            'Título *',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: _inputDecoration(hint: 'Título da discussão'),
          ),

          const SizedBox(height: AppSpacing.md),

          // Conteúdo label
          Text(
            'Descrição *',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _contentController,
            maxLines: 4,
            minLines: 2,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            decoration: _inputDecoration(hint: 'Descreva o assunto...'),
          ),

          const SizedBox(height: AppSpacing.xl),

          Align(
            alignment: Alignment.centerRight,
            child: AnimatedOpacity(
              opacity: _canPublish ? 1.0 : 0.35,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: _canPublish
                    ? () => widget.onPublish(
                          _titleController.text.trim(),
                          _contentController.text.trim(),
                        )
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.send,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Publicar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}