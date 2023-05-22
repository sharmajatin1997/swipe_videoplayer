import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'helpers.dart';

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late PageController pageController;
  int currentPageIndex = 0;
  Map<int, ChewieController> chewieControllerMap = {};

  Stream<ChewieController> initializeControllers(int index) async* {
    if (chewieControllerMap[index] != null){
      yield chewieControllerMap[index]!;
      return;
    }
    final controller = VideoPlayerController.network(videoUrls[index]);
    await controller.initialize();

    var chewieControllerInternal = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
    );

    chewieControllerMap[index] = chewieControllerInternal;
    yield chewieControllerInternal;
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int pageIndex) {
    if (pageIndex != currentPageIndex) {
      chewieControllerMap[currentPageIndex]?.pause();
      currentPageIndex = pageIndex;
      chewieControllerMap[currentPageIndex]?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: PageView.builder(
        controller: pageController,
        itemCount: videoUrls.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          return StreamBuilder<ChewieController>(
            stream: initializeControllers(index),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load video URL'));
              } else {
                final chewieControllers = snapshot.data;
                return Center(
                  child: Chewie(
                    controller: chewieControllers!,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
