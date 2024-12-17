import 'dart:io';

import 'package:editor_app/features/video/save_button.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class EditVideoView extends StatefulWidget {
  final File file;
  const EditVideoView({super.key, required this.file});

  @override
  State<EditVideoView> createState() => _EditVideoViewState();
}

class _EditVideoViewState extends State<EditVideoView> {
  int currentIndex = 0;

  final _trimmer = Trimmer();

  bool _isPlaying = false;

  double _videoStartValue = 0.0;
  double _videoEndValue = 0.0;

  void _initializeVideoPlayer() {
    _trimmer.loadVideo(videoFile: widget.file).then((_) {
      setState(() {});
    });
  }

  void _playVideo() async {
    final playbackState = await _trimmer.videoPlaybackControl(
      startValue: _videoStartValue,
      endValue: _videoEndValue,
    );
    setState(() {
      _isPlaying = playbackState;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Video"),
        actions: [
          SaveButton(
            videoPath: widget.file.path,
            videoStartInMs: _videoStartValue,
            videoEndInMs: _videoEndValue,
          ),
        ],
      ),
      body: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: width * 0.7,
              child: videoViewer(),
            ),
            const SizedBox(height: 20),
            IndexedStack(
              index: currentIndex,
              children: [
                trimViewer(),
                const Text("Audio"),
                const Text("Filters"),
                const Text("Text"),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Trim",
            icon: Icon(Icons.cut),
          ),
          BottomNavigationBarItem(
            label: "Audio",
            icon: Icon(Icons.audiotrack),
          ),
          BottomNavigationBarItem(
            label: "Filters",
            icon: Icon(Icons.filter),
          ),
          BottomNavigationBarItem(
            label: "Text",
            icon: Icon(Icons.text_fields),
          ),
        ],
      ),
    );
  }

  Widget trimViewer() {
    return TrimViewer(
      trimmer: _trimmer,
      viewerHeight: 50,
      viewerWidth: MediaQuery.sizeOf(context).width * 0.9,
      type: ViewerType.fixed,
      durationStyle: DurationStyle.FORMAT_MM_SS,
      onChangeStart: (value) => _videoStartValue = value,
      onChangeEnd: (value) => _videoEndValue = value,
      onChangePlaybackState: (value) {
        setState(() {
          _isPlaying = value;
        });
      },
      editorProperties: const TrimEditorProperties(
        circlePaintColor: Colors.black,
        borderPaintColor: Colors.black,
      ),
      durationTextStyle: const TextStyle(color: Colors.black),
    );
  }

  Widget videoViewer() {
    final aspectRatio =
        _trimmer.videoPlayerController?.value.aspectRatio ?? 16 / 9;

    return GestureDetector(
      onTap: _playVideo,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            VideoViewer(trimmer: _trimmer),
            Center(
              child: Opacity(
                opacity: _isPlaying ? 0 : 1,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
