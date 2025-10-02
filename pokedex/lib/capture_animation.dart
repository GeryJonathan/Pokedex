import 'dart:io';      // <-- FIX #1: ADD THIS IMPORT
import 'dart:math';
import 'package:flutter/material.dart';

class CaptureAnimation extends StatefulWidget {
  final String imagePath;

  const CaptureAnimation({super.key, required this.imagePath});

  @override
  State<CaptureAnimation> createState() => _CaptureAnimationState();
}

class _CaptureAnimationState extends State<CaptureAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pokeballSlideAnimation;
  late Animation<double> _imageShrinkAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _successFlashAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    // Sequence:
    // 0ms - 1000ms: Pokeball slides up
    _pokeballSlideAnimation = Tween<double>(begin: 300.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOut),
      ),
    );

    // 1000ms - 1500ms: Image shrinks into the pokeball
    _imageShrinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.33, curve: Curves.easeIn),
      ),
    );

    // 1500ms - 4000ms: Pokeball wiggles
    _wiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -pi / 12), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -pi / 12, end: pi / 12), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: pi / 12, end: -pi / 12), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -pi / 12, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9), // Wiggle happens in the middle
    ));

    // 4000ms - 4500ms: Success flash
    _successFlashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // The Pokémon image that will shrink
            ScaleTransition(
              scale: _imageShrinkAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain, height: 300,),
              ),
            ),
            // The Pokeball that slides up and wiggles
            Transform.translate(
              offset: Offset(0, _pokeballSlideAnimation.value),
              child: RotationTransition(
                turns: _wiggleAnimation,
                child: _controller.value > 0.33 
                  ? Image.asset('assets/pokeball.png', height: 100)
                  : Opacity( // Make it transparent until image is absorbed
                      opacity: _controller.value > 0.22 ? 1.0 : 0.0,
                      child: Image.asset('assets/pokeball.png', height: 100)
                    ),
              ),
            ),
            // Success flash
            if (_controller.value >= 0.9)
              FadeTransition(
                opacity: _successFlashAnimation,
                child: Icon(
                  Icons.auto_awesome, // <-- FIX #2: CORRECTED ICON
                  color: Colors.yellow.shade600,
                  size: 150,
                ),
              ),
          ],
        );
      },
    );
  }
}