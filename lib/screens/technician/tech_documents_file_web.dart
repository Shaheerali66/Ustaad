// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pickFile({
  required String accept,
  bool capture = false,
  required Function(String base64, String name, int size) onPicked,
  required Function(String message) onError,
}) {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = accept;
  if (capture) {
    uploadInput.setAttribute('capture', 'user');
  }
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final size = file.size;

      // 5MB Size Validation
      if (size > 5 * 1024 * 1024) {
        onError('File size must be less than 5MB (Selected file is ${(size / (1024 * 1024)).toStringAsFixed(2)}MB)');
        return;
      }

      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        if (result is String) {
          onPicked(result, file.name, size);
        }
      });
    }
  });
}

void downloadFile(String base64, String name) {
  final anchor = html.AnchorElement(href: base64)
    ..setAttribute('download', name)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
