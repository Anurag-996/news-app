class Article {
  final Source source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;

  Article({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source'] ?? {}),
      author: json['author'] ?? 'Unknown author',
      title: json['title'] ?? 'No title available',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? 'No URL available',
      urlToImage: json['urlToImage'] ?? 'No image available',
      publishedAt: json['publishedAt'] ?? 'Unknown date',
      content: json['content'] ?? 'No content available',
    );
  }
}

class Source {
  final String id;
  final String name;

  Source({
    required this.id,
    required this.name,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] ?? 'unknown-id',
      name: json['name'] ?? 'Unknown Source',
    );
  }
}
