import 'package:flutter/material.dart';

/// Botão reutilizável do sistema NOTIF.
/// Suporta estados: loading, outlined, danger e hover.
/// Funciona em Web, Desktop e Mobile.
class NotifButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDanger;
  final IconData? icon;
  final double? width;
  final Color? color;

  const NotifButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDanger = false,
    this.icon,
    this.width,
    this.color,
  });

  @override
  State<NotifButton> createState() => _NotifButtonState();
}

class _NotifButtonState extends State<NotifButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.color ?? (widget.isDanger ? Colors.red : Colors.blue);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.isOutlined
              ? Colors.transparent
              : primaryColor.withOpacity(_hover ? .9 : 1),
          borderRadius: BorderRadius.circular(10),
          border: widget.isOutlined ? Border.all(color: primaryColor) : null,
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 6,
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 18,
                              color: widget.isOutlined
                                  ? primaryColor
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.isOutlined
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}