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
            
            // Botão de Anexo Estilizado
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

  Widget _buildAttachmentButton() {
    return InkWell(
      onTap: () {
        // Lógica para selecionar arquivo
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.paperclip, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(
              "Adicionar PDF ou Imagem",
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
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
          // Ação de publicar
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