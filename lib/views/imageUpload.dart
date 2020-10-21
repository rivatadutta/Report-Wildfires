import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif_flutter/exif_flutter.dart';
import 'package:exif_flutter/tags.dart';
import 'package:fire_project/views/mapRender.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../globalVariables.dart';
// import 'package:gallery_saver/gallery_saver.dart';

Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

class ImageUpload extends StatefulWidget {
  ImageUpload({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File result;
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  getMetadata() async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      final fileBytes = await file.readAsBytes();
      mainCheckFlow(ByteData.view(fileBytes.buffer));
    }
  }

  Future<void> mainCheckFlow(ByteData bytes) async {
    final tempPath = await getTemporaryDirectory();
    final filePath = tempPath.path + '/' + 'New Image - ${DateTime.now()}.jpeg';
    await writeToFile(
      bytes,
      filePath,
    );

    final attributesFirst = await Exif.getAttributes(filePath);
    print(attributesFirst);

    // final latitude = -4.8055555;
    // final longitude = -39.3555555;
    // final dateTimeOriginal = DateTime.parse('2009-08-11 16:45:32');
    // final userComment = 'You can add a metadata stringified version here';
    //
    // final newAttributes = Metadata(
    //   latitude: latitude,
    //   longitude: longitude,
    //   dateTimeOriginal: dateTimeOriginal,
    //   userComment: userComment,
    // );
    //
    // await Exif.setAttributes(filePath, newAttributes);
    // final attributesSecond = await Exif.getAttributes(filePath);
    // print(attributesSecond);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        backgroundColor: Color(Global.backgroundColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            MapRender(),
                        transitionsBuilder: (context, animation1, animation2,
                                child) =>
                            FadeTransition(opacity: animation1, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),
                    );
                  },
                  backgroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(Icons.map_outlined),
                  heroTag: "mapRender",
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getMetadata,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
        heroTag: "imageSelector",
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
