class EducationalMaterial {
  final int id;
  final String title;
  final String description;
  final String author;
  final String publisher;
  final int year;
  final String isbn;
  final String category;
  final String coverImage;
  final String url;

  EducationalMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.publisher,
    required this.year,
    required this.isbn,
    required this.category,
    required this.coverImage,
    required this.url,
  });

  // Factory constructor to create an EducationalMaterial from JSON
  factory EducationalMaterial.fromJson(Map<String, dynamic> json) {
    return EducationalMaterial(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      publisher: json['publisher'],
      year: json['year'],
      isbn: json['isbn'],
      category: json['category'],
      coverImage: json['cover_image'],
      url: json['url'],
    );
  }

  // Convert an EducationalMaterial to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'publisher': publisher,
      'year': year,
      'isbn': isbn,
      'category': category,
      'cover_image': coverImage,
      'url': url,
    };
  }
}
