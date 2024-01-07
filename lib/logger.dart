// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static LogLevel logLevel = LogLevel.info;

  static void debug(String message) {
    if (logLevel.index <= LogLevel.debug.index) {
      _log('[DEBUG] $message');
    }
  }

  static void info(String message) {
    if (logLevel.index <= LogLevel.info.index) {
      _log('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (logLevel.index <= LogLevel.warning.index) {
      _log('[WARNING] $message');
    }
  }

  static void error(String message) {
    if (logLevel.index <= LogLevel.error.index) {
      _log('[ERROR] $message');
    }
  }

  static void _log(String message) {
    print(message);
    // 这里可以将日志写入文件或其他目标
  }
}
