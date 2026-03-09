import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PostImage extends StatefulWidget {
  final PlatformFile image;

  const PostImage({
    super.key,
    required this.image,
  });

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = widget.image.bytes;

    if (bytes == null) {
      return Container(
        height: 220,
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFCBD5E1),
            size: 48,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedBuilder(
              animation: _scale,
              builder: (_, child) {
                return Transform.scale(
                  scale: _scale.value,
                  child: child,
                );
              },
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}