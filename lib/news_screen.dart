import 'package:flutter/material.dart';
import 'package:newsapp/Service/news_service.dart';
import 'package:newsapp/article_detail_screen.dart';
import 'package:newsapp/news_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsapp/article.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NewsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const NewsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late ScrollController _scrollController;
  late bool _isDarkMode;
  int _currentPage = 1;
  bool _hasMore = true;
  List<Article> _articles = [];
  int _selectedIndex = 0;
  bool _hasInternet = true;
  bool _rateLimited = false;
  String? _errorMessage; // Error message to display
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<String> _categories = [
    'General',
    'Business',
    'Technology',
    'Health',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _checkInternetConnectivity();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _hasMore &&
            _errorMessage == null) {
          _loadMoreNews();
        }
      });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      _checkInternetConnectivity(result);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnectivity(
      [List<ConnectivityResult>? result]) async {
    var connectivityResult = result ?? await Connectivity().checkConnectivity();

    setState(() {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet) ||
          connectivityResult.contains(ConnectivityResult.vpn) ||
          connectivityResult.contains(ConnectivityResult.other)) {
        _hasInternet = true;
      } else {
        _hasInternet = false;
      }

      if (_hasInternet && _articles.isEmpty) {
        _fetchNews();
      }
    });
  }

  Future<void> _fetchNews() async {
    if (!_hasInternet) return;

    try {
      final newsResponse = await NewsService().fetchTopHeadlines(
        category: _categories[_selectedIndex].toLowerCase(),
        pageSize: 10,
        page: _currentPage,
      );
      setState(() {
        _articles = newsResponse.articles;
        _hasMore = newsResponse.articles.length == 10;
        _errorMessage = null; // Clear any previous error message
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('Rate limit exceeded:')) {
          _rateLimited = true;
          _errorMessage =
              'Rate limit reached. Please wait before making more requests.';
        } else {
          _errorMessage = 'An error occurred: $e';
        }
        _hasMore = false; // Prevent loading more when there's an error
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (!_hasMore || !_hasInternet || _rateLimited) {
      return;
    }

    setState(() {
      _currentPage++;
    });
    try {
      final newsResponse = await NewsService().fetchTopHeadlines(
        category: _categories[_selectedIndex].toLowerCase(),
        pageSize: 10,
        page: _currentPage,
      );
      setState(() {
        _articles.addAll(newsResponse.articles);
        _hasMore = newsResponse.articles.length == 10;
        _errorMessage = null; // Clear any previous error message
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('Rate limit exceeded:')) {
          _rateLimited = true;
          _errorMessage =
              'Rate limit reached. Please wait before making more requests.';
        } else {
          _errorMessage = 'An error occurred: $e';
        }
        _hasMore = false; // Prevent loading more when there's an error
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _currentPage = 1;
        _hasMore = true;
        _articles.clear();
        _rateLimited = false;
        _errorMessage = null; // Clear any previous error message
        _fetchNews();
      });
    }
  }

  void _onSelectedMenuItem(BuildContext context, int item) {
    switch (item) {
      case 0:
        _toggleDarkMode();
        break;
    }
  }

  void _toggleDarkMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
      widget.onThemeChanged(_isDarkMode);
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_categories[_selectedIndex]} News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 30.0,
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(),
              );
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (item) => _onSelectedMenuItem(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(
                    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  title: Text(
                    _isDarkMode ? 'Light Mode' : 'Dark Mode',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _hasInternet
          ? (_errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _articles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _articles.length) {
                      return _hasMore
                          ? const SizedBox(
                              height: 50,
                              child: Center(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : const SizedBox();
                    }
                    final article = _articles[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _isDarkMode ? Colors.white24 : Colors.black12,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  _isDarkMode ? Colors.white70 : Colors.black,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: '${index + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: article.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'General',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: 'Technology',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Sports',
          ),
        ],
      ),
    );
  }
}
