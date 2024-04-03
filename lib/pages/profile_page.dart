import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/btmnavbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _contactController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Loading user data...');
    DocumentSnapshot userData =
        await _firestore.collection('users').doc(_user.uid).get();
    print('User data loaded: $userData');

    // Check if userData contains the 'email' field
    if (userData.exists && userData.data() != null) {
      Map<String, dynamic>? userDataMap =
          userData.data() as Map<String, dynamic>?;
      if (userDataMap != null && userDataMap.containsKey('email')) {
        setState(() {
          _emailController.text = userDataMap['email'];
        });
      }
    }

    // Set other fields as you were doing before
    setState(() {
      _usernameController.text = userData['username'];
      _ageController.text = userData['age'];
      _contactController.text = userData['contact'];
      _imageURL = userData['img_url'];
    });
  }

  Future<void> _updateUserData() async {
    await _firestore.collection('users').doc(_user.uid).update({
      'username': _usernameController.text,
      'email': _emailController.text,
      'age': _ageController.text,
      'contact': _contactController.text,
      'img_url': _imageURL
    });
    _showSuccessSnackbar('Profile Updated Successfully');
  }

  String _imageURL = '';
  Future<void> _uploadImage() async {
    try {
      if (_auth.currentUser == null) {
        // User is not authenticated, show error message or sign-in prompt
        _showErrorSnackbar("User is not authenticated. Please sign in.");
        return;
      }
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('profilepic/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageReference.putFile(imageFile);
        await uploadTask.whenComplete(() async {
          String imageUrl = await storageReference.getDownloadURL();
          setState(() {
            _imageURL = imageUrl;
          });
        });
      }
      _showSuccessSnackbar('Profile Picture Uploaded');
    } catch (error, stackTrace) {
      _showErrorSnackbar("Error Uploading image : $error");
      print(stackTrace);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [],
      ),
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamed(context, '/home');
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _imageURL != ''
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(_imageURL),
                          )
                        : const CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                AssetImage('assets/default-user.png'),
                          ),
                    Positioned(
                      bottom: 0,
                      child: IconButton(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _usernameController.text,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                          ),
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(labelText: 'Age'),
                          ),
                          TextFormField(
                            controller: _contactController,
                            decoration:
                                const InputDecoration(labelText: 'Contact'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _updateUserData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(43, 166, 129, 1),
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BtmNavBar(
        currentIndex: 4,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
