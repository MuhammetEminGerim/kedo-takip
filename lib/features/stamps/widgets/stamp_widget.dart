import 'package:flutter/material.dart';
import 'dart:io';
import '../../../shared/models/stamp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StampWidget extends StatelessWidget {
  final Stamp stamp;
  final VoidCallback? onLongPress;

  const StampWidget({
    super.key,
    required this.stamp,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  child: Image.file(
                    File(stamp.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
      child: CustomPaint(
        painter: StampPainter(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(stamp.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              if (stamp.caption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stamp.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dancingScript(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
              if (stamp.caption.isEmpty) const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(stamp.date),
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    const double holeRadius = 4.0;
    const double spacing = 12.0;

    final holesPath = Path();

    // Top and Bottom holes
    for (double x = spacing; x < size.width; x += spacing) {
      holesPath.addOval(Rect.fromCircle(center: Offset(x, 0), radius: holeRadius));
      holesPath.addOval(Rect.fromCircle(center: Offset(x, size.height), radius: holeRadius));
    }

    // Left and Right holes
    for (double y = spacing; y < size.height; y += spacing) {
      holesPath.addOval(Rect.fromCircle(center: Offset(0, y), radius: holeRadius));
      holesPath.addOval(Rect.fromCircle(center: Offset(size.width, y), radius: holeRadius));
    }

    final finalPath = Path.combine(PathOperation.difference, path, holesPath);

    canvas.drawPath(finalPath, shadowPaint);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
