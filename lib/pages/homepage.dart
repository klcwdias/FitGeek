import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:tflite/tflite.dart';

import '../widgets/btmnavbar.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _highestConfidenceLabel;
  File? _image;
  List<dynamic>? _recognitions;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      _runInference(File(image.path));
    }
  }

  Widget _buildBlurredBackground() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  bool _isInferenceInProgress = false;

  Future<void> _runInference(File image) async {
    if (_isInferenceInProgress) {
      return; // Skip if inference is already in progress
    }

    // Set inference in progress to true
    setState(() {
      _image = image;
      _recognitions = null;
      _highestConfidenceLabel = null;
      _isInferenceInProgress = true;
    });

    // Run inference after the delay
    await Future.delayed(const Duration(seconds: 3));

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4, // Number of classes in your model
    );

    var highestConfidenceLabel = recognitions?.isNotEmpty == true
        ? recognitions!.reduce(
            (a, b) => a['confidence'] > b['confidence'] ? a : b)['label']
        : null;

    // Update the state with the results and set inference in progress to false
    setState(() {
      _image = image;
      _recognitions = recognitions;
      _highestConfidenceLabel = highestConfidenceLabel;
      _isInferenceInProgress = false;
    });
  }

  int _currentIndex = 2;
  final _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  final _key = GlobalKey<ScaffoldState>();
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Builder(builder: (context) {
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            title: const Text('FIT GEEK'),
          ),
          //drawer: ExampleSidebarX(controller: _controller),
          drawer: ExampleSidebarX(controller: _controller),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageCard(),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _getImage(ImageSource.gallery),
                      child: const Text('Select Image'),
                    ),
                    ElevatedButton(
                      onPressed: () => _getImage(ImageSource.camera),
                      child: const Text('Take a Photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _isInferenceInProgress
                    ? _buildLoadingAnimation() // Show loading animation if inference is in progress
                    : _buildPredictionResult(),
              ],
            ),
          ),
          bottomNavigationBar: BtmNavBar(
            currentIndex: _currentIndex,
            onItemSelected: _onItemTapped,
          ),
        ),
      );
    });
  }

  Widget _buildImageCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height *
            0.55, // Adjust this value based on your preferences
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: _image != null
              ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _image == null
            ? const Center(
                child: Text('No image selected.'),
              )
            : null,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(true);
    return true;
  }

  String getTitle() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildLoadingAnimation() {
    return Stack(
      children: [
        // Blurred background
        _buildBlurredBackground(),

        // Loading animation
        Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.orange,
            size: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionResult() {
    return _highestConfidenceLabel != null
        ? Text(
            'Prediction: $_highestConfidenceLabel',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          )
        : Container();
  }
}
