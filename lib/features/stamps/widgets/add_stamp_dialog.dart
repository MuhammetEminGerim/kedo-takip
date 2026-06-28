import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_strings.dart';
import '../providers/stamp_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import 'package:exif/exif.dart';

class AddStampDialog extends ConsumerStatefulWidget {
  final String catId;

  const AddStampDialog({super.key, required this.catId});

  @override
  ConsumerState<AddStampDialog> createState() => _AddStampDialogState();
}

class _AddStampDialogState extends ConsumerState<AddStampDialog> {
  final _captionController = TextEditingController();
  String? _selectedImagePath;
  DateTime? _exifDate;
  late String _selectedCatId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.catId;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      DateTime? extractedDate;
      try {
        final bytes = await File(pickedFile.path).readAsBytes();
        final tags = await readExifFromBytes(bytes);
        if (tags.containsKey('Image DateTime')) {
          final dateStr = tags['Image DateTime']!.printable;
          final parts = dateStr.split(' ');
          final dateParts = parts[0].replaceAll(':', '-');
          final timeParts = parts.length > 1 ? parts[1] : '00:00:00';
          extractedDate = DateTime.parse('$dateParts $timeParts');
        }
      } catch (e) {
        debugPrint('EXIF read error: $e');
      }

      setState(() {
        _selectedImagePath = pickedFile.path;
        _exifDate = extractedDate;
      });
    }
  }

  Future<void> _saveStamp() async {
    if (_selectedImagePath == null) return;
    
    setState(() => _isSaving = true);
    
    await ref.read(stampsProvider.notifier).addStamp(
      _selectedCatId,
      _selectedImagePath!,
      _captionController.text.trim(),
      date: _exifDate,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.get('add_stamp'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Cat Selector (Only if multiple cats exist)
            Consumer(
              builder: (context, ref, child) {
                final cats = ref.watch(catListProvider);
                if (cats.length <= 1) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCatId,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('select_cat', fallback: 'Kedi Seç'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: cats.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCatId = val);
                    },
                  ),
                );
              },
            ),
            
            // Image Preview or Picker
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.only(bottom: 110, top: 16), // Padding to avoid navbar
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: Text(AppStrings.get('camera')),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: Text(AppStrings.get('gallery')),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(AppStrings.get('select_photo'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Caption Input
            TextField(
              controller: _captionController,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: AppStrings.get('caption'),
                hintText: AppStrings.get('caption_hint'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Save Button
            ElevatedButton(
              onPressed: (_selectedImagePath == null || _isSaving) ? null : _saveStamp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(AppStrings.get('save_stamp'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
