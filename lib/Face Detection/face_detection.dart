import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetection extends StatefulWidget {
  const FaceDetection({Key? key}) : super(key: key);

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  ui.Image? _image;
  bool showText = false;
  var imageProperty;
  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  PickedFile? _pickedImage;
  List<Rect> _boundingBoxes = <Rect>[];
  List<Rect> rect = <Rect>[];

  getImage() async {
    final PickedFile? pickedImage =
        await _picker.getImage(source: ImageSource.gallery);
    imageProperty = await pickedImage!.readAsBytes();
    imageProperty = await decodeImageFromList(imageProperty);
    setState(() {
      _pickedImage = pickedImage;
      _image = null;

      imageProperty = imageProperty;
    });
    if (_pickedImage != null) {
      final File file = File(_pickedImage!.path);
      Uint8List bytes = await file.readAsBytes();
      final ui.Image image = await decodeImageFromList(bytes);
      setState(() {
        _image = image;
        _boundingBoxes.clear();
      });
    }
  }

  faceDetector() async {
    try {
      final inputImage = InputImage.fromFilePath(_pickedImage!.path);
      final options = FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.15,
        enableContours: true,
      );
      final faceDetector = GoogleMlKit.vision.faceDetector(options);

      final List<Face> faces = await faceDetector.processImage(inputImage);

      List<Rect> boundingBoxes = [];
      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox!;
        boundingBoxes.add(boundingBox);
      }

      setState(() {
        _boundingBoxes = boundingBoxes;
      });
    } catch (e) {
      print('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
        actions: [
          IconButton(
              onPressed: () {
                getImage();
                showText = false;
              },
              icon: const Icon(
                Icons.add_a_photo,
                size: 25,
              )),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_image != null)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _image!.width / _image!.height,
                      child: Image(
                          image: FileImage(File(_pickedImage!.path)),
                          fit: BoxFit.contain),
                    ),
                    for (Rect boundingBox in _boundingBoxes)
                      Positioned(
                        left: boundingBox.left.toDouble(),
                        top: boundingBox.top.toDouble(),
                        width: boundingBox.width.toDouble(),
                        height: boundingBox.height.toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(80),
            child: InkWell(
              onTap: () {
                faceDetector();
                showText = true;
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Center(
                  child: Text(
                    'Detect Faces',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
