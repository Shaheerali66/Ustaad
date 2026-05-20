/// Stub implementation for non-web platforms.
/// These functions should never be called on mobile (guarded by kIsWeb checks),
/// but the stubs are needed so the code compiles on all platforms.

void pickFile({
  required String accept,
  bool capture = false,
  required Function(String base64, String name, int size) onPicked,
  required Function(String message) onError,
}) {
  // No-op on mobile — guarded by kIsWeb in caller
}

void downloadFile(String base64, String name) {
  // No-op on mobile — guarded by kIsWeb in caller
}
