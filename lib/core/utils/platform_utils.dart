import 'package:themeparkapp/core/utils/platform_utils_stub.dart'
    if (dart.library.io) 'package:themeparkapp/core/utils/platform_utils_io.dart';

bool get isTestEnvironment => isTestEnvironmentImpl;
