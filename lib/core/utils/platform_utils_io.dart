import 'dart:io';

bool get isTestEnvironmentImpl => Platform.environment.containsKey('FLUTTER_TEST');
