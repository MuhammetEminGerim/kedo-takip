import 'dart:io';

void main() {
  var dir = Directory(r'C:\Users\emin\AppData\Local\Pub\Cache\hosted\pub.dev');
  var files = dir.listSync(recursive: true).where((f) => f.path.endsWith('fluentui_system_icons.dart')).toList();
  if (files.isNotEmpty) {
    var content = File(files.first.path).readAsStringSync();
    var lines = content.split('\n');
    for (var line in lines) {
      if (line.contains('food') || line.contains('drop') || line.contains('bowl') || line.contains('sweep') || line.contains('scale') || line.contains('weight') || line.contains('animal') || line.contains('box')) {
        print(line.trim());
      }
    }
  }
}
