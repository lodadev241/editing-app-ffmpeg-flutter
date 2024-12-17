import 'dart:developer';

import 'package:editor_app/common/custom_snackbar.dart';
import 'package:editor_app/utils/file_utils.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SaveButton extends StatefulWidget {
  final String videoPath;
  final double videoStartInMs;
  final double videoEndInMs;
  const SaveButton({
    super.key,
    required this.videoStartInMs,
    required this.videoEndInMs,
    required this.videoPath,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  final _saveProgress = ValueNotifier<num>(0);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        showProgressDialog();
        _editWithFFmpeg();
      },
      icon: const Icon(Icons.save),
    );
  }

  Future<String> getOutputFilePath() async {
    final directory = await getApplicationCacheDirectory();
    return '${directory.path}/${const Uuid().v4()}.mp4';
  }

  void _editWithFFmpeg() async {
    final outputPath = await getOutputFilePath();

    final trim = '-ss ${widget.videoStartInMs}ms -to ${widget.videoEndInMs}ms';

    final command = '-y $trim -i "${widget.videoPath}" "$outputPath"';

    await FFmpegKit.executeAsync(
      command,
      (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {

          await Gal.putVideo(outputPath).then((_) {
            FileUtils.deleteFile(outputPath);
          });

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar(
              content: "Video saved to gallery",
              width: 200,
              seconds: 2,
            ));
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            _saveProgress.value = 0;
          });

          log("Edit video success");
        } else {
          log("Error occurred!");
        }
      },
      (ffmpegLog) {
        log("FFmpeg Log: ${ffmpegLog.getMessage()}");
      },
      (statistics) {
        final videoDuration = widget.videoEndInMs - widget.videoStartInMs;
        if (statistics.getTime() > 0) {
          num progressValue = (statistics.getTime() / videoDuration) * 100;
          if (progressValue >= 100) {
            progressValue = 99.99;
          }
          _saveProgress.value = progressValue;
        }
      },
    );
  }

  void showProgressDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: _saveProgress,
          builder: (context, value, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text(
                "Editing Video...",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${value.toStringAsFixed(2)}%"),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: value.toDouble() / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.blue.withOpacity(0.4),
                    minHeight: 16,
                  ),
                  const SizedBox(height: 20),
                  const Text("Do not close the app!"),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
