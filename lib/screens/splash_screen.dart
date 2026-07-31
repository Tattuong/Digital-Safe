import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/auth_service.dart';
import '../providers/shop_provider.dart';
import '../providers/vault_provider.dart';
import 'auth/setup_pin_screen.dart';
import 'auth/unlock_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      context.read<ShopProvider>().init(),
      context.read<VaultProvider>().init(),
    ]);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final hasPin = await AuthService.instance.hasPin();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => hasPin ? const UnlockScreen() : const SetupPinScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final glow = 0.3 + _pulse.value * 0.4;
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: glow),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                AppStrings.t(context, 'appName'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppStrings.t(context, 'appTagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 48),
              Icon(Icons.lock_outline_rounded, size: 36, color: AppColors.neonBlue.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
