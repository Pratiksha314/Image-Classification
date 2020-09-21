import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  bool _isLoading = false ;
  PickedFile _image ;
  List _output ;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((val) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar ( title: Text("Detection App"), ),
      floatingActionButton: FloatingActionButton (
         child: Icon(Icons.image),   onPressed:  chooseImage,  ),
      body: _isLoading ? Container (
         alignment: Alignment.center, child: CircularProgressIndicator())
            : Container (
             width: MediaQuery.of(context).size.width,
              child: Column (
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null ? Container() : Image.file(File(_image.path)),
                  SizedBox( height: 15, ),
                  _output != null  ? Text ( "${_output[0]["label"]}",
                style: TextStyle (
                color: Colors.black,
                fontSize: 25.0,
                background: Paint()..color = Colors.white,
              ), )  : Container()
                ],
              ),
            ), ); }

  chooseImage () async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
       _isLoading = true;
      _image = image; 
    });         
    detectImg(File(image.path));
  }

  detectImg ( File pic ) async {
    var outputImg = await Tflite.runModelOnImage (
        path: pic.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5
    );
    setState(() {
      _isLoading = false;
      _output = outputImg;
    });
  }

  loadModel() async {
    await Tflite.loadModel (
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

}