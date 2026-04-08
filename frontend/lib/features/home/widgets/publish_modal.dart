import 'package:file_picker/file_picker.dart'; 
import 'package:flutter/material.dart';
import 'package:notif_app/core/constants/app_colors.dart';

class PublishModal extends StatefulWidget {
  final Function(String, List<PlatformFile>) onPublish;
  const PublishModal({super.key, required this.onPublish});

  @override
  State<PublishModal> createState() => _PublishModalState();
}

class _PublishModalState extends State<PublishModal> {
  final TextEditingController _controller = TextEditingController();
  List<PlatformFile> _selectedFiles = [];

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // 👈 CRÍTICO: Garante que os bytes existam na Web
    );
    if (result != null) setState(() => _selectedFiles = result.files);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 1,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "O que está acontecendo?", 
              border: InputBorder.none
            ),
          ),
          if (_selectedFiles.isNotEmpty && _selectedFiles.first.bytes != null)
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Usamos Image.memory pois withData: true garante os bytes
                child: Image.memory(
                  _selectedFiles.first.bytes!, 
                  fit: BoxFit.cover
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined, color: AppColors.primary), 
                onPressed: _pickFiles
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (_controller.text.isNotEmpty || _selectedFiles.isNotEmpty) {
                    widget.onPublish(_controller.text, _selectedFiles);
                  }
                },
                child: const Text("Publicar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}