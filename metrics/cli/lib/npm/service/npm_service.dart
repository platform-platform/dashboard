// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/interfaces/service/info_service.dart';

/// An abstract class for Npm service that provides methods for working with Npm.
abstract class NpmService extends InfoService {
  /// Installs npm dependencies into the given [path].
  Future<void> installDependencies(String path);
}
