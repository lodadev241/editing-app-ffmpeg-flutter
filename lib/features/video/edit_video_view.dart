import 'dart:developer';
import 'dart:io';

import 'package:editor_app/constants/constants.dart';
import 'package:editor_app/features/video/save_button.dart';
import 'package:editor_app/features/video/widgets/overlay_image_widget.dart';
import 'package:editor_app/features/video/widgets/trim_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class EditVideoView extends StatefulWidget {
  final File file;
  const EditVideoView({
    super.key,
    required this.file,
  });

  @override
  State<EditVideoView> createState() => _EditVideoViewState();
}

class _EditVideoViewState extends State<EditVideoView> {
  int currentIndex = 0;

  final _trimmer = Trimmer();

  bool _isPlaying = false;

  double _videoStartValue = 0.0;
  double _videoEndValue = 0.0;

  String? selectedSticker;
  Offset _stickerOffset = const Offset(0, 0);
  double? stickerXGap;
  double? stickerYGap;

  late RenderBox _renderBox;
  final _videoPlayerKey = GlobalKey();

  late double videoWidth;
  late double videoHeight;

  late double videoUIWidth;
  late double videoUIHeight;

  late Offset videoTopLeftPosition;
  late Offset videoTopRightPosition;
  late Offset videoBottomLeftPosition;
  late Offset videoBottomRightPosition;

  bool oneTime = false;

  void _initializeVideoPlayer() {
    _trimmer.loadVideo(videoFile: widget.file).then((_) {
      setState(() {});
    });

    _trimmer.videoPlayerController?.addListener(() {
      if (oneTime == false) {
        setState(() {
          videoWidth = _trimmer.videoPlayerController!.value.size.width;
          videoHeight = _trimmer.videoPlayerController!.value.size.height;
          oneTime = true;
        });
        _getVideoPlayerPosition();
      }
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

  void _getVideoPlayerPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderBox =
          _videoPlayerKey.currentContext!.findRenderObject() as RenderBox;

      log("Height: ${_renderBox.size.height}");
      log("Width: ${_renderBox.size.width}");

      // Top-left corner
      videoTopLeftPosition = _renderBox.localToGlobal(Offset.zero);

      // Bottom-right corner
      videoBottomRightPosition = _renderBox.localToGlobal(
        Offset(_renderBox.size.width, _renderBox.size.height),
      );

      // Top-right corner
      videoTopRightPosition =
          _renderBox.localToGlobal(Offset(_renderBox.size.width, 0));

      // Bottom-left corner
      videoBottomLeftPosition = _renderBox.localToGlobal(
        Offset(0, _renderBox.size.height),
      );

      log("Top-Left: $videoBottomLeftPosition");
      log("Top-Right: $videoTopRightPosition");
      log("Bottom-Right: $videoBottomRightPosition");
      log("Bottom-Left: $videoBottomLeftPosition");

      setState(() {
        videoUIHeight = _renderBox.size.height;
        videoUIWidth = _renderBox.size.width;

        _stickerOffset = Offset(
          (videoTopRightPosition.dx - videoTopLeftPosition.dx) / 2,
          (videoBottomRightPosition.dy - videoTopRightPosition.dy) / 2,
        );

        stickerXGap = _stickerOffset.dx * (videoWidth / videoUIWidth);
        stickerYGap = _stickerOffset.dy * (videoHeight / videoUIHeight);
      });
    });
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
            videoStartInMs: _videoStartValue > 0.01 ? _videoStartValue : 0.01,
            videoEndInMs: _videoEndValue,
            imagePath: selectedSticker,
            stickerX: stickerXGap,
            stickerY: stickerYGap,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                key: _videoPlayerKey,
                width: width * 0.7,
                child: videoViewer(),
              ),
              const SizedBox(height: 20),
              IndexedStack(
                index: currentIndex,
                children: [
                  trimViewerWidget(),
                  const Text("Audio"),
                  overlayImageWidget(),
                  const Text("Text"),
                ],
              )
            ],
          ),
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

  Widget overlayImageWidget() {
    return OverlayImageWidget(
      getSelectedSticker: (value) {
        setState(() {
          selectedSticker = value;
        });
        log(selectedSticker.toString());
      },
    );
  }

  Widget trimViewerWidget() {
    return Center(
      child: TrimWidget(
        trimmer: _trimmer,
        file: widget.file,
        getStartValue: (value) {
          _videoStartValue = value;
        },
        getEndValue: (value) {
          _videoEndValue = value;
        },
        getPlayingState: (value) {
          setState(() {
            _isPlaying = value;
          });
        },
      ),
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
            selectedSticker == null ? const SizedBox() : stickerWidget(),
          ],
        ),
      ),
    );
  }

  Widget stickerWidget() {
    return Positioned.fromRect(
      rect: Rect.fromPoints(
        Offset(_stickerOffset.dx, _stickerOffset.dy),
        Offset(_stickerOffset.dx + 64, _stickerOffset.dy + 64),
      ),
      child: Draggable(
        onDragUpdate: (details) {
          log(details.globalPosition.toString());
          setState(() {
            _stickerOffset += details.delta;
            if (details.globalPosition.dx < videoTopLeftPosition.dx) {
              _stickerOffset = Offset(
                0,
                _stickerOffset.dy,
              );
            }
            if (details.globalPosition.dx > videoTopRightPosition.dx) {
              _stickerOffset = Offset(
                videoTopRightPosition.dx -
                    (details.globalPosition.dx - videoBottomRightPosition.dx) -
                    Constants.stickerSize,
                _stickerOffset.dy,
              );
            }
            if (details.globalPosition.dy < videoTopLeftPosition.dy) {
              _stickerOffset = Offset(
                _stickerOffset.dx,
                0,
              );
            }
            if (details.globalPosition.dy > videoBottomLeftPosition.dy) {
              _stickerOffset = Offset(
                _stickerOffset.dx,
                videoBottomLeftPosition.dy -
                    (details.globalPosition.dy - videoBottomLeftPosition.dy) -
                    Constants.stickerSize -
                    32,
              );
            }
            stickerXGap = _stickerOffset.dx * (videoWidth / videoUIWidth);
            stickerYGap = _stickerOffset.dy * (videoHeight / videoUIHeight);
          });
        },
        feedback: const SizedBox(),
        child: Image.asset(selectedSticker!),
      ),
    );
  }
}
