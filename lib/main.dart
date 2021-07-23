import 'camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


List<CameraDescription> cameras;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();


  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  
  runApp(MyApp(camera: firstCamera,));



}

class MyApp extends StatelessWidget {
final CameraDescription camera;
  const MyApp({Key key, @required this.camera}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return MaterialApp(
        title: 'Sort cam',
        theme: ThemeData(
          primarySwatch:Colors.blue,
        ),
        home: TakePictureScreen(camera: camera)
    );
  }
}
