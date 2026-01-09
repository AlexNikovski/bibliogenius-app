class CuratedBook {
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;

  const CuratedBook({
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
  });
}

class CuratedList {
  final String title;
  final String description;
  final List<CuratedBook> books;
  final String? coverUrl;

  const CuratedList({
    required this.title,
    required this.description,
    required this.books,
    this.coverUrl,
  });
}

/// How to add a new curated list:
/// 1. Create a new `CuratedList` object in the `curatedLists` array below.
/// 2. Provide a `title` and `description` (in French preferred).
/// 3. Add a `coverUrl` (optional) for the list cover.
/// 4. Populate `books` with `CuratedBook` entries. Use ISBN-13 whenever possible to ensure accurate metadata.
///
/// Example:
/// ```dart
/// CuratedList(
///   title: "My New List",
///   description: "A description of this amazing collection.",
///   books: [
///     CuratedBook(title: "Book Title", author: "Author", isbn: "978..."),
///   ],
/// )
/// ```
const List<CuratedList> curatedLists = [
  CuratedList(
    title: "Les 100 livres du siècle (Le Monde)",
    description:
        "Les 100 meilleurs livres du 20ème siècle, selon un sondage réalisé au printemps 1999 par la Fnac et le journal Le Monde.",
    coverUrl: "https://covers.openlibrary.org/b/id/10520666-L.jpg",
    books: [
      CuratedBook(
        title: "L'Étranger",
        author: "Albert Camus",
        isbn: "9782070360024",
      ),
      CuratedBook(
        title: "À la recherche du temps perdu",
        author: "Marcel Proust",
        isbn: "9782070759224",
      ),
      CuratedBook(
        title: "Le Procès",
        author: "Franz Kafka",
        isbn: "9782070368228",
      ),
      CuratedBook(
        title: "Le Petit Prince",
        author: "Antoine de Saint-Exupéry",
        isbn: "9782070612758",
      ),
      CuratedBook(
        title: "La Condition humaine",
        author: "André Malraux",
        isbn: "9782070360024",
      ),
      CuratedBook(
        title: "Voyage au bout de la nuit",
        author: "Louis-Ferdinand Céline",
        isbn: "9782070364886",
      ),
      CuratedBook(
        title: "Les Raisins de la colère",
        author: "John Steinbeck",
        isbn: "9782070360536",
      ),
      CuratedBook(
        title: "Pour qui sonne le glas",
        author: "Ernest Hemingway",
        isbn: "9782070360253",
      ),
      CuratedBook(
        title: "Gatsby le Magnifique",
        author: "F. Scott Fitzgerald",
        isbn: "9782070360451",
      ),
      CuratedBook(
        title: "1984",
        author: "George Orwell",
        isbn: "9782070368228",
      ),
    ],
  ),
  CuratedList(
    title: "Prix Hugo (Meilleur Roman)",
    description:
        "Romans de science-fiction et de fantasy ayant remporté le prestigieux prix Hugo.",
    coverUrl: "https://covers.openlibrary.org/b/id/8259443-L.jpg",
    books: [
      CuratedBook(
        title: "Dune",
        author: "Frank Herbert",
        isbn: "9782266320481",
      ),
      CuratedBook(
        title: "La Main gauche de la nuit",
        author: "Ursula K. Le Guin",
        isbn: "9782253062831",
      ),
      CuratedBook(
        title: "Neuromancien",
        author: "William Gibson",
        isbn: "9782290312841",
      ),
      CuratedBook(
        title: "La Stratégie Ender",
        author: "Orson Scott Card",
        isbn: "9782290349229",
      ),
      CuratedBook(
        title: "Hypérion",
        author: "Dan Simmons",
        isbn: "9782266241915",
      ),
      CuratedBook(
        title: "American Gods",
        author: "Neil Gaiman",
        isbn: "9782846261562",
      ),
      CuratedBook(
        title: "Le Problème à trois corps",
        author: "Liu Cixin",
        isbn: "9782330077020",
      ),
      CuratedBook(
        title: "La Cinquième Saison",
        author: "N.K. Jemisin",
        isbn: "9782290157183",
      ),
    ],
  ),
  CuratedList(
    title: "Classiques du Cyberpunk",
    description:
        "High tech, low life. Les textes fondateurs du genre cyberpunk.",
    coverUrl: "https://covers.openlibrary.org/b/id/12556533-L.jpg",
    books: [
      CuratedBook(
        title: "Neuromancien",
        author: "William Gibson",
        isbn: "9782290312841",
      ),
      CuratedBook(
        title: "Le Samouraï virtuel",
        author: "Neal Stephenson",
        isbn: "9782253076889",
      ),
      CuratedBook(
        title: "Les androïdes rêvent-ils de moutons électriques ?",
        author: "Philip K. Dick",
        isbn: "9782290349229",
      ),
      CuratedBook(
        title: "Carbone modifié",
        author: "Richard K. Morgan",
        isbn: "9782290004081",
      ),
    ],
  ),
];
