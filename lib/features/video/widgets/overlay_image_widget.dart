import 'package:editor_app/constants/constants.dart';
import 'package:flutter/material.dart';

class OverlayImageWidget extends StatefulWidget {
  final Function(String) getSelectedSticker;
  const OverlayImageWidget({super.key, required this.getSelectedSticker});

  @override
  State<OverlayImageWidget> createState() => _OverlayImageWidgetState();
}

class _OverlayImageWidgetState extends State<OverlayImageWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Text("Cat"),
              Text("Christmas"),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                imagesGridView(0),
                imagesGridView(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imagesGridView(int index) {
    final stickers = Constants.stickers[index];

    return GridView.builder(
      itemCount: stickers.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return GestureDetector(
          onTap: () {
            widget.getSelectedSticker(sticker);
          },
          child: GridTile(
            child: Image.asset(
              sticker,
            ),
          ),
        );
      },
    );
  }
}
