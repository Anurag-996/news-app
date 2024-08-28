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
  bool _rateLimited = false; // Add this variable to track rate limiting
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
    _checkInternetConnectivity(); // Check internet connectivity on startup
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _hasMore) {
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
    _connectivitySubscription
        .cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  Future<void> _checkInternetConnectivity(
      [List<ConnectivityResult>? result]) async {
    // Get the current connectivity result
    var connectivityResult = result ?? await Connectivity().checkConnectivity();

    // Set the state based on connectivity result
    setState(() {
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        // Mobile network available
        _hasInternet = true;
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        // Wi-Fi is available
        _hasInternet = true;
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        // Ethernet connection available
        _hasInternet = true;
      } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
        // VPN connection active
        _hasInternet = true;
      } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
        // Bluetooth connection available
        _hasInternet = false; // Usually Bluetooth does not provide internet
      } else if (connectivityResult.contains(ConnectivityResult.other)) {
        // Connected to a network which is not in the above mentioned networks
        _hasInternet = true;
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        // No available network types
        _hasInternet = false;
      }

      if (_hasInternet && _articles.isEmpty) {
        _fetchNews();
      }
    });
  }

  Future<void> _fetchNews() async {
    if (!_hasInternet) return; // Do nothing if no internet

    try {
      final newsResponse = await NewsService().fetchTopHeadlines(
        category: _categories[_selectedIndex].toLowerCase(),
        pageSize: 10,
        page: _currentPage,
      );
      setState(() {
        _articles = newsResponse.articles;
        _hasMore = newsResponse.articles.length == 10;
      });
    } catch (e) {
      if (e.toString().contains('rateLimited')) {
        setState(() {
          _rateLimited = true;
        });
      } else {
        // Handle other errors if needed
      }
    }
  }

  Future<void> _loadMoreNews() async {
    if (!_hasMore || !_hasInternet || _rateLimited) {
      return; // Prevent further loading if no more items, no internet, or rate limited
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
      });
    } catch (e) {
      if (e.toString().contains('rateLimited')) {
        setState(() {
          _rateLimited = true;
        });
      } else {
        // Handle other errors if needed
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _currentPage = 1;
        _hasMore = true;
        _articles.clear();
        _rateLimited = false; // Reset rate limit on category change
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
          ? Stack(
              children: [
                ListView.builder(
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
                ),
                if (_rateLimited)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Rate limit reached. Please wait before making more requests.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            )
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
        items: const <BottomNavigationBarItem>[
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
