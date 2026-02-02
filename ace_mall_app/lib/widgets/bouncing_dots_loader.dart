import 'package:flutter/material.dart';

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;
  
  const BouncingDotsLoader({
    super.key,
    this.color = const Color(0xFF4CAF50),
    this.size = 12.0,
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = _controller.value - delay;
              final normalizedValue = value < 0 ? value + 1 : value;
              
              double scale = 1.0;
              if (normalizedValue < 0.5) {
                scale = 1.0 + (normalizedValue * 0.4);
              } else {
                scale = 1.2 - ((normalizedValue - 0.5) * 0.4);
              }
              
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
