# News App

A Flutter application for browsing and reading news articles. The app allows users to view news in different categories, search for articles, and view article details. It supports both light and dark themes and provides offline support.

## Features

- **Browse News**: View the latest news articles categorized by topic.
- **Search Functionality**: Search for news articles using keywords.
- **Article Details**: View detailed information about each article, including images.
- **Theming**: Switch between light and dark themes.
- **Offline Support**: Display a no internet icon when offline and refresh when connected.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.24.0 or later)
- Dart (version 3.5 or later)
- Java (OpenJdk 22 or later)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Anurag-996/news-app.git
   
2. Navigate to the project directory:

   ```bash
   cd news-app

3. Install dependencies:
   ```bash
   flutter pub get

### Dependencies
#### This project uses the following dependencies:
- **http: ^1.2.2**:  - For making HTTP requests.
- **connectivity_plus: ^6.0.5**:  - For checking internet connectivity.
- **shared_preferences: ^2.3.2**: - For storing user preferences locally.
- **intl: ^0.19.0**:  -  For internationalization and formatting dates.
- **flutter_dotenv: ^5.1.0**: - For loading environment variables.
- **webview_flutter: ^4.9.0**: - For displaying web content in a web view.
- **url_launcher: ^6.3.0**: - For launching URLs in the browser.
- **flutter_launcher_icons**: - For customizing app icons.

### API Information
#### This app fetches news articles from the [News API.](https://newsapi.org/)
##### Top Headlines Endpoint:
    GET https://newsapi.org/v2/top-headlines?country=in&apiKey=YOUR_API_KEY
##### Parameters:
- **`country`**: The country code (e.g., `in` for India).
- **`apiKey`**: Your API key for authentication.
  
##### Search News Endpoint:
    GET https://newsapi.org/v2/everything?q=SEARCH_QUERY&apiKey=YOUR_API_KEY
    
##### Parameters:
- **`q`**: The search query keyword.
- **`apiKey`**: Your API key for authentication.


### Loading Environment Variables
To securely manage sensitive information such as API keys, this project uses the flutter_dotenv package.

#### Steps to Load .env File:
1. Create a `.env` file in the root of your project:
   ```bash
   touch .env
2. Add your environment variables to the `.env` file:
   ```bash
   API_KEY=your_news_api_key

### Usage

1. Run the app:
   ```bash
   flutter run
2. Explore the different news categories, search for articles, and view article details.

## Known Issues

### Dart SDK Not Configured Error in Android Studio

If you encounter the "Dart SDK not configured" error in Android Studio, you can resolve it by following these steps:

**Invalidate Caches and Restart:**

1. In Android Studio, go to `File` > `Invalidate Caches / Restart`.
2. Click on "Invalidate and Restart" to refresh the project.

This method has been effective in resolving the issue in Android Studio.

