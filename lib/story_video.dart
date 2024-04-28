import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:story/story_image.dart';
import 'package:video_player/video_player.dart';

class StoryVideo extends StatefulWidget {
  const StoryVideo({
    required super.key,
    required this.url,
  });

  final String url;

  @override
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  late VideoPlayerController controller;
  late final pauseListener = (VideoPlayerController controller) {
    if (!mounted || !controller.value.isInitialized) {
      // Controller is not initialized, do nothing
      return;
    }
    if (storyImageLoadingController.value == StoryImageLoadingState.pause) {
      controller.pause();
    } else if (storyImageLoadingController.value ==
        StoryImageLoadingState.unpause) {
      controller.play();
    }
  };
  late final videoPlayingListener = (VideoPlayerController controller) async {
    if (!mounted || !controller.value.isInitialized) {
      // Controller is not initialized, do nothing
      return;
    }
    final position = await controller.position;
    if ((position ?? Duration.zero) > Duration.zero &&
        storyImageLoadingController.value != StoryImageLoadingState.pause) {
      storyImageLoadingController.value = StoryImageLoadingState.available;
      return;
    }
  };

  @override
  void initState() {
    super.initState();
    storyImageLoadingController.value = StoryImageLoadingState.loading;

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) {
          return; // State is disposed, do nothing
        }
        setState(() {
          controller.play();
        });
      });

    if (storyImageLoadingController.value == StoryImageLoadingState.available) {
      controller.removeListener(() => videoPlayingListener(controller));
    } else {
      controller.addListener(() => videoPlayingListener(controller));
    }

    storyImageLoadingController.addListener(() => pauseListener(controller));
  }

  @override
  void dispose() {
    storyImageLoadingController.removeListener(() => pauseListener(controller));
    controller.removeListener(() => videoPlayingListener(controller));
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller)),
      ),
    );
  }
}
