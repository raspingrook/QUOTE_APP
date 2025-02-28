import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  // Allow self-signed/expired certificates for development purposes
  HttpOverrides.global = MyHttpOverrides();
  runApp(const QuoteApp());
}

// Custom HTTP overrides to bypass certificate verification
// Note: This should only be used in development, not in production apps
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class QuoteApp extends StatelessWidget {
  final http.Client? httpClient;

  const QuoteApp({Key? key, this.httpClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quotes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QuoteScreen(httpClient: httpClient),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  final http.Client? httpClient;

  const QuoteScreen({Key? key, this.httpClient}) : super(key: key);

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _quote = 'Your quote will appear here';
  String _author = '';
  bool _isLoading = false;
  late http.Client _client;

  @override
  void initState() {
    super.initState();
    // Use the injected client or create a new one if none was provided
    _client = widget.httpClient ?? http.Client();
  }

  @override
  void dispose() {
    // Only close the client if we created it (not the injected one)
    if (widget.httpClient == null) {
      _client.close();
    }
    super.dispose();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client.get(Uri.parse('https://api.quotable.io/random'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data['content'];
          _author = data['author'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _quote = 'Failed to load quote. Status code: ${response.statusCode}';
          _author = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _quote = 'Error: ${e.toString()}';
        _author = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Quotes'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                        _quote,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_author.isNotEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            '— $_author',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _fetchQuote,
                child: const Text('Fetch Quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}