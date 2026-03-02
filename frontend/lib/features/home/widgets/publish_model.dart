import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart'; // <-- Adicionado
import '../../../core/theme/app_colors.dart';

class PublishModal extends StatefulWidget {
  // Atualizado para receber também a lista de arquivos
  final Function(String, List<PlatformFile>) onPublish;

  const PublishModal({super.key, required this.onPublish});

  @override
  State<PublishModal> createState() => _PublishModalState();
}

class _PublishModalState extends State<PublishModal> {
  final TextEditingController _postController = TextEditingController();
  
  // Lista para armazenar os arquivos selecionados
  final List<PlatformFile> _arquivosSelecionados = [];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  // Função para chamar o File Picker nativo
  Future<void> _selecionarArquivo({required FileType tipo, List<String>? extensoes}) async {
    try {
      FilePickerResult? resultado = await FilePicker.platform.pickFiles(
        type: tipo,
        allowedExtensions: extensoes,
        allowMultiple: true,
      );

      if (resultado != null) {
        setState(() {
          _arquivosSelecionados.addAll(resultado.files);
        });
      }
    } catch (e) {
      debugPrint("Erro ao selecionar arquivo: $e");
    }
  }

  // Função para remover um arquivo selecionado
  void _removerArquivo(int index) {
    setState(() {
      _arquivosSelecionados.removeAt(index);
    });
  }

  void _handlePublish() {
    // Agora permite publicar se houver texto OU arquivo
    if (_postController.text.trim().isEmpty && _arquivosSelecionados.isEmpty) return; 
    
    widget.onPublish(_postController.text, _arquivosSelecionados);
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
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
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
                  // Prévia dos arquivos selecionados
                  if (_arquivosSelecionados.isNotEmpty) _buildFilesPreview(),
                ],
              ),
            ),
            const Divider(),
            _buildModalActions(),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar a lista de arquivos selecionados antes de postar
  Widget _buildFilesPreview() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _arquivosSelecionados.length,
        itemBuilder: (context, index) {
          final arquivo = _arquivosSelecionados[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: Chip(
              label: Text(
                arquivo.name,
                style: GoogleFonts.inter(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              onDeleted: () => _removerArquivo(index),
              deleteIcon: const Icon(LucideIcons.x, size: 16),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.image, color: Colors.blue),
          onPressed: () => _selecionarArquivo(
            tipo: FileType.image, // Mudamos para custom
          ),
        ),
      ],
    );
  }
}