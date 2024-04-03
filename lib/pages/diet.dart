import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/btmnavbar.dart';
import 'video.dart';

class RecipeCompilation {
  final int id;
  final String name;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;

  RecipeCompilation({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}

class Diet extends StatefulWidget {
  const Diet({Key? key}) : super(key: key);

  @override
  _DietState createState() => _DietState();
}

class _DietState extends State<Diet> {
  late String apiEndpoint;
  List<RecipeCompilation> compilations = [];
  List<String> ingredients = ["fat", "protein"];
  String selectedFood = 'protein'; // Default selected body part

  Future<List<RecipeCompilation>> fetchCompilationsByCategory() async {
    final apiUrl =
        '$apiEndpoint/recipes/list?from=0&size=20&tags=under_30_minutes&q=$selectedFood';

    final response = await http.get(Uri.parse(apiUrl), headers: {
      'X-RapidAPI-Key': '39d61d9fafmsh575a3b0634c8064p142d20jsn899bbdceff4b',
      'X-RapidAPI-Host': 'tasty.p.rapidapi.com'
    });

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData['results'] is List) {
        final List<dynamic> results = responseData['results'];
        List<RecipeCompilation> compilations = [];

        for (var result in results) {
          if (result['compilations'] is List &&
              result['compilations'].isNotEmpty) {
            for (var compilation in result['compilations']) {
              final thumbnailUrl = compilation['thumbnail_url'] ??
                  'https://example.com/default_image.jpg';
              compilations.add(RecipeCompilation(
                id: compilation['id'] ?? 0,
                name: compilation['name'] ?? 'No Title',
                description: compilation['description'] ?? 'No description',
                thumbnailUrl: thumbnailUrl,
                videoUrl: compilation['video_url'] ?? '',
              ));
            }
          }
        }

        return compilations;
      } else {
        throw Exception('Unexpected response format: results is not a List');
      }
    } else {
      throw Exception('Failed to load compilations: ${response.statusCode}');
    }
  }

  List<RecipeCompilation> selectedCategoryCompilations = [];

  Future<void> fetchAndSetCompilationsByCategory() async {
    final compilationsByCategory = await fetchCompilationsByCategory();
    setState(() {
      selectedCategoryCompilations = compilationsByCategory;
    });
  }

  int _currentIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    apiEndpoint = 'https://tasty.p.rapidapi.com';
    // Fetch compilations for the selected category
    fetchAndSetCompilationsByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FIT GEEK',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ingredients.map((ingredient) {
                final isSelected = selectedFood == ingredient;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFood = ingredient;
                      });
                      fetchAndSetCompilationsByCategory(); // Fetch compilations for the selected category
                    },
                    style: ButtonStyle(
                      elevation: isSelected
                          ? MaterialStateProperty.all<double>(4.0)
                          : MaterialStateProperty.all<double>(0.0),
                      backgroundColor: isSelected
                          ? MaterialStateProperty.all<Color>(Colors.green)
                          : MaterialStateProperty.all<Color>(
                              Colors.transparent),
                      foregroundColor: isSelected
                          ? MaterialStateProperty.all<Color>(Colors.white)
                          : MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: Text(ingredient),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recipe Compilations by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedCategoryCompilations.length,
              itemBuilder: (context, index) {
                return CompilationCard(
                  compilation: selectedCategoryCompilations[index],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BtmNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

class CompilationCard extends StatelessWidget {
  final RecipeCompilation compilation;

  const CompilationCard({Key? key, required this.compilation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            compilation.thumbnailUrl,
            height: 250.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              compilation.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              compilation.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoPage(videoUrl: compilation.videoUrl),
                  ),
                );
              },
              child: const Text('Watch Video'),
            ),
          ),
        ],
      ),
    );
  }
}
