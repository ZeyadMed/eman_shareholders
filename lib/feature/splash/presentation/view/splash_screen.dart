import 'package:eman_shareholders/core/router/app_router.dart';
import 'package:eman_shareholders/core/service_locator/service_locator.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:eman_shareholders/core/style/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

import '../view_model/cubit/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _navigateToOnboarding();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // الأيقونة تيجي من اليمين
    _iconSlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );
    _iconSlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SplashCubit(getIt<SessionManager>())..startSplashScreen(),
      child: BlocListener<SplashCubit, String>(
        listener: (context, state) {
          if (state == 'home') {
            GoRouter.of(context).go(AppRouter.statementScreen);
          } else if (state == 'login') {
            GoRouter.of(context).go(AppRouter.login);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.splashGradient),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _iconSlideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(Assets.assetsImagesAppLogo),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
