import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';


Future<List<Uint8List>> extractFrames(String videoPath, int frameCount) async {
  List<Uint8List> frames = [];

  for (int i = 0; i < frameCount; i++) {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
      maxWidth: 300,
      timeMs: (i * 1000), // Время в миллисекундах, на котором нужно получить кадр
    );
    frames.add(uint8list!); // Добавляем кадр в список
  }

  return frames;
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Frames',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Uint8List> videoFrames = [];

  Future<void> _pickVideoAndExtractFrames() async {
    final pickedVideo = await ImagePicker().getVideo(
        source: ImageSource.gallery);

    if (pickedVideo != null) {
      String videoPath = pickedVideo.path;
      List<Uint8List> frames = await extractFrames(videoPath, 8);

      setState(() {
        videoFrames = frames;
      });
    }
  }


  late VideoPlayerController _controller;
  String _selectedVideoPath = '';
  final PageController _pageController = PageController();

  Future<void> _pickVideo() async {
    // final PageController _pageController = PageController();

    final pickedVideo =
    await ImagePicker().getVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _selectedVideoPath = pickedVideo.path;
        _controller = VideoPlayerController.file(File(_selectedVideoPath))
          ..initialize().then((_) {
            setState(() {});
            //_controller.play(); // Воспроизвести видео после инициализации
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 80, // Отступ сверху
                  left: 20, // Отступ слева
                  right: 20, // Отступ справа
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width -
                        MediaQuery.of(context).size.width / 7,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(50), // Закругление краев

                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: FractionallySizedBox(
                          widthFactor: 1, // Пример: 80% ширины экрана
                          heightFactor: 1, // Пример: 60% высоты экрана
                          child: PageView.builder(
                              itemCount: videoFrames.length,
                              itemBuilder: (context, index){
                                return Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: MemoryImage(videoFrames[index]),
                                        fit: BoxFit.cover, // Растянуть изображение
                                      ),
                                    ),
                                  ),
                                );
                              },
                              controller: _pageController),
                        )
                    )
                ),
              )
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  // Отступ снизу
                  child: ElevatedButton(
                      onPressed: _pickVideoAndExtractFrames,
                      child: Text('Загрузить видео'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                        ),
                      )))),
        ]
        )
    );
  }
}