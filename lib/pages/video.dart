import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/btmnavbar.dart';

class VideoPage extends StatefulWidget {
  final String videoUrl;

  const VideoPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 /
              9, // You may adjust this aspect ratio as per your video dimensions
          child: VideoPlayerWidget(videoUrl: widget.videoUrl),
        ),
      ),
      bottomNavigationBar: BtmNavBar(
        currentIndex: 1,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _loading = true;
  bool _videoNotFound = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    try {
      await _controller.initialize();
      setState(() {
        _loading = false;
      });
      _controller.play(); // Start video playback
    } catch (error) {
      setState(() {
        _loading = false;
        _videoNotFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_videoNotFound) {
      return const Center(child: Text('Video not found.'));
    } else {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    }
  }
}
