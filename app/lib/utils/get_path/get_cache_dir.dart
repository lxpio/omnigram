import 'dart:io';
import 'package:omnigram/utils/platform_utils.dart';

import 'package:path_provider/path_provider.dart';

Future<Directory> getAnxCacheDir() async {
  switch (AnxPlatform.type) {
    case AnxPlatformEnum.android:
    case AnxPlatformEnum.ohos:
    case AnxPlatformEnum.windows:
    case AnxPlatformEnum.macos:
    case AnxPlatformEnum.ios:
      return await getApplicationCacheDirectory();
  }
}
