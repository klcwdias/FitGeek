import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  double bmiResult = 0.0;

  @override
  void initState() {
    super.initState();
    // Load the TFLite model when the app starts
    loadModel();
  }

  loadModel() async {
    var interpreter =
        await Interpreter.fromAsset('lib/assets/converted_model.tflite');

    setState(() {
      _interpreter = interpreter;
    });
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Process the pickedFile, send it to the server, and get BMI result
      File imageFile = File(pickedFile.path);
      double result = await sendImageAndGetBMI(imageFile);
      setState(() {
        bmiResult = result;
      });
    }
  }

  Future<double> sendImageAndGetBMI(File imageFile) async {
    // Perform inference locally using the TFLite model
    double bmiResult = await performLocalInference(imageFile);

    // Uncomment the following line if you want to use server-side inference
    // double bmiResult = await sendImageToServer(imageFile);

    return bmiResult;
  }

  Future<double> performLocalInference(File imageFile) async {
    // Load the image as input tensor
    var inputImageData =
        await imageToByteListUint8(imageFile, 224, 224, 127.5, 127.5);

    // Perform inference
    var output = List.filled(1 * 1, 0)
        .reshape([1, 1]); // Assuming output shape is [1, 1]
    _interpreter.run(inputImageData, output);

    // Extract the result directly as a double
    double bmiResult = output[0][0];

    return bmiResult;
  }

  Future<Uint8List> imageToByteListUint8(
      File file, int width, int height, double mean, double std) async {
    var imageBytes = await file.readAsBytes();
    var image = Uint8List.fromList(imageBytes);

    var byteList = Float32List(1 * width * height * 3);
    var buffer = ByteData.sublistView(byteList.buffer as TypedData);

    int byteIndex = 0;
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        int pixel = image[byteIndex++];
        buffer.setFloat32(
            (j * width + i) * 3 * 4, (pixel - mean) / std, Endian.little);
      }
    }

    return byteList.buffer.asUint8List();
  }

  Future<double> sendImageToServer(File imageFile) async {
    var uri = Uri.parse('http://127.0.0.1:5000/process_image');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      // Parse the response and get BMI result
      Map<String, dynamic> data =
          json.decode(await response.stream.bytesToString());
      double bmiResult = data['bmi'];
      return bmiResult;
    } else {
      // Handle error
      throw Exception('Failed to process image');
    }
  }

  late Interpreter _interpreter; // Reference to the TFLite interpreter

  @override
  void dispose() {
    // Clean up resources when the widget is disposed
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Predictor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: const Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('Take a Photo'),
            ),
            const SizedBox(height: 20),
            Text(
              'BMI Result: $bmiResult',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
