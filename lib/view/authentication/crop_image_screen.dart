import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crop/crop.dart';

class CropImageScreen extends StatelessWidget {
  final controller = CropController();
  final File image;

  CropImageScreen({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Crop Image",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            onPressed: () async {
              final cropped = await controller.crop();
              Navigator.pop(context, cropped);
            },
            child: Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Crop(
        shape: CropShape.oval,
        controller: controller,
        child: Image.file(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
