class Source {
  final String? id;
  final String? name;
  final String? description;
  final String? url;
  final String? category;
  final String? language;
  final String? country;

  Source({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.category,
    required this.language,
    required this.country,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] ?? 'Unknown id',
      name: json['name'] ?? 'Unknown name',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? 'No URL available',
      category: json['category'] ?? 'Uncategorized',
      language: json['language'] ?? 'Unknown language',
      country: json['country'] ?? 'Unknown country',
    );
  }
}

class TopHeadlinesSourcesResponse {
  final String? status;
  final List<Source>? sources;

  TopHeadlinesSourcesResponse({
    required this.status,
    required this.sources,
  });

  factory TopHeadlinesSourcesResponse.fromJson(Map<String, dynamic> json) {
    return TopHeadlinesSourcesResponse(
      status: json['status'] ?? 'Unknown status',
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((item) => Source.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
