import 'package:flutter/cupertino.dart';

class SwipeableRightWrapper extends StatefulWidget {
  const SwipeableRightWrapper({
    super.key,
    required this.child,
    required this.rightScreen,
  });

  final Widget child;
  final Widget rightScreen;

  @override
  State<SwipeableRightWrapper> createState() => _SwipeableRightWrapperState();
}

class _SwipeableRightWrapperState extends State<SwipeableRightWrapper> {
  final PageController _pageController = PageController(viewportFraction: 1.0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isInitialized)
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-(_pageController.page!) * 100, 0),
                child: widget.child,
              );
            },
          )
        else
          const SizedBox(),
        PageView.builder(
          controller: _pageController,
          // hitTestBehavior: HitTestBehavior.deferToChild,
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) return const SizedBox();
            return widget.rightScreen;
          },
        )
      ],
    );
  }
}
