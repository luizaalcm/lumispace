import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../auth/auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _abrirLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AuthScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = math.sin(_controller.value * math.pi * 2) * 10;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF7F0FF),
                  Color(0xFFEADCFB),
                  Color(0xFFDCC7F4),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -40,
                  child: _BlurBubble(
                    size: 210,
                    color: const Color(0x52FFFFFF),
                    offsetY: offset * 0.4,
                  ),
                ),
                Positioned(
                  top: 160,
                  right: -55,
                  child: _BlurBubble(
                    size: 180,
                    color: const Color(0x42E7CCFF),
                    offsetY: -offset * 0.5,
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -40,
                  child: _BlurBubble(
                    size: 160,
                    color: const Color(0x35FFFFFF),
                    offsetY: offset * 0.55,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'LumiSpace - Diário TPB',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF806F99),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Transform.translate(
                          offset: Offset(0, offset),
                          child: Image.asset(
                            'imagemincial.png',
                            height: 265,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'LumiSpace',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: const Color(0xFF4E4461),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'o seu app para auxiliar no processo terapêutico.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF6F6681),
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _abrirLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1.4,
                                ),
                              ),
                            ),
                            child: const Text('Começar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({
    required this.size,
    required this.color,
    required this.offsetY,
  });

  final double size;
  final Color color;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 48,
              spreadRadius: 14,
            ),
          ],
        ),
      ),
    );
  }
}
