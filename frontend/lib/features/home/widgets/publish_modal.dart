import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PublishModal extends StatefulWidget {
  final Function(String, List<PlatformFile>) onPublish;

  const PublishModal({
    super.key,
    required this.onPublish,
  });

  @override
  State<PublishModal> createState() => _PublishModalState();
}

class _PublishModalState extends State<PublishModal> {
  final TextEditingController _controller = TextEditingController();
  List<PlatformFile> _files = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _files = result.files;
      });
    }
  }

  void _publish() {
    final text = _controller.text.trim();

    if (text.isEmpty && _files.isEmpty) return;

    widget.onPublish(text, _files);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Nova publicação",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "O que você quer compartilhar?",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [

              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickFiles,
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _publish,
                child: const Text("Publicar"),
              ),
            ],
          ),

          if (_files.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "${_files.length} imagem(ns) selecionada(s)",
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}