import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curated_lists.dart';
import '../../services/api_service.dart';

class ImportCuratedListScreen extends StatefulWidget {
  const ImportCuratedListScreen({Key? key}) : super(key: key);

  @override
  _ImportCuratedListScreenState createState() =>
      _ImportCuratedListScreenState();
}

class _ImportCuratedListScreenState extends State<ImportCuratedListScreen> {
  // final ApiService _apiService = ApiService(); // Removed unused field
  bool _isImporting = false;

  Future<void> _importList(CuratedList list) async {
    String selectedStatus = 'wanting'; // Default to "Wishlist"

    final String? confirmedStatus = await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Importer "${list.title}" ?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cela va créer une nouvelle collection avec ${list.books.length} livres.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Statut des livres importés :',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'owned',
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Dans ma bibliothèque'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'to_read',
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border, size: 20),
                            SizedBox(width: 8),
                            Text('À lire'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'wanting',
                        child: Row(
                          children: [
                            Icon(Icons.favorite_border, size: 20),
                            SizedBox(width: 8),
                            Text('Wishlist'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedStatus = val ?? 'owned';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedStatus == 'wanting'
                        ? 'Les livres seront ajoutés à votre wishlist.'
                        : 'Des exemplaires seront créés automatiquement.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selectedStatus),
                  child: const Text('Importer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmedStatus == null) return; // Dialog was cancelled

    final bool shouldMarkAsOwned = confirmedStatus != 'wanting';
    final String readingStatus = confirmedStatus == 'owned'
        ? 'to_read'
        : confirmedStatus;

    if (!mounted) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // 1. Create the collection
      final collection = await apiService.createCollection(
        list.title,
        description: list.description,
      );

      final collectionId = collection.id.toString();
      int successCount = 0;

      // 2. Import books
      for (final book in list.books) {
        try {
          // Prepare book data
          final bookData = {
            'title': book.title,
            'author': book.author,
            'isbn': book.isbn,
            'reading_status': readingStatus,
            'owned': shouldMarkAsOwned,
          };

          // Try Create
          int? bookId;
          final createRes = await apiService.createBook(bookData);

          if (createRes.statusCode == 201) {
            final data = createRes.data;
            if (data is Map && data.containsKey('book')) {
              bookId = data['book']['id'];
            } else {
              bookId = data['id'];
            }
          } else {
            // If creation failed (duplicate), try to find
            if (book.isbn != null && book.isbn!.isNotEmpty) {
              final existingBook = await apiService.findBookByIsbn(book.isbn!);
              if (existingBook != null) {
                bookId = existingBook.id;
              }
            }

            // If still not found, try searching by title
            if (bookId == null) {
              final books = await apiService.getBooks(title: book.title);
              if (books.isNotEmpty) {
                bookId = books.first.id;
              }
            }
          }

          // Link to Collection
          if (bookId != null) {
            await apiService.addBookToCollection(collectionId, bookId);
            successCount++;
          }
        } catch (e) {
          debugPrint('Error importing book ${book.title}: $e');
        }
      }

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Collection "${list.title}" créée avec $successCount livres.',
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Découvrir des Collections')),
      body: _isImporting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Création de la collection et importation des livres...',
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: curatedLists.length,
              itemBuilder: (context, index) {
                final list = curatedLists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      if (list.coverUrl != null)
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(list.coverUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              list.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (list.coverUrl == null) ...[
                              Text(
                                list.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(list.description),
                            const SizedBox(height: 16),
                            Text(
                              'Contient ${list.books.length} livres :',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            // Preview first 3 books
                            ...list.books
                                .take(3)
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.book,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${b.title} - ${b.author}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (list.books.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 24,
                                  top: 4,
                                ),
                                child: Text(
                                  '+ ${list.books.length - 3} autres...',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _importList(list),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Importer la collection'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
