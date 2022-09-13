// import 'package:flutter/material.dart';

// class AnimatedMenuButton extends StatefulWidget {
//   const AnimatedMenuButton({Key? key}) : super(key: key);

//   @override
//   State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
// }

// class _AnimatedMenuButtonState extends State<AnimatedMenuButton>
//     with TickerProviderStateMixin {
//   bool _isPlay = false;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isPlay == false) {
//           _controller.forward();
//           _isPlay = true;
//         } else {
//           _controller.reverse();
//           _isPlay == false;
//         }
//       },
//       child: AnimatedIcon(
//         icon: AnimatedIcons.close_menu,
//         progress: _controller,
//         size: 16,
//         color: Colors.black,
//       ),
//     );
//   }
// }

//////////////////////////////////////////////////////////////

import 'dart:async';

import 'package:flutter/material.dart';

class MenuButtonAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallLike;
  const MenuButtonAnimation({
    Key? key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.smallLike = false,
  }) : super(key: key);

  @override
  _MenuButtonAnimationState createState() => _MenuButtonAnimationState();
}

class _MenuButtonAnimationState extends State<MenuButtonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scale;
  final Tween<double> turnsTween = Tween<double>(
    begin: 1,
    end: 0,
  );

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      // duration: Duration(
      //   milliseconds: widget.duration.inMilliseconds ~/ 2,
      // ),
      duration: Duration(seconds: 1),
    );

    // scale = Tween<double>(begin: 1, end: 1.2).animate(animationController);
    scale =
        CurvedAnimation(parent: animationController, curve: Curves.easeInSine);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MenuButtonAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  startAnimation() async {
    // if (widget.isAnimating || widget.smallLike) {
    //   await animationController.forward();
    //   // await animationController.reverse();
    //   await Future.delayed(Duration(milliseconds: 200));

    //   if (widget.onEnd != null) {
    //     widget.onEnd!();
    //   }
    // }
    if (widget.isAnimating && widget.smallLike) {
      await animationController.forward();
    } else {
      await animationController.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ScaleTransition(
    //   scale: scale,
    //   child: widget.child,
    // );
    return RotationTransition(
      turns: turnsTween.animate(animationController),
      child: widget.child,
    );
  }
}
