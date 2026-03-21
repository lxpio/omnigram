import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/current_time_input.dart';

import 'base_tool.dart';

class CurrentTimeTool
    extends RepositoryTool<CurrentTimeInput, Map<String, dynamic>> {
  CurrentTimeTool()
      : super(
          name: 'current_time',
          description:
              'Retrieve the device\'s current time so you can reference timestamps in replies. Use when relative phrases need precise values. Returns ISO-8601 local and UTC strings, a millisecond timestamp, and optional timezone metadata.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'include_timezone': {
                'type': 'boolean',
                'description':
                    'Optional. Set false to omit timezone name/offset from the response (defaults to true).',
              },
            },
          },
          timeout: const Duration(seconds: 1),
        );

  @override
  CurrentTimeInput parseInput(Map<String, dynamic> json) {
    return CurrentTimeInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(CurrentTimeInput input) async {
    final now = DateTime.now();
    final utc = now.toUtc();
    final offset = now.timeZoneOffset;

    return {
      'localIso': now.toIso8601String(),
      'utcIso': utc.toIso8601String(),
      'timestampMs': now.millisecondsSinceEpoch,
      if (input.includeTimezone)
        'timezone': {
          'name': now.timeZoneName,
          'offsetMinutes': offset.inMinutes,
        },
    };
  }
}

final AiToolDefinition currentTimeToolDefinition = AiToolDefinition(
  id: 'current_time',
  displayNameBuilder: (L10n l10n) => l10n.aiToolCurrentTimeName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolCurrentTimeDescription,
  build: (context) => CurrentTimeTool().tool,
);
