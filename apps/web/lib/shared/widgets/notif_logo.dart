import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotifLogo extends StatelessWidget {
  final double size;

  const NotifLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('N', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: size)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(LucideIcons.bellRing, color: Colors.white, size: size * 0.82),
        ),
        Text('TIF', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: size)),
      ],
    );
  }
}
