import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimWidget extends StatefulWidget {
  final File file;
  final Trimmer trimmer;
  final Function(double) getStartValue;
  final Function(double) getEndValue;
  final Function(bool) getPlayingState;
  const TrimWidget({
    super.key,
    required this.file,
    required this.getStartValue,
    required this.getEndValue,
    required this.getPlayingState,
    required this.trimmer,
  });

  @override
  State<TrimWidget> createState() => _TrimWidgetState();
}

class _TrimWidgetState extends State<TrimWidget> {
  @override
  Widget build(BuildContext context) {
    return TrimViewer(
      trimmer: widget.trimmer,
      viewerHeight: 50,
      viewerWidth: MediaQuery.sizeOf(context).width * 0.9,
      type: ViewerType.fixed,
      durationStyle: DurationStyle.FORMAT_MM_SS,
      onChangeStart: (value) {
        widget.getStartValue(value);
      },
      onChangeEnd: (value) {
        widget.getEndValue(value);
      },
      onChangePlaybackState: (value) {
        widget.getPlayingState(value);
      },
      editorProperties: const TrimEditorProperties(
        circlePaintColor: Colors.black,
        borderPaintColor: Colors.black,
      ),
      durationTextStyle: const TextStyle(color: Colors.black),
    );
  }
}
