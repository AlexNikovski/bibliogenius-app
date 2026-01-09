import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import 'cached_book_cover.dart';

/// A card showing a book work with multiple editions in a swipeable carousel.
/// Inspired by Gleeph's edition browser.
class WorkEditionCard extends StatefulWidget {
  final String workId;
  final String title;
  final String? author;
  final List<Map<String, dynamic>> editions;
  final Function(Map<String, dynamic>) onAddBook;

  const WorkEditionCard({
    super.key,
    required this.workId,
    required this.title,
    this.author,
    required this.editions,
    required this.onAddBook,
  });

  @override
  State<WorkEditionCard> createState() => _WorkEditionCardState();
}

class _WorkEditionCardState extends State<WorkEditionCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editionCount = widget.editions.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and author
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.author != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.author!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Edition badge
          if (editionCount > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$editionCount ${TranslationService.translate(context, 'editions')}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Edition carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: editionCount,
              itemBuilder: (context, index) {
                final edition = widget.editions[index];
                return _buildEditionSlide(edition);
              },
            ),
          ),

          // Dots indicator
          if (editionCount > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  editionCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Add button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    widget.onAddBook(widget.editions[_currentPage]),
                icon: const Icon(Icons.add),
                label: Text(
                  TranslationService.translate(context, 'add_to_library'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditionSlide(Map<String, dynamic> edition) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CompactBookCover(imageUrl: edition['cover_url'], size: 140),
          ),
          const SizedBox(width: 16),
          // Edition details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (edition['publisher'] != null)
                  _buildDetailRow(Icons.business, edition['publisher']),
                if (edition['publication_year'] != null)
                  _buildDetailRow(
                    Icons.calendar_today,
                    edition['publication_year'].toString(),
                  ),
                if (edition['isbn'] != null)
                  _buildDetailRow(Icons.qr_code, edition['isbn']),
                if (edition['source'] != null)
                  _buildDetailRow(Icons.public, edition['source']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
