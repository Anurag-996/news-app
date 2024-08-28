import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newsapp/Service/news_service.dart';
import 'package:newsapp/news_response.dart';
import 'package:newsapp/article.dart';
import 'package:newsapp/article_detail_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NewsSearchDelegate extends SearchDelegate {
  final NewsService _newsService = NewsService();

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Enter a search term and press search to get results.'),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final query = this.query;
    if (query.isEmpty) {
      return const Center(
        child: Text('Please enter a search term.'),
      );
    }
    return _SearchResults(query: query, newsService: _newsService);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}

class _SearchResults extends StatefulWidget {
  final String query;
  final NewsService newsService;

  const _SearchResults({required this.query, required this.newsService});

  @override
  State<_SearchResults> createState() => __SearchResultsState();
}

class __SearchResultsState extends State<_SearchResults> {
  final List<Article> _articles = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final int _pageSize = 10;
  bool _hasInternet = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    _loadMore(); // Initial load when query is submitted
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _checkInternetConnectivity(result);
    });
  }

  Future<void> _checkInternetConnectivity([List<ConnectivityResult>? result]) async {
    var connectivityResult = result ?? await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      if (_hasInternet && _articles.isEmpty) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            SizedBox(height: 20),
            Text('No Internet Connection', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMore();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: _articles.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _articles.length) {
            return const Center(
              child: Opacity(
                opacity: 0.5,
                child: CircularProgressIndicator(),
              ),
            );
          }
          final article = _articles[index];
          return ListTile(
            title: Text(article.title),
            subtitle: Text(article.description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      setState(() {
        _articles.clear();
        _currentPage = 1;
        _hasMore = true;
        _loadMore();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || !_hasInternet) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final newsResponse = await _fetchHeadlines(widget.query, _currentPage);
      setState(() {
        _isLoading = false;
        _articles.addAll(newsResponse.articles);
        if (newsResponse.articles.length < _pageSize) {
          _hasMore = false;
        }
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<NewsResponse> _fetchHeadlines(String query, int page) {
    return widget.newsService
        .fetchSearchHeadlines(query: query, pageSize: _pageSize, page: page);
  }
}
