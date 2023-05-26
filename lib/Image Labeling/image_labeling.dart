import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ImageLabeling extends StatefulWidget {
  const ImageLabeling({Key? key}) : super(key: key);

  @override
  State<ImageLabeling> createState() => _ImageLabelingState();
}

class _ImageLabelingState extends State<ImageLabeling> {
  ui.Image? _image;
  bool showText = false;

  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  PickedFile? _pickedImage;
  var word = '';

  getImage() async {
    final PickedFile? pickedImage =
        await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage;
      _image = null;
    });
    if (_pickedImage != null) {
      final File file = File(_pickedImage!.path);
      Uint8List bytes = await file.readAsBytes();
      final ui.Image image = await decodeImageFromList(bytes);
      setState(() {
        _image = image;
      });
    }
  }

  labelsFromImage() async {
    try {
      final ImageLabelerOptions options =
          ImageLabelerOptions(confidenceThreshold: 0.6);
      final imageLabeler = ImageLabeler(options: options);
      final inputImage = InputImage.fromFilePath(_pickedImage!.path);

      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputImage);

      for (ImageLabel label in labels) {
        final String text = label.label;
        final int index = label.index;
        final double confidence = label.confidence;
        setState(() {
          word = '$word\n$text';
        });
        print(index.toString());
        print(confidence.toString());
      }
      imageLabeler.close();
    } catch (e) {
      print('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Labeling'),
        actions: [
          IconButton(
              onPressed: () {
                getImage();
                showText = false;
                word = '';
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
                child: AspectRatio(
                    aspectRatio: _image!.width / _image!.height,
                    child: Image(image: FileImage(File(_pickedImage!.path)))),
              ),
            ),
          showText
              ? Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text(word.toString())),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(80),
                  child: InkWell(
                    onTap: () {
                      labelsFromImage();
                      showText = true;
                      if (word == null) {
                        setState(() {
                          word = 'Text not detected';
                        });
                      }
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
                          'Read',
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
