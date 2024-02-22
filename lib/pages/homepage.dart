import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    // Check and request permission
    var status = await Permission.photos.request();

    if (status.isGranted) {
      // Permission granted, proceed with picking image
      try {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          _image = image;
          file = File(image!.path);
        });
        detectImage(file!);
      } catch (e) {
        print('Error picking image: $e');
      }
    } else {
      // Permission denied
      print('Permission denied for accessing photos');
    }
  }

  Future<void> detectImage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    try {
      print("//////////////////////////////////////////////////");
      print(_recognitions);
      print("//////////////////////////////////////////////////");
    } catch (e) {
      print('Error running model: $e');
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}
