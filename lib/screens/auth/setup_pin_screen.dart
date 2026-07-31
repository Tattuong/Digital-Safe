import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/app_toast.dart';
import '../main_shell.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _nameCtrl = TextEditingController(text: 'David');
  String _pin = '';
  String _confirmPin = '';
  int _step = 0;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AuthService.instance.setupPin(
      _pin,
      userName: _nameCtrl.text.trim().isEmpty ? 'User' : _nameCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  void _onDigit(String d) {
    setState(() {
      _error = null;
      if (_step == 0) {
        if (_pin.length < 4) _pin += d;
        if (_pin.length == 4) _step = 1;
      } else if (_step == 1) {
        if (_confirmPin.length < 4) _confirmPin += d;
        if (_confirmPin.length == 4) {
          if (_confirmPin != _pin) {
            _error = AppStrings.t(context, 'pinMismatch');
            _confirmPin = '';
            _step = 0;
            _pin = '';
          } else {
            _step = 2;
          }
        }
      }
    });
  }

  void _backspace() {
    setState(() {
      _error = null;
      if (_step == 0 && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_step == 1 && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 2) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(AppStrings.t(context, 'setupVault'), style: AppTypography.titleLarge(color: Colors.white)),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: AppStrings.t(context, 'yourName')),
                ),
                const Spacer(),
                FilledButton(onPressed: _finish, child: Text(AppStrings.t(context, 'save'))),
              ],
            ),
          ),
        ),
      );
    }

    final current = _step == 0 ? _pin : _confirmPin;
    final title = _step == 0 ? AppStrings.t(context, 'createPin') : AppStrings.t(context, 'confirmPin');

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.shieldGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.titleLarge(color: Colors.white)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < current.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.neonBlue : Colors.white24,
                    border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.5)),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const Spacer(),
            _PinPad(onDigit: _onDigit, onBackspace: _backspace),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  String _pin = '';
  String? _error;

  Future<void> _verifyPin() async {
    final ok = await AuthService.instance.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      setState(() {
        _error = AppStrings.t(context, 'wrongPin');
        _pin = '';
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _error = null;
      _pin += d;
    });
    if (_pin.length == 4) _verifyPin();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _onForgotPin() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'forgotPinTitle')),
        content: Text(AppStrings.t(context, 'forgotPinMessage')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(context, 'resetVault')),
          ),
        ],
      ),
    );
    if (reset != true || !mounted) return;

    await context.read<VaultProvider>().resetVault();
    if (!mounted) return;

    AppToast.show(context, title: AppStrings.t(context, 'vaultResetDone'));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SetupPinScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.shieldGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.t(context, 'enterPin'), style: AppTypography.titleLarge(color: Colors.white)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.neonBlue : Colors.white24,
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            TextButton(onPressed: _onForgotPin, child: Text(AppStrings.t(context, 'forgotPin'))),
            const Spacer(),
            _PinPad(onDigit: _onDigit, onBackspace: _backspace),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _PinPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: keys.length,
        itemBuilder: (_, i) {
          final key = keys[i];
          if (key.isEmpty) return const SizedBox.shrink();
          return Material(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                if (key == '⌫') {
                  onBackspace();
                } else {
                  onDigit(key);
                }
              },
              child: Center(
                child: Text(
                  key,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
