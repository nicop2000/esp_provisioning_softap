import 'package:logger/logger.dart';

/// The global logger for this library.
///
/// Can be overridden by consumers of this library for custom logging behavior.
Logger logger = Logger(
  printer: PrettyPrinter(
    printTime: true,
    printEmojis: false,
  ),
);
