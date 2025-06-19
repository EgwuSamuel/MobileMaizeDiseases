import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'display_image_page.dart';
import 'feedback_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();
  User? _user;
  String? _fullName;
  Uint8List? _imageData;
  String? _prediction;
  double? _confidenceLevel;
  bool _isLoading = false;
  tfl.Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
    userStream.listen((user) {
      setState(() {
        _user = user;
        _fetchFullName();
      });
    });
  }

  Future<void> _fetchFullName() async {
    if (_user != null) {
      DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child('users').child(_user!.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.value != null) {
        Map<String, dynamic> userData = snapshot.value as Map<String, dynamic>;
        setState(() {
          _fullName = userData['full_name'];
        });
      }
    }
  }

  Future<void> _loadModel() async {
    _interpreter = await tfl.Interpreter.fromAsset('lib/ml/best_float32.tflite');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageData = await pickedImage.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _runModelOnImage() async {
    if (_imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Decode and resize image
      img.Image? image = img.decodeImage(_imageData!);
      if (image == null) {
        throw Exception("Image decoding failed");
      }
      image = img.copyResize(image, width: 224, height: 224);

      // Load labels.txt if not already loaded
      List<String> labels = [];
      String labelsData = await rootBundle.loadString('lib/ml/labels.txt');
      labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();

      // Prepare input tensor
      var input = List.generate(1, (_) => List.generate(224, (_) => List.generate(224, (_) => List.filled(3, 0.0))));
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          img.Pixel pixel = image.getPixel(x, y);

          double red = pixel.r / 255.0;
          double green = pixel.g / 255.0;
          double blue = pixel.b / 255.0;

          input[0][y][x] = [red, green, blue];
        }
      }

      // Ensure correct output list initialization
      var output = List.generate(1, (_) => List.filled(labels.length, 0.0));

      // Run model inference
      _interpreter?.run(input, output);

      // Find the highest confidence score
      int maxIndex = 0;
      double maxConfidence = output[0][0];
      for (int i = 1; i < labels.length; i++) {
        if (output[0][i] > maxConfidence) {
          maxConfidence = output[0][i];
          maxIndex = i;
        }
      }

      // Get the corresponding label
      String predictionLabel = labels[maxIndex];

      setState(() {
        _prediction = predictionLabel;
        _confidenceLevel = maxConfidence * 100;
        _isLoading = false;
      });

      // Navigate to result page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayImagePage(
            imageData: _imageData!,
            prediction: _prediction!,
            confidenceLevel: _confidenceLevel!,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running model: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maize Plant Disease Detection'),
        backgroundColor: Color.fromARGB(255, 7, 107, 35),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 7, 107, 35)),
              accountName: Text(_fullName ?? 'User'),
              accountEmail: Text(_user?.email ?? 'No Email'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : NetworkImage('https://via.placeholder.com/150'),
              ),
            ),
            ListTile(
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FeedbackPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageData != null) Image.memory(_imageData!),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          overlayColor: const Color.fromARGB(255, 7, 107, 35),
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: Text(
                          'Pick Image',
                          style:
                          TextStyle(color: Color.fromARGB(255, 12, 84, 36)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          overlayColor: const Color.fromARGB(255, 7, 107, 35),
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                        child: Text('Capture Image',
                            style: TextStyle(
                                color: Color.fromARGB(255, 12, 84, 36))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _runModelOnImage,
                    style: ElevatedButton.styleFrom(
                      overlayColor: const Color.fromARGB(255, 7, 107, 35),
                    ),
                    child: const Text('Predict Disease',
                        style:
                        TextStyle(color: Color.fromARGB(255, 12, 84, 36))),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 12, 84, 36),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
