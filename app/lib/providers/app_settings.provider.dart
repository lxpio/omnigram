// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:omnigram/services/app_settings.service.dart';

part 'app_settings.provider.g.dart';

@Riverpod(keepAlive: true)
AppSettingsService appSettingsService(AppSettingsServiceRef ref) => AppSettingsService();
