import 'package:flutter/material.dart';
import 'package:kssia/src/data/models/promotions_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final double width;

  const AutoScrollText({required this.text, required this.width, Key? key})
      : super(key: key);

  @override
  _AutoScrollTextState createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  late ScrollController _scrollController;
  double scrollOffset = 0.0;
  double textWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setTextWidth();
      startScrolling();
    });
  }

  // Set the width of the text based on its actual rendered size
  void setTextWidth() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    textWidth = textPainter.width;
  }

  void startScrolling() {
    if (_scrollController.hasClients) {
      // Adjust the scroll duration based on text width, the longer the text, the longer it scrolls
      final scrollDuration = (textWidth / 30)
          .clamp(8, 20)
          .toInt(); // Adjust the value for speed control

      Future.delayed(const Duration(seconds: 1), () {
        if (_scrollController.hasClients) {
          _scrollController
              .animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(
                seconds:
                    scrollDuration), // Slower scrolling based on text length
            curve: Curves.linear,
          )
              .then((_) {
            _scrollController.jumpTo(0);
            startScrolling(); // Loop the scrolling
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 30, // Fixed height for the text
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Disable manual scrolling
        child: Row(
          children: [
            Text(
              widget.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 20), // Gap between repeated text
          ],
        ),
      ),
    );
  }
}

String? extractYoutubeId(String url) {
  final RegExp regExp = RegExp(
    r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
    caseSensitive: false,
  );
  final match = regExp.firstMatch(url);
  return match?.group(1);
}

Widget customVideo({
  required String videoId,
  required String title,
}) {
  final ytController = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      disableDragSeek: true,
      autoPlay: false,
      loop: true,
      mute: false,
      controlsVisibleAtStart: true,
      enableCaption: true,
      isLive: false,
    ),
  );

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: YoutubePlayer(
      controller: ytController,
      showVideoProgressIndicator: true,
      aspectRatio: 16 / 9,
    ),
  );
}
