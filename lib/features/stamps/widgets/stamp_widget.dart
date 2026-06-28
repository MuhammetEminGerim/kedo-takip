import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../shared/models/stamp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class StampWidget extends ConsumerWidget {
  final Stamp stamp;
  final VoidCallback? onLongPress;

  const StampWidget({
    super.key,
    required this.stamp,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

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
                  child: Center(
                    child: CustomPaint(
                      painter: StampPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Flexible(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(stamp.imagePath),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              if (stamp.caption.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  stamp.caption,
                                  textAlign: TextAlign.center,
                                  style: isModern 
                                    ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))
                                    : GoogleFonts.dancingScript(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('dd MMM yyyy').format(stamp.date),
                                textAlign: TextAlign.right,
                                style: isModern
                                  ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))
                                  : GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: isModern ? _buildModernCard(context) : _buildPlayfulStamp(context),
    );
  }

  Widget _buildModernCard(BuildContext context) {
    return CustomPaint(
      painter: StampPainter(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(stamp.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Color(0xFFE2E8F0), child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (stamp.caption.isNotEmpty)
                            Text(
                              stamp.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          if (stamp.caption.isNotEmpty) const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy').format(stamp.date),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayfulStamp(BuildContext context) {
    return CustomPaint(
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
