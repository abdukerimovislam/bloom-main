// 📁 lib/screens/simple_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleSplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SimpleSplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Создаём контроллер анимации
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Анимация увеличения иконки
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Анимация появления текста и индикатора
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // ✅ Добавляем слушатель ЗАРАНЕЕ
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeSplash();
      }
    });

    // Запускаем splash-анимацию
    _startSplashAnimation();
  }

  Future<void> _startSplashAnimation() async {

    // Лёгкая вибрация при старте
    await HapticFeedback.lightImpact();

    // Запуск анимации
    _controller.forward();

    // 🛡️ Защита: если вдруг слушатель не сработает (например, ошибка Flutter)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.status != AnimationStatus.completed) {
        _completeSplash();
      }
    });
  }

  void _completeSplash() {
    if (!mounted) {
      return;
    }


    // Лёгкая вибрация при завершении
    HapticFeedback.lightImpact();

    // Вызываем переданный callback
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.background,
              theme.colorScheme.surface.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌱 Анимированная иконка
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco,
                    color: theme.colorScheme.onPrimary,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ✨ Анимированный текст
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Bloom',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your cycle companion',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 🔄 Анимированный индикатор загрузки
              FadeTransition(
                opacity: _fadeAnimation,
                child: const _LoadingIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final theme = Theme.of(context);

    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
