import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _iconSlideAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Pulse animation for icon (subtle heartbeat effect)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Icon animations - appears first with bounce
    _iconSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Text animations - appears after icon
    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Tagline - appears last with gentle fade
    _taglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _mainController.forward();
    
    // Start pulse after main animation completes
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
      }
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF66BB6A), // Lighter green
              Color(0xFF4CAF50), // Standard green
              Color(0xFF43A047), // Slightly darker for depth
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle floating circles background effect
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Icon with pulse - Layered circles
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _iconSlideAnimation.value),
                        child: Opacity(
                          opacity: _iconFadeAnimation.value,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outermost circle (largest, most transparent)
                                    Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    // Middle circle
                                    Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.12),
                                      ),
                                    ),
                                    // Inner circle (lightest green/white)
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart_rounded,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Animated App Name
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Text(
                            'Ace Mall',
                            style: GoogleFonts.lobster(
                              fontSize: 42,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Animated Tagline
                  AnimatedBuilder(
                    animation: _taglineAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineAnimation.value,
                        child: Text(
                          '...serving your needs',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}