import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../providers/stamp_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/stamp_widget.dart';
import '../widgets/add_stamp_dialog.dart';
import '../../../core/theme/app_theme.dart';

class StampAlbumScreen extends ConsumerStatefulWidget {
  const StampAlbumScreen({super.key});

  @override
  ConsumerState<StampAlbumScreen> createState() => _StampAlbumScreenState();
}

class _StampAlbumScreenState extends ConsumerState<StampAlbumScreen> {
  String? _selectedFilterCatId; // null means 'All'

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    final cats = ref.watch(catListProvider);
    final stamps = ref.watch(stampsProvider);
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

    final catStamps = _selectedFilterCatId == null 
        ? stamps 
        : stamps.where((s) => s.catId == _selectedFilterCatId).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isModern ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Text(
              isModern ? AppStrings.get('stamp_album').toUpperCase() : AppStrings.get('stamp_album'),
              style: isModern 
                ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  )
                : GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isModern,
      ),
      body: Column(
        children: [
          if (cats.isNotEmpty) _buildFilterChips(cats, isModern),
          Expanded(
            child: selectedCat == null
                ? Center(child: Text(AppStrings.get('add_cat_first')))
                : catStamps.isEmpty
                    ? _buildEmptyState(context, isModern)
                    : _buildAlbumGrid(context, catStamps),
          ),
        ],
      ),
      floatingActionButton: selectedCat != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Padding to stay clear of floating navbar
              child: FloatingActionButton.extended(
                onPressed: () => _showAddStampDialog(context, _selectedFilterCatId ?? selectedCat.id),
                backgroundColor: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                label: Text(AppStrings.get('add_stamp'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChips(List<dynamic> cats, bool isModern) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(AppStrings.get('all', fallback: 'Tümü')),
              selected: _selectedFilterCatId == null,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilterCatId = null);
              },
              selectedColor: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: _selectedFilterCatId == null 
                  ? (isModern ? Colors.white : Theme.of(context).colorScheme.onSurface)
                  : (isModern ? const Color(0xFF64748B) : Theme.of(context).colorScheme.onSurface),
                fontWeight: isModern ? FontWeight.w800 : null,
              ),
              backgroundColor: isModern ? Colors.white : null,
              side: isModern ? BorderSide(color: _selectedFilterCatId == null ? Colors.transparent : const Color(0xFFE2E8F0)) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isModern ? 8 : 20)),
            ),
          ),
          ...cats.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.name),
              selected: _selectedFilterCatId == cat.id,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilterCatId = cat.id);
              },
              selectedColor: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: _selectedFilterCatId == cat.id 
                  ? (isModern ? Colors.white : Theme.of(context).colorScheme.onSurface)
                  : (isModern ? const Color(0xFF64748B) : Theme.of(context).colorScheme.onSurface),
                fontWeight: isModern ? FontWeight.w800 : null,
              ),
              backgroundColor: isModern ? Colors.white : null,
              side: isModern ? BorderSide(color: _selectedFilterCatId == cat.id ? Colors.transparent : const Color(0xFFE2E8F0)) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isModern ? 8 : 20)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isModern) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined, size: 80, color: isModern ? const Color(0xFFCBD5E1) : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('empty_album'),
            style: TextStyle(
              fontSize: 18, 
              color: isModern ? const Color(0xFF64748B) : Colors.grey,
              fontWeight: isModern ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<dynamic> catStamps) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.75, // Taller for caption
      ),
      itemCount: catStamps.length,
      itemBuilder: (context, index) {
        final stamp = catStamps[index];
        return StampWidget(
          stamp: stamp,
          onLongPress: () => _showDeleteDialog(context, stamp.id),
        );
      },
    );
  }

  void _showAddStampDialog(BuildContext context, String catId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddStampDialog(catId: catId),
    );
  }

  void _showDeleteDialog(BuildContext context, String stampId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('delete_stamp')),
        content: Text(AppStrings.get('delete_stamp_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              ref.read(stampsProvider.notifier).deleteStamp(stampId);
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.get('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
