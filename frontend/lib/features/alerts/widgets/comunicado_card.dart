import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // Controladores para os campos de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();

  // NOVO: Variável para armazenar o arquivo selecionado
  PlatformFile? _selectedFile;

  // NOVO: Função para selecionar o arquivo
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Novo Comunicado',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informações Gerais"),
            const SizedBox(height: 16),

            _buildTextField(
              label: "Título do Comunicado",
              hint: "Ex: Atualização do Código de Conduta",
              controller: _tituloController,
            ),
            
            const SizedBox(height: 20),
            
            // Campo de Conteúdo (Maior)
            _buildTextField(
              label: "Conteúdo do Texto",
              hint: "Escreva aqui a mensagem detalhada...",
              controller: _conteudoController,
              maxLines: 8,
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle("Anexos e Mídia"),
            const SizedBox(height: 12),
            
            // Botão de Anexo Atualizado
            _buildAttachmentButton(),
            
            const SizedBox(height: 32),
            
            // Botão de Enviar
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  // ATUALIZADO: Lógica visual e funcional do botão de anexo
  Widget _buildAttachmentButton() {
    final bool hasFile = _selectedFile != null;

    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFEFF6FF) : Colors.white, // Fica azulzinho se tiver arquivo
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), 
            style: BorderStyle.solid
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFile ? LucideIcons.fileCheck : LucideIcons.paperclip, 
              color: hasFile ? const Color(0xFF3B82F6) : const Color(0xFF64748B)
            ),
            const SizedBox(width: 10),
            Expanded( // Expanded evita erro de layout se o nome do arquivo for muito grande
              child: Text(
                hasFile ? _selectedFile!.name : "Adicionar PDF ou Imagem",
                style: GoogleFonts.inter(
                  color: hasFile ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                  fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Se tiver arquivo, mostra um botão para remover
            if (hasFile) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFile = null;
                  });
                },
                child: const Icon(LucideIcons.xCircle, color: Colors.redAccent, size: 20),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Aqui você acessa os dados para enviar:
          // _tituloController.text
          // _conteudoController.text
          // _selectedFile (pode ser null)
          
          print("Título: ${_tituloController.text}");
          print("Conteúdo: ${_conteudoController.text}");
          print("Arquivo: ${_selectedFile?.name}");

          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          "PUBLICAR COMUNICADO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}