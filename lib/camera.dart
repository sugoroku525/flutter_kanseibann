import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/services.dart';



String result;
String imagePath;
String image;
bool _isBusy = false;
OpenFileDialogType _dialogType = OpenFileDialogType.image;

SourceType _sourceType = SourceType.photoLibrary;
bool _allowEditing = false;
File _currentFile;
String _savedFilePath;
bool _localOnly = false;

class HexColor extends Color {
static int _getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor;
  }
  return int.parse(hexColor, radix: 16);
}

HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class TakePictureScreen extends StatefulWidget {
  
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
  
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
  
  
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

Widget _buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
      
            
        
          
        
        FloatingActionButton (
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            
            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                
                  imagePath: image?.path,
                
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
      
      ],
    );
  }
  

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
              elevation: 0.0,
      ),
      
      extendBodyBehindAppBar: true,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
body: Stack(
        children: <Widget>[
          
          
          FutureBuilder<void>(
            
            future: _initializeControllerFuture,
              builder: (context, snapshot) {
              
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(_controller),
                );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
          
          _buildControlBar(),
          Container(
                color:Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                    'Tap for photo',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.white),
                ),
          )
        ],
      ),
        ],
),
  
    );

  
  }



}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  DisplayPictureScreen({Key key, this.imagePath}) ;

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState(imagePath:imagePath);
  
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen>{
    
  final String imagePath;
  _DisplayPictureScreenState({this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
              backgroundColor: Colors.black,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.crop_rotate),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.insert_emoticon),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.text_fields),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        color: HexColor('ff0099'),
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
  
          
          floatingActionButton:FloatingActionButton(
            child:Icon(Icons.download_rounded),
          onPressed:imagePath==null?null :()=> _saveFile(false),
          
                
        
          ),
      
    );
  }
  Future<void> _saveFile(bool useData) async {

    try {
      setState(() {
        _isBusy = true;
        if(imagePath!=null){
        _currentFile = File(imagePath);
        }else{
          _currentFile=null;
        }
      
      });
      final data = useData ? await _currentFile.readAsBytes() : null;
      final params = SaveFileDialogParams(
          sourceFilePath: useData ? null : _currentFile.path,
          data: data,
          localOnly: _localOnly,
          fileName: useData ? "untitled" : null);
      result= await FlutterFileDialog.saveFile(params: params);
      print(result);
    } on PlatformException catch (e) {
      print(e);
    } finally {
      setState(() {
        _savedFilePath = result ?? _savedFilePath;
        _isBusy = false;
      });
    }
  }
}

