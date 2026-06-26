import 'dart:io';

void main() {
  var lines = File('lib/core/constants/app_strings.dart').readAsLinesSync();
  var trKeys = <String>{};
  var enKeys = <String>{};
  
  bool inEn = false;
  
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (line.contains('_en = {')) inEn = true;
    
    var match = RegExp(r"^\s*'([^']+)'\s*:").firstMatch(line);
    if (match != null) {
      var key = match.group(1)!;
      if (!inEn) {
        if (trKeys.contains(key)) print('Duplicate in TR (Line ${i+1}): $key');
        trKeys.add(key);
      } else {
        if (enKeys.contains(key)) print('Duplicate in EN (Line ${i+1}): $key');
        enKeys.add(key);
      }
    }
  }
}
