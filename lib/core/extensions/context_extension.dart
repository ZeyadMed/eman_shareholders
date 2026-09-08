part of "extensions.dart";

extension ContextExtensions on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get shortestSide => MediaQuery.of(this).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  bool get isSmallMobile => screenWidth < 360;

  bool get isNormalMobile => !isTablet && !isSmallMobile;

  T responsiveValue<T>({
    required T smallMobile,
    required T mobile,
    required T tablet,
  }) {
    if (isTablet) return tablet;
    if (isSmallMobile) return smallMobile;
    return mobile;
  }

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom != 0;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';
  bool get isRussion => Localizations.localeOf(this).languageCode == 'ru';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  TextDirection get reversedTextDirection =>
      !isArabic ? TextDirection.rtl : TextDirection.ltr;

  FocusScopeNode get foucsScopeNode => FocusScope.of(this);

  // void showErrorMessage(String message) {
  //   scaffoldMessengerKey.currentState?.clearSnackBars();
  //   scaffoldMessengerKey.currentState?.showSnackBar(
  //     SnackBar(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       content: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: Text(
  //               message,
  //               style: AppTextTheme.bodyMedium.copyWith(color: Colors.black),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           const SizedBox(width: 10),
  //           const Icon(
  //             Icons.error,
  //             color: Colors.red,
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.white,
  //       behavior: SnackBarBehavior.floating,
  //       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //       margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
  //     ),
  //   );
  // }

  // void showSuccessMessage(
  //   String message, {
  //   Color color = Colors.green,
  //   IconData icon = Icons.check_circle,
  // }) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     scaffoldMessengerKey.currentState?.showSnackBar(
  //       SnackBar(
  //         duration: const Duration(seconds: 2),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         content: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Expanded(
  //               child: LocalizedLabel(
  //                 text: message,
  //                 style: AppTextTheme.bodyMedium.copyWith(color: Colors.black),
  //                 textAlign: TextAlign.center,
  //                 maxLines: 4,
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             Icon(icon, color: color),
  //           ],
  //         ),
  //         backgroundColor: Colors.white,
  //         behavior: SnackBarBehavior.floating,
  //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //         margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
  //       ),
  //     );
  //   });
  // }

  void showTapAgainToExit({
    String message = 'اضغط مرة اخرى للخروج',
    Color color = Colors.grey,
    IconData icon = Icons.logout,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: AppTextTheme.bodyMedium.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: color),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
        ),
      );
    });
  }

  void showSuccessDialog(String text) {
    showDialog(
      context: this,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        content: Text(
          text,
          style: AppTextTheme.bodyMedium.copyWith(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.all(20).copyWith(bottom: 40),
      ),
    );
  }

  void showLoadingDialog({
    String? message,
    bool canPop = false,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => PopScope(
        canPop: canPop,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              Gaps.v18(),
              Text(
                message ?? '...تحميل البيانات',
                style: theme.textTheme.titleLarge!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20).copyWith(bottom: 40),
        ),
      ),
    );
  }

  void showTopSnackBar({
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(this);

    // Early return if no overlay is available
    if (overlay == null) {
      debugPrint('⚠️ Cannot show snackbar: No Overlay widget found in context');
      return;
    }

    // Define color + icon for each type
    late final Color backgroundColor;
    late final IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = HexColor.secondaryColor;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    // Animation controller
    final animationController = AnimationController(
      vsync: Navigator.of(this),
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    final curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack);

    final overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          final slideOffset =
              Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)
                  .animate(curvedAnimation);
          final opacity =
              Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

          return Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 10,
            child: SlideTransition(
              position: slideOffset,
              child: FadeTransition(
                opacity: opacity,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Animate in
    animationController.forward();

    // Auto remove
    Future.delayed(duration, () async {
      await animationController.reverse();
      overlayEntry.remove();
      animationController.dispose();
    });
  }
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
