import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/common.dart';
import 'package:seahorse_calculator/constants.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kickController = useTextEditingController(text: '${Constants.kickPrice}');
    final onStageController = useTextEditingController(text: '${Constants.onStagePrice}');
    final winController = useTextEditingController(text: '${Constants.winPrice}');

    Widget buildInput(String key, TextEditingController controller) {
      return Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(key),
          ),
          const Spacer(),
          Expanded(
            flex: 6,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      );
    }

    return PopScope(
      onPopInvoked: (didPop) => ScaffoldMessenger.of(context).clearMaterialBanners(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Cài đặt'),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildInput('Giá đá', kickController),
                      const SizedBox(height: 16),
                      buildInput('Giá lên ngựa', onStageController),
                      const SizedBox(height: 16),
                      buildInput('Giá thắng', winController),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    final kick = int.tryParse(kickController.text);
                    final onStage = int.tryParse(onStageController.text);
                    final win = int.tryParse(winController.text);
                    if (kick == null || onStage == null || win == null) {
                      showErrorMessage(context, 'Nhập cho đúng mới lưu được.');
                      return;
                    }
                    final box = await Hive.openBox('settings');
                    await box.put('kickPrice', kick);
                    await box.put('onStagePrice', onStage);
                    await box.put('winPrice', win);
                    if (!context.mounted) return;
                    showMessage(context, 'Lưu thành công');
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
