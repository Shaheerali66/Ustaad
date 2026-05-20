import 'dart:io';

void main() {
  final directory = Directory('.');
  
  void processDirectory(Directory dir) {
    if (!dir.existsSync()) return;
    for (var entity in dir.listSync()) {
      if (entity.path.contains('.git') || entity.path.contains('build') || entity.path.contains('.dart_tool')) {
        continue;
      }
      
      if (entity is Directory) {
        processDirectory(entity);
      } else if (entity is File) {
        // Skip images and binaries
        if (entity.path.endsWith('.png') || entity.path.endsWith('.jpg') || entity.path.endsWith('.jpeg') || entity.path.endsWith('.ttf') || entity.path.endsWith('.otf') || entity.path.endsWith('.exe') || entity.path.endsWith('.dll') || entity.path.endsWith('.so') || entity.path.endsWith('.dylib') || entity.path.endsWith('.pb')) {
          continue;
        }
        
        try {
          String content = entity.readAsStringSync();
          String newContent = content
              .replaceAll('USTAAD', 'USTAAD')
              .replaceAll('USTAAD', 'USTAAD')
              .replaceAll('USTAAD', 'USTAAD')
              .replaceAll('USTAAD', 'USTAAD')
              .replaceAll('USTAAD', 'USTAAD')
              .replaceAll('ustaad', 'ustaad')
              .replaceAll('ustaadAi', 'ustaadAi')
              .replaceAll('ustaadai', 'ustaadai')
              .replaceAll('ustaad', 'ustaad');
              
          if (content != newContent) {
            entity.writeAsStringSync(newContent);
            print('Updated ${entity.path}');
          }
        } catch (e) {
          // Skip files that cannot be read as UTF-8
        }
      }
    }
  }
  
  processDirectory(directory);
  print('Rebranding complete.');
}
