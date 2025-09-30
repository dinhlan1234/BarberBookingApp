import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AvatarFancyLoading extends StatelessWidget {
  final String imageUrl;

  const AvatarFancyLoading({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.blue,
            size: 100,
          ),
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ],
      ),
    );
  }
}
