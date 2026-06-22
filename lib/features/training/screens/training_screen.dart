import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  int _tapsToday = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Training ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
            const Icon(Icons.school_outlined, color: AppColors.playfulText, size: 28),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clicker Section
              const Text('Clicker button', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _tapsToday++;
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.playfulSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: AppColors.playfulSecondary.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Click!',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.playfulText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_tapsToday taps', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                      Text('today', style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Cute Training Plan
              const Text('Cute training plan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTrainingPlanCard('Sit', Icons.chair_alt_outlined, 0.6, '60%', AppColors.playfulSecondary, false),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard('Come', Icons.pets_outlined, 0.3, '30%', AppColors.playfulPrimary, false),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard('High Five', Icons.pan_tool_outlined, 0.0, '0%', AppColors.playfulTertiary, true),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard('Carrier', Icons.inventory_2_outlined, 0.0, '0%', AppColors.playfulAccentPeach, true),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              PastelCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department_outlined, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        const Text('5 Day Streak!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Keep going!', style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Guides
              Row(
                children: [
                  const Text('Guides ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const Icon(Icons.menu_book_outlined, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              _buildGuideCard('Night crying', Icons.nights_stay_outlined, 'Read →', Icons.nights_stay),
              const SizedBox(height: 12),
              _buildGuideCard('Scratching', Icons.pets_outlined, 'Read →', Icons.pan_tool),
              const SizedBox(height: 12),
              _buildGuideCard('Biting', Icons.mood_bad_outlined, 'Read →', Icons.mood_bad),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingPlanCard(String title, IconData icon, double progress, String percentText, Color color, bool isLocked) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: AppColors.playfulText),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(percentText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const Spacer(),
          if (isLocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.lock_rounded, size: 24, color: AppColors.playfulText),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/cat_avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String title, IconData icon, String actionText, IconData fallbackIcon) {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.playfulText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, size: 24, color: AppColors.playfulText)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.playfulPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(actionText, style: TextStyle(color: AppColors.playfulPrimary, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
