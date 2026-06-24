import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/providers/cat_provider.dart';
import '../providers/stamp_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/stamp_widget.dart';
import '../widgets/add_stamp_dialog.dart';

class StampAlbumScreen extends ConsumerStatefulWidget {
  const StampAlbumScreen({super.key});

  @override
  ConsumerState<StampAlbumScreen> createState() => _StampAlbumScreenState();
}

class _StampAlbumScreenState extends ConsumerState<StampAlbumScreen> {
  String? _selectedFilterCatId; // null means 'All'

  @override
  Widget build(BuildContext context) {
    final selectedCat = ref.watch(selectedCatProvider);
    final cats = ref.watch(catListProvider);
    final stamps = ref.watch(stampsProvider);

    final catStamps = _selectedFilterCatId == null 
        ? stamps 
        : stamps.where((s) => s.catId == _selectedFilterCatId).toList();

    return Scaffold(
      backgroundColor: AppColors.playfulBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('stamp_album'),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (cats.isNotEmpty) _buildFilterChips(cats),
          Expanded(
            child: selectedCat == null
                ? Center(child: Text(AppStrings.get('add_cat_first')))
                : catStamps.isEmpty
                    ? _buildEmptyState(context)
                    : _buildAlbumGrid(context, catStamps),
          ),
        ],
      ),
      floatingActionButton: selectedCat != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130.0), // Increased padding to stay clear of floating navbar
              child: FloatingActionButton.extended(
                onPressed: () => _showAddStampDialog(context, _selectedFilterCatId ?? selectedCat.id),
                backgroundColor: AppColors.playfulPrimary,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(AppStrings.get('add_stamp')),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChips(List<dynamic> cats) {
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
              selectedColor: AppColors.playfulPrimary.withOpacity(0.3),
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
              selectedColor: AppColors.playfulPrimary.withOpacity(0.3),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('empty_album'),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
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
