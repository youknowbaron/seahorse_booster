import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

class DialogContainer extends StatelessWidget {
  const DialogContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.widthPct = 0.9,
    this.dismissOnBarrier = true,
    this.dismissKeyboardOnTap = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double widthPct;
  final bool dismissOnBarrier;
  final bool dismissKeyboardOnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissOnBarrier ? Navigator.of(context).pop : null,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: () {
              if (dismissKeyboardOnTap) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * widthPct,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Theme.of(context).colorScheme.background,
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class HitDialog extends HookWidget {
  const HitDialog({super.key, this.a = '', this.b = ''});

  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: const Duration(milliseconds: 1000))
      ..forward()
      ..repeat();

    useEffect(
      () {
        () async {
          await Future.delayed(const Duration(milliseconds: 2000));
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }();
        return null;
      },
      const [],
    );

    return DialogContainer(
      dismissOnBarrier: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$a đá đầu heo $b',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            child: Lottie.asset(
              'assets/lottie/kick.json',
              controller: controller,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
