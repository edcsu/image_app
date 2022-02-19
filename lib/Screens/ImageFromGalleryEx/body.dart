import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_app/Models/file_metadata.dart';
import 'package:image_app/Screens/Home/body.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class ImageFromGalleryEx extends StatefulWidget {
  final type;
  const ImageFromGalleryEx(this.type, {Key? key}) : super(key: key);

  @override
  ImageFromGalleryExState createState() => ImageFromGalleryExState(this.type);
}

class ImageFromGalleryExState extends State<ImageFromGalleryEx> {
  var _image;
  var _imagePath;
  var imagePicker;
  var resultData;
  FileMetadata? _fileMetadata;
  var type;

  ImageFromGalleryExState(this.type);

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(type == ImageSourceType.camera
              ? "Image from Camera"
              : "Image from Gallery")),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var source = type == ImageSourceType.camera
                    ? ImageSource.camera
                    : ImageSource.gallery;
                XFile? image = await imagePicker.pickImage(
                    source: source,
                    imageQuality: 50,
                    preferredCameraDevice: CameraDevice.front);
                setState(() {
                  if (image != null) {
                    _image = File(image.path);
                    _imagePath = image.path;
                  }
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.red[200]),
                child: _image != null
                    ? Image.file(
                        _image,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.red[200]),
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          MaterialButton(
            color: Colors.blue,
            child: const Text(
              "Upload",
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              if (_imagePath != null) {
                var response = await uploadImage(_imagePath);
                setState(() {
                  resultData = response;
                  _fileMetadata = FileMetadata.fromJson(response);
                });
              }
            },
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 400,
            height: 200,
            // decoration: BoxDecoration(color: Colors.red[200]),
            // decoration: BoxDecoration(color: Colors.red[200]),
            child: _fileMetadata == null
                ? const Text("Nothing yet")
                : SizedBox(
                    // decoration: BoxDecoration(color: Colors.red[200]),
                    width: 300,
                    // height: 300,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(15.0),
                      children: <Widget>[
                        const Text(
                          "Files details",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "Name: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _fileMetadata!.name!.substring(1, 40),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Size: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("${_fileMetadata!.size}"),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Type: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("${_fileMetadata!.type}"),
                          ],
                        ),
                      ],
                    )),
          ),
        ],
      ),
    );
  }
}

Future<String> uploadImage(String filePath) async {
  var request = http.MultipartRequest(
      "POST",
      Uri.parse(
          "https://keith-filemetadata-api.herokuapp.com/api/fileanalyse"));

  // request.fields['title'] = "dummyImage";

  var picture = await http.MultipartFile.fromPath('upfile', filePath);

  request.files.add(picture);

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();

    var result = String.fromCharCodes(responseData);

    print(result);

    return result;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return "Failed to upload file";
  }
}
