import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Exercise {
  final String id;
  final String name;
  final String gifUrl;
  final String bodyPart;
  final String equipment;
  final String target;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.gifUrl,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
  });
}

class Workout extends StatefulWidget {
  const Workout({Key? key}) : super(key: key);

  @override
  WorkoutState createState() => WorkoutState();
}

class WorkoutState extends State<Workout> {
  List<Exercise> exercises = [];
  List<String> bodyParts = [
    "back",
    "cardio",
    "chest",
    "lower arms",
    "lower legs",
    "neck",
    "shoulders",
    "upper arms",
    "upper legs",
    "waist"
  ];
  String selectedBodyPart = 'chest'; // Default selected body part
  List<String> filteredBodyParts = [];
  late String apiEndpoint;

  Future<List<Exercise>> fetchExercisesByBodyPart() async {
    final apiUrl = '$apiEndpoint/exercises/bodyPart/$selectedBodyPart';

    final response = await http.get(Uri.parse(apiUrl), headers: {
      'X-RapidAPI-Key': '39d61d9fafmsh575a3b0634c8064p142d20jsn899bbdceff4b',
      'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
    });

    if (response.statusCode == 200) {
      final List<dynamic> exercisesData = json.decode(response.body);
      return exercisesData.map((item) {
        final gifUrl =
            item['gifUrl'] ?? 'https://example.com/default_image.jpg';
        return Exercise(
          id: item['id'] ?? '',
          name: item['name'] ?? 'No Title',
          gifUrl: gifUrl,
          bodyPart: item['bodyPart'] ?? '',
          equipment: item['equipment'] ?? '',
          target: item['target'] ?? '',
          secondaryMuscles: List<String>.from(item['secondaryMuscles'] ?? []),
          instructions: List<String>.from(item['instructions'] ?? []),
        );
      }).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  List<Exercise> bodyPartExercisesData = [];

  Future<void> fetchAndSetExercisesByBodyPart() async {
    final exercisesByBodyPart = await fetchExercisesByBodyPart();
    setState(() {
      bodyPartExercisesData = exercisesByBodyPart;
    });
  }

  Future<void> fetchAllExercises() async {
    for (String bodyPart in bodyParts) {
      final apiUrl = '$apiEndpoint/exercises/bodyPart/$bodyPart';

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-API-Key': '39d61d9fafmsh575a3b0634c8064p142d20jsn899bbdceff4b',
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
      });

      if (response.statusCode == 200) {
        final List<dynamic> exercisesData = json.decode(response.body);
        setState(() {
          exercises.addAll(exercisesData.map((item) {
            final gifUrl =
                item['gifUrl'] ?? 'https://example.com/default_image.jpg';
            return Exercise(
              id: item['id'] ?? '',
              name: item['name'] ?? 'No Title',
              gifUrl: gifUrl,
              bodyPart: bodyPart,
              equipment: item['equipment'] ?? '',
              target: item['target'] ?? '',
              secondaryMuscles:
                  List<String>.from(item['secondaryMuscles'] ?? []),
              instructions: List<String>.from(item['instructions'] ?? []),
            );
          }));
        });
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    apiEndpoint = 'https://exercisedb.p.rapidapi.com';
    // Fetch exercises for all body parts
    fetchAllExercises();
    filteredBodyParts = List.from(bodyParts);
    // Fetch exercises for the selected body part
    fetchAndSetExercisesByBodyPart();
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
              children: bodyParts.map((bodyPart) {
                final isSelected = selectedBodyPart == bodyPart;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedBodyPart = bodyPart;
                      });
                      fetchAndSetExercisesByBodyPart(); // Fetch exercises for the selected body part
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
                    child: Text(bodyPart),
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
                'Exercises by Body Part',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bodyPartExercisesData.length,
              itemBuilder: (context, index) {
                return ExerciseCard(exercise: bodyPartExercisesData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({Key? key, required this.exercise}) : super(key: key);

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
            exercise.gifUrl,
            height: 350.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Text(
              'Category: ${exercise.bodyPart}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Target Muscles: ${exercise.target}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Equipment: ${exercise.equipment}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Secondary Muscles: ${exercise.secondaryMuscles}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Display instructions as a list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Display instructions as a list
                for (String instruction in exercise.instructions) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      instruction.trim(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/timer');
              },
              child: const Text('Start Exercise'),
            ),
          ),
        ],
      ),
    );
  }
}
