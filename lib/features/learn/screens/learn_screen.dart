import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn & Train 🎓'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClickerTrainingCard(context),
            const SizedBox(height: 32),
            const Text('Training Videos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildVideoPlaceholder(context, 'How to Clicker Train Your Cat', '5 mins'),
            _buildVideoPlaceholder(context, 'Litter Box Basics', '3 mins'),
            const SizedBox(height: 32),
            const Text('Helpful Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildArticleCard(context, 'Understanding Cat Body Language', 'Learn what your cat is trying to tell you with their tail and ears.'),
            _buildArticleCard(context, 'Best Diet for Indoor Cats', 'A quick guide to portion control and wet vs dry food.'),
            _buildArticleCard(context, 'Why Does My Cat Meow at Night?', "Tips to ensure you and your cat get a good night's sleep."),
          ],
        ),
      ),
    );
  }

  Widget _buildClickerTrainingCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.ads_click, size: 48, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(height: 16),
            const Text('Digital Clicker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'Use this consistent sound to train your cat. Click immediately when they do the right thing, then reward!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would play a sharp "click" sound using audioplayers
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Click! 🔊 Give a treat!'), duration: Duration(milliseconds: 500)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(32),
                elevation: 8,
              ),
              child: const Text('CLICK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context, String title, String duration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(duration, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.article, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Placeholder for opening article
        },
      ),
    );
  }
}
