import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun Fact App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple[200],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[800],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: FunFactPage(onThemeToggle: _toggleTheme),
    );
  }
}

class FunFactPage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const FunFactPage({super.key, required this.onThemeToggle});

  @override
  State<FunFactPage> createState() => _FunFactPageState();
}

class _FunFactPageState extends State<FunFactPage> {
  String _currentFact = "Press the button to get a fun fact!";
  List<String> _previousFacts = [];

  Future<void> fetchFact() async {
    const url = 'https://uselessfacts.jsph.pl/random.json?language=en';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Add the current fact to previous facts before updating
          if (_currentFact != "Press the button to get a fun fact!" &&
              _currentFact != "Failed to fetch fact. Try again later." &&
              _currentFact != "An error occurred: " &&
              _currentFact != "No fact available at the moment.") {
            _previousFacts.insert(0, _currentFact);
          }

          _currentFact = data['text'] ?? "No fact available at the moment.";
        });
      } else {
        setState(() {
          _currentFact = "Failed to fetch fact. Try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _currentFact = "An error occurred: $e";
      });
    }
  }

  void _showPreviousFacts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Previous Fun Facts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: _previousFacts.isEmpty
              ? const Text('No previous facts yet.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _previousFacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _previousFacts[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Fun Fact App',
      applicationVersion: '2.0.1',
      children: [
        const Text(
          'Developed by Kubomu Edwin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '© 2024 All Rights Reserved',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fun Fact App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _previousFacts.isNotEmpty ? _showPreviousFacts : null,
            tooltip: 'View Previous Facts',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About App',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _currentFact,
                  key: ValueKey<String>(_currentFact),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: fetchFact,
                    icon: const Icon(Icons.science),
                    label: const Text("Get a Fun Fact"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _previousFacts.isNotEmpty ? _showPreviousFacts : null,
                    icon: const Icon(Icons.history),
                    label: const Text("Previous Facts"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _previousFacts.isNotEmpty
                          ? (Theme.of(context).brightness == Brightness.light
                              ? Colors.deepPurple[300]
                              : Colors.deepPurple[700])
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}