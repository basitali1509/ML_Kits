import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextReader extends StatefulWidget {
  TextReader({Key? key}) : super(key: key);

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  bool isImageLoaded = false;
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

  getTextFromImage() async {
    try {
      final inputImage = InputImage.fromFilePath(_pickedImage!.path);
      final textDetector = GoogleMlKit.vision.textRecognizer();

      RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      String Text = recognizedText.text;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            setState(() {
              word = Text.toString();
            });
          }
        }
      }
      print(word);
      print(Text.toString());
    } catch (e) {
      print('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Reader'),
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
                      getTextFromImage();
                      showText = true;
                      if (word.isEmpty) {
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
