import 'package:flutter/material.dart';
import 'package:ml_kits/Barcode%20Reader/barcode_reader.dart';
import 'package:ml_kits/Face%20Detection/face_detection.dart';
import 'package:ml_kits/Image%20Labeling/image_labeling.dart';
import 'package:ml_kits/Smart%20Reply/smart_reply.dart';
import 'package:ml_kits/Text%20Reader/text_reader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> names = [
      'Text Reader',
      'Barcode Scanner',
      'Image Labeling',
      'Face Detection',
      'Smart Reply'
    ];
    List<Widget> classes = [
      TextReader(),
      BarcodeReader(),
      ImageLabeling(),
      FaceDetection(),
      SmartReplyPage()
    ];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => classes[index]));
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(40)),
                        child: Center(
                          child: Text(
                            names[index],
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
