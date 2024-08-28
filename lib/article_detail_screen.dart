import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/article.dart';
import 'package:newsapp/webview_screen.dart';

// Main Article Detail Screen
class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (conditionally rendered)
              if (article.urlToImage!='No image available')
                Image.network(article.urlToImage),
              const SizedBox(height: 18),

              // Title, Author, and Published Date
              ArticleHeader(article: article),
              const SizedBox(height: 18),

              // Description
              ArticleDescription(description: article.description),
              const SizedBox(height: 18),

              // Content
              ArticleContent(content: article.content),
              const SizedBox(height: 18),

              // Read Full Article Button
              ReadFullArticleButton(url: article.url),
            ],
          ),
        ),
      ),
    );
  }
}

// Header Widget for Title, Author, and Date
class ArticleHeader extends StatelessWidget {
  final Article article;

  const ArticleHeader({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${article.author} | ${DateFormat.yMMMMd().format(DateTime.parse(article.publishedAt))}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// Widget for Article Description
class ArticleDescription extends StatelessWidget {
  final String? description;

  const ArticleDescription({super.key, this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description ?? 'No description available',
      style: const TextStyle(fontSize: 16),
    );
  }
}

// Widget for Article Content
class ArticleContent extends StatelessWidget {
  final String? content;

  const ArticleContent({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content ?? 'No content available',
      style: const TextStyle(fontSize: 16),
    );
  }
}

// Reusable Button Widget for 'Read Full Article'
class ReadFullArticleButton extends StatelessWidget {
  final String url;

  const ReadFullArticleButton({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url),
          ),
        );
      },
      child: const Text('Read Full Article'),
    );
  }
}
