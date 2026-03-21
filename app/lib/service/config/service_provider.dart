import 'package:omnigram/service/config/config_item.dart';
import 'package:flutter/material.dart';

/// Base class for all service providers (Translate, TTS, etc.).
///
/// [T] is the service enum type (e.g., TranslateService, TtsService).
///
/// Subclasses must implement:
/// - [service]: The service enum value this provider corresponds to.
/// - [getLabel]: The display label for this service.
/// - [getConfigItems]: Configuration items for this service.
/// - [getConfig]: Returns the current configuration.
/// - [saveConfig]: Saves the configuration.
abstract class ServiceProvider<T> {
  /// The service enum value this provider corresponds to.
  T get service;

  /// The display label for this service.
  String getLabel(BuildContext context);

  /// Get the configuration items for this service.
  /// Returns an empty list if the service has no configuration.
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [];
  }

  /// Returns the current configuration.
  /// Returns an empty map if no configuration is saved.
  Map<String, dynamic> getConfig() => {};

  /// Saves the configuration.
  void saveConfig(Map<String, dynamic> config) {}
}
