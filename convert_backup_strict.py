import csv
import json
import datetime
import re

source_file = '/Users/federico/Sites/bibliotech/_ressources/bibliogenius_backup_2026-01-18.json'
# We will overwrite the same file to keep it simple for the user
target_file = '/Users/federico/Sites/bibliotech/_ressources/bibliogenius_backup_2026-01-18.json'

def parse_year(year_str):
    if not year_str:
        return None
    cleaned = re.sub(r'[^0-9]', '', year_str)
    if not cleaned:
        return None
    try:
        return int(cleaned)
    except ValueError:
        return None

def clean_str(val):
    if not val:
        return None
    val = val.strip()
    return val if val else None

try:
    books = []
    # Read the file line by line first to handle potential malformed CSV lines if any
    # But csv module is usually robust. 
    # The file has "Title", "Author" etc.
    
    with open(source_file, 'r', encoding='utf-8') as f:
        # Determine if we need to skip lines or handle headers? 
        # The file content viewed previously shows headers on line 1.
        reader = csv.DictReader(f)
        
        for row in reader:
            # Skip empty rows
            if not any(row.values()):
                continue
                
            book = {
                'title': clean_str(row.get('Title', 'Unknown')),
                'author': clean_str(row.get('Author')),
                'isbn': clean_str(row.get('ISBN')),
                'publisher': clean_str(row.get('Publisher')),
                'publication_year': parse_year(row.get('Year')),
                'reading_status': clean_str(row.get('Status')),
                'cover_url': clean_str(row.get('Cover URL')),
                'owned': True,
                # Add default values for required fields that might be missing in CSV
                'subjects': [],
                'user_rating': None,
                'started_reading_at': None,
                'finished_reading_at': None,
                'price': None,
                'digital_formats': []
            }
            
            # Ensure title is present (backend likely requires it)
            if not book['title']:
                book['title'] = "Untitled Book"

            books.append(book)

    backup_data = {
        'version': '1.0',
        'exported_at': datetime.datetime.now().isoformat(),
        'books': books,
        'contacts': [],
        'tags': [],
        'collections': []
    }

    with open(target_file, 'w', encoding='utf-8') as f:
        json.dump(backup_data, f, indent=2, ensure_ascii=False)

    print(f"Successfully converted {len(books)} books to JSON backup format (Strict Mode).")

except Exception as e:
    print(f"Error: {e}")
