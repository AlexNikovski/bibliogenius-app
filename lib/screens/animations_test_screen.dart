import 'package:flutter/material.dart';
import '../widgets/achievement_pop_animation.dart';
import '../widgets/goal_reached_animation.dart';
import '../widgets/badge_unlock_animation.dart';
import '../widgets/level_up_animation.dart';
import '../widgets/book_complete_animation.dart';
import '../widgets/plus_one_animation.dart';

/// Demo screen to test all gamification animations
class AnimationsTestScreen extends StatelessWidget {
  const AnimationsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Animation Tests'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gamification Animations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap any button to test the animation',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Achievement Pop
            _AnimationCard(
              title: '🏆 Achievement Pop',
              description: 'Toast notification for unlocked achievements',
              color: Colors.amber,
              onTap: () {
                AchievementPopAnimation.show(
                  context,
                  achievementName: 'First Book Added!',
                  achievementIcon: Icons.auto_stories,
                  color: Colors.amber,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Goal Reached
            _AnimationCard(
              title: '🎯 Goal Reached',
              description: 'Fireworks celebration for completed reading goals',
              color: Colors.green,
              onTap: () {
                GoalReachedAnimation.show(
                  context,
                  goalType: 'yearly',
                  booksRead: 25,
                  customMessage: '🎯 Yearly Goal Reached!',
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Badge Unlock
            _AnimationCard(
              title: '🏅 Badge Unlock',
              description: 'Full-screen confetti for new badge',
              color: Colors.purple,
              onTap: () {
                BadgeUnlockAnimation.show(
                  context,
                  badgeName: 'Bibliophile',
                  badgeAssetPath: 'assets/images/badges/bibliophile.svg',
                  badgeColor: const Color(0xFFFF9800),
                  subtitle: '🏆 New Badge Unlocked!',
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Level Up
            _AnimationCard(
              title: '⬆️ Level Up',
              description: 'Progress bar flash for level advancement',
              color: Colors.blue,
              onTap: () {
                LevelUpAnimation.show(
                  context,
                  newLevel: 3,
                  trackName: 'Reader',
                  trackColor: Colors.green,
                  trackIcon: Icons.menu_book,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Book Complete
            _AnimationCard(
              title: '📚 Book Complete',
              description: 'Stars and XP when finishing a book',
              color: Colors.teal,
              onTap: () {
                BookCompleteCelebration.show(
                  context,
                  bookTitle: 'The Great Gatsby',
                  xpEarned: 50,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Plus One
            _AnimationCard(
              title: '+1 Mario Style',
              description: 'Floating +1 when adding a book',
              color: Colors.orange,
              onTap: () {
                PlusOneAnimation.show(context);
              },
            ),
            
            const SizedBox(height: 32),
            
            // Test multiple animations
            ElevatedButton.icon(
              onPressed: () async {
                // Trigger sequence of animations
                AchievementPopAnimation.show(
                  context,
                  achievementName: 'Streak Master!',
                  achievementIcon: Icons.local_fire_department,
                  color: Colors.red,
                );
                
                await Future.delayed(const Duration(milliseconds: 1500));
                
                PlusOneAnimation.show(context);
                
                await Future.delayed(const Duration(milliseconds: 1500));
                
                LevelUpAnimation.show(
                  context,
                  newLevel: 2,
                  trackName: 'Collector',
                  trackColor: Colors.blue,
                  trackIcon: Icons.collections_bookmark,
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Sequence Demo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimationCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AnimationCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.play_circle_filled,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.touch_app,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
