import 'package:editor_app/features/image/select_image_view.dart';
import 'package:editor_app/features/video/select_video_view.dart';
import 'package:editor_app/utils/storage_utils.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  List<Widget> pages = const [
    SelectVideoView(),
    SelectImageView(),
  ];

  @override
  void initState() {
    super.initState();
    StorageUtils.requestStoragePermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera,
            ),
            label: "Video",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image,
            ),
            label: "Picture",
          ),
        ],
      ),
    );
  }
}
