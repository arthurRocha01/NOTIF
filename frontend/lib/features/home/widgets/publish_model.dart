// lib/features/home/widgets/publish_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class PublishModal extends StatefulWidget {
  final Function(String) onPublish;

  const PublishModal({super.key, required this.onPublish});

  @override
  State<PublishModal> createState() => _PublishModalState();
}

class _PublishModalState extends State<PublishModal> {
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _handlePublish() {
    if (_postController.text.trim().isEmpty) return;
    widget.onPublish(_postController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.infoBlue,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    'Publicar',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuário Administrador',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                    _buildPrivacyTag(),
                  ],
                ),
              ],
            ),
            Expanded(
              child: TextField(
                controller: _postController,
                maxLines: null,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Sobre o que você quer falar?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const Divider(),
            _buildModalActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.globe, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text('Qualquer pessoa',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildModalActions() {
    return Row(
      children: [
        IconButton(icon: const Icon(LucideIcons.image, color: Colors.blue), onPressed: () {}),
        IconButton(icon: const Icon(LucideIcons.video, color: Colors.green), onPressed: () {}),
        IconButton(icon: const Icon(LucideIcons.fileText, color: Colors.orange), onPressed: () {}),
        const Spacer(),
        IconButton(icon: const Icon(LucideIcons.moreHorizontal), onPressed: () {}),
      ],
    );
  }
}