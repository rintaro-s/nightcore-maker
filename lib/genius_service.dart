import 'dart:convert';
import 'package:http/http.dart' as http;

class GeniusService {
  final String _apiToken = 'GxrmoW6Miet-99SfD73FkMRPJqR8dXZ7r7-iCBEnEgiRvCCzI-ziqprODnQ2aSFR';

  Future<String> fetchLyrics(String songTitle, String artist) async {
    // Search for the song in Genius API
    final searchUrl = Uri.parse(
        'https://api.genius.com/search?q=${Uri.encodeComponent(songTitle)}%20${Uri.encodeComponent(artist)}'
    );
    final response = await http.get(
      searchUrl,
      headers: {
        'Authorization': 'Bearer $_apiToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final songId = json['response']['hits'][0]['result']['id'];

      return await _fetchLyricsById(songId);
    } else {
      throw Exception('Failed to search Genius API');
    }
  }

  Future<String> _fetchLyricsById(int songId) async {
    final songUrl = Uri.parse('https://api.genius.com/songs/$songId');
    final response = await http.get(
      songUrl,
      headers: {
        'Authorization': 'Bearer $_apiToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final lyricsUrl = json['response']['song']['url'];

      return await _scrapeLyricsFromPage(lyricsUrl);
    } else {
      throw Exception('Failed to fetch song details');
    }
  }

  Future<String> _scrapeLyricsFromPage(String lyricsUrl) async {
    final response = await http.get(Uri.parse(lyricsUrl));

    if (response.statusCode == 200) {
      final lyricsPage = response.body;
      // Scrape the lyrics from the page (use regex or a scraping library)
      final start = lyricsPage.indexOf('<div class="lyrics">');
      final end = lyricsPage.indexOf('</div>', start);
      final lyrics = lyricsPage.substring(start, end)
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .trim();
      return lyrics;
    } else {
      throw Exception('Failed to scrape lyrics');
    }
  }
}
