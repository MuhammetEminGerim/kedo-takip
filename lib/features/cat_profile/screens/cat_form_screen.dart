import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/models/cat.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';

class CatFormScreen extends ConsumerStatefulWidget {
  final Cat? catToEdit;

  const CatFormScreen({super.key, this.catToEdit});

  @override
  ConsumerState<CatFormScreen> createState() => _CatFormScreenState();
}

class _CatFormScreenState extends ConsumerState<CatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  DateTime? _selectedDate;
  String _gender = 'Female';
  bool _isNeutered = false;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.catToEdit?.name ?? '');
    _breedController = TextEditingController(text: widget.catToEdit?.breed ?? '');
    _weightController = TextEditingController(text: widget.catToEdit?.weight?.toString() ?? '');
    _selectedDate = widget.catToEdit?.birthDate;
    _photoPath = widget.catToEdit?.photoPath;
    if (widget.catToEdit != null) {
      _gender = widget.catToEdit!.gender;
      _isNeutered = widget.catToEdit!.isNeutered;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.playfulBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.playfulText.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.get('choose_photo'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.playfulText)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt_rounded,
                  label: AppStrings.get('camera'),
                  color: AppColors.playfulPrimary,
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library_rounded,
                  label: AppStrings.get('gallery'),
                  color: AppColors.playfulSecondary,
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;

    // Copy to app directory for persistence
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'cat_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

    setState(() {
      _photoPath = savedFile.path;
    });
  }

  Widget _buildPhotoOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.playfulText),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.playfulPrimary,
              onPrimary: Colors.white,
              surface: AppColors.playfulBackground,
              onSurface: AppColors.playfulText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveCat() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('please_select_birth_date'), style: const TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: AppColors.playfulPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        return;
      }

      final weight = double.tryParse(_weightController.text);

      if (widget.catToEdit == null) {
        // Add new
        ref.read(catListProvider.notifier).addCat(
          name: _nameController.text,
          breed: _breedController.text,
          birthDate: _selectedDate!,
          gender: _gender,
          isNeutered: _isNeutered,
          weight: weight,
          photoPath: _photoPath,
        );
      } else {
        // Update existing
        final cat = widget.catToEdit!
          ..name = _nameController.text
          ..breed = _breedController.text
          ..birthDate = _selectedDate!
          ..gender = _gender
          ..isNeutered = _isNeutered
          ..weight = weight
          ..photoPath = _photoPath;
        ref.read(catListProvider.notifier).updateCat(cat);
      }

      context.pop();
    }
  }

  void _deleteCat() {
    if (widget.catToEdit == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.playfulBackground,
        title: Text(AppStrings.get('delete_cat'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
        content: Text(
          '${widget.catToEdit!.name} ${AppStrings.get('are_you_sure_remove')}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.playfulText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(catListProvider.notifier).deleteCat(widget.catToEdit!);
              Navigator.pop(ctx);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(AppStrings.get('delete'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.catToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.playfulBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? '${AppStrings.get('edit_cat')} ' : '${AppStrings.get('add_cat')} ',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText, fontSize: 24),
            ),
            const Text('🐱', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.playfulText),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: _deleteCat,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.playfulPrimary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(color: AppColors.playfulPrimary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          image: _photoPath != null
                              ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                              : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.playfulPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(AppStrings.get('tap_to_change_photo'), style: const TextStyle(color: AppColors.playfulText, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildKawaiiTextField(
                controller: _nameController,
                label: AppStrings.get('name'),
                icon: Icons.pets_rounded,
                validator: (value) => value!.isEmpty ? AppStrings.get('please_enter_name') : null,
              ),
              const SizedBox(height: 16),

              // Breed Field
              _buildKawaiiTextField(
                controller: _breedController,
                label: AppStrings.get('breed'),
                icon: Icons.category_rounded,
                validator: (value) => value!.isEmpty ? AppStrings.get('please_enter_breed') : null,
              ),
              const SizedBox(height: 16),

              // Birth Date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: PastelCard(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.playfulTertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: AppColors.playfulText, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.get('birth_date'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
                          const SizedBox(height: 2),
                          Text(
                            _selectedDate == null ? AppStrings.get('select_date') : DateFormat.yMMMd().format(_selectedDate!),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: _selectedDate == null ? AppColors.playfulText.withOpacity(0.4) : AppColors.playfulText,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.playfulText.withOpacity(0.4)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              PastelCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.playfulSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _gender == 'Female' ? Icons.female_rounded : Icons.male_rounded,
                        color: AppColors.playfulText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(AppStrings.get('gender'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
                    const Spacer(),
                    _buildGenderChip('Female', '♀', AppStrings.get('female')),
                    const SizedBox(width: 8),
                    _buildGenderChip('Male', '♂', AppStrings.get('male')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Neutered
              PastelCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.playfulAccentPeach.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.healing_rounded, color: AppColors.playfulText, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(AppStrings.get('neutered_spayed'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
                    ),
                    Switch(
                      value: _isNeutered,
                      onChanged: (val) => setState(() => _isNeutered = val),
                      activeColor: AppColors.playfulPrimary,
                      activeTrackColor: AppColors.playfulPrimary.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              _buildKawaiiTextField(
                controller: _weightController,
                label: AppStrings.get('weight_kg'),
                icon: Icons.monitor_weight_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                suffixText: AppStrings.get('kg'),
              ),
              const SizedBox(height: 32),

              // Save Button
              GestureDetector(
                onTap: _saveCat,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.playfulPrimary, AppColors.playfulAccentPeach],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.playfulPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isEditing ? AppStrings.get('save_changes') : AppStrings.get('add_cat_button'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKawaiiTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? suffixText,
  }) {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.playfulPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.playfulText, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.playfulText),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText.withOpacity(0.5)),
                suffixText: suffixText,
                suffixStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String value, String symbol, String displayLabel) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.playfulPrimary : AppColors.playfulSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Text(
          '$symbol $displayLabel',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: isSelected ? Colors.white : AppColors.playfulText,
          ),
        ),
      ),
    );
  }
}
