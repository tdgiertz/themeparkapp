import 'dart:io';

void main() {
  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    print('No lcov.info found');
    return;
  }
  
  final lines = lcovFile.readAsLinesSync();
  var currentFile = '';
  var totalFound = 0;
  var totalHit = 0;
  
  final fileCoverage = <String, double>{};
  final fileMissed = <String, int>{};
  
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      totalFound = 0;
      totalHit = 0;
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final hit = int.parse(parts[1]);
        totalFound++;
        if (hit > 0) totalHit++;
      }
    } else if (line == 'end_of_record') {
      if (totalFound > 0) {
        fileCoverage[currentFile] = totalHit / totalFound;
        fileMissed[currentFile] = totalFound - totalHit;
      } else {
        fileCoverage[currentFile] = 1.0;
        fileMissed[currentFile] = 0;
      }
    }
  }
  
  final entries = fileCoverage.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
    
  print('Coverage by File (Lowest First):');
  for (final entry in entries) {
    final pct = (entry.value * 100).toStringAsFixed(1);
    final missed = fileMissed[entry.key];
    print('${pct.padLeft(5)}% | Missed: ${missed.toString().padRight(3)} | ${entry.key}');
  }
}
