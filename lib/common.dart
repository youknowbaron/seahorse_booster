import 'package:flutter/material.dart';

showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
  return;
}

showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Text(
        message,
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
  return;
}
