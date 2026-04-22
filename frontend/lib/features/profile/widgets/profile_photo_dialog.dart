import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilePhotoDialog extends StatelessWidget {
  final String currentPath;
  final Function(String) onImagePicked;

  const ProfilePhotoDialog({super.key, required this.currentPath, required this.onImagePicked});

  static void show(BuildContext context, String path, Function(String) onPicked) {
    showDialog(context: context, builder: (_) => ProfilePhotoDialog(currentPath: path, onImagePicked: onPicked));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Foto de Perfil', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: currentPath.isEmpty 
                ? const AssetImage('') as ImageProvider
                : FileImage(File(currentPath)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  onImagePicked(image.path);
                  navigator.pop();
                }
              },
              icon: const Icon(LucideIcons.camera),
              label: const Text('Alterar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}