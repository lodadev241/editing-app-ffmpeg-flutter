import 'dart:developer';
import 'dart:io';

import 'package:editor_app/common/custom_snackbar.dart';
import 'package:editor_app/common/custom_text_button.dart';
import 'package:editor_app/features/video/edit_video_view.dart';
import 'package:editor_app/features/video/video_player_widget.dart';
import 'package:editor_app/utils/file_utils.dart';
import 'package:flutter/material.dart';

class SelectVideoView extends StatefulWidget {
  const SelectVideoView({super.key});

  @override
  State<SelectVideoView> createState() => _SelectVideoViewState();
}

class _SelectVideoViewState extends State<SelectVideoView> {
  File? selectedVideo;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            height: selectedVideo != null ? null : height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (selectedVideo != null) const SizedBox(height: 30),
                SizedBox(
                  width: width * 0.8,
                  child: selectedVideo == null
                      ? const SizedBox()
                      : VideoPlayerWidget(file: selectedVideo!),
                ),
                const SizedBox(height: 20),
                CustomTextButton(
                  label: "Select a video",
                  onPressed: getVideo,
                  icon: const Icon(Icons.add_a_photo),
                ),
                const SizedBox(height: 20),
                CustomTextButton(
                  label: "Edit video",
                  onPressed: navigateToEditView,
                  icon: const Icon(Icons.edit),
                ),
                if (selectedVideo != null) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getVideo() async {
    final selectedFile = await FileUtils.getVideoFromGallery();
    if (selectedFile != null) {
      setState(() {
        selectedVideo = selectedFile;
      });
    }
    log(selectedFile.toString());
  }

  void navigateToEditView() {
    if (selectedVideo != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditVideoView(
            file: selectedVideo!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(
            content: "Please select a video", width: 200, seconds: 2),
      );
    }
  }
}
