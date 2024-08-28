import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsapp/news_response.dart';

class NewsService {
  final String _apiKey = dotenv.env['API_KEY']!;
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<NewsResponse> fetchTopHeadlines({
    String country = 'in',
    String? category,
    int pageSize = 10,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/top-headlines').replace(queryParameters: {
      'country': country,
      'category': category,
      'pageSize': pageSize.toString(),
      'page': page.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'X-Api-Key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NewsResponse.fromJson(data);
    } else if (response.statusCode == 429) {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'API Limit Reached Try Again Later';
      throw Exception('Rate limit exceeded: $message');
    } else {
      throw Exception('Failed to load top headlines');
    }
  }

  Future<NewsResponse> fetchSearchHeadlines({
    required String query,
    int pageSize = 10,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: {
      'q': query,
      'pageSize': pageSize.toString(),
      'page': page.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'X-Api-Key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NewsResponse.fromJson(data);
    } else if (response.statusCode == 429) {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'API Limit Reached Try Again Later';
      throw Exception('Rate limit exceeded: $message');
    } else {
      throw Exception('Failed to load search headlines');
    }
  }
}
