import 'package:omnigram/service/vibration_service.dart';
import 'package:flutter/material.dart';

class VibrationTestPage extends StatefulWidget {
  const VibrationTestPage({super.key});

  @override
  State<VibrationTestPage> createState() => _VibrationTestPageState();
}

class _VibrationTestPageState extends State<VibrationTestPage> {
  VibrationCapabilities? _capabilities;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    final caps = await VibrationService.getCapabilities();
    if (!mounted) return;
    setState(() {
      _capabilities = caps;
      _loading = false;
    });
  }

  Future<void> _trigger(VibrationType type) async {
    await VibrationService.vibrate(type);
  }

  @override
  Widget build(BuildContext context) {
    final caps = _capabilities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibration Test'),
        actions: [
          IconButton(
            onPressed: _loadCapabilities,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh capabilities',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loading || caps == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capabilities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCapabilityRow('Has Vibrator', caps.hasVibrator),
                        _buildCapabilityRow(
                            'Has Amplitude Control', caps.hasAmplitudeControl),
                        _buildCapabilityRow('Supports Custom Patterns',
                            caps.hasCustomVibrationsSupport),
                        _buildCapabilityRow(
                            'Can Use Haptics', caps.canUseHaptics),
                        _buildCapabilityRow(
                            'Has Any Feedback', caps.hasAnyVibration),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vibration Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VibrationType.values.map(
              (type) {
                return OutlinedButton(
                  onPressed: (caps?.hasAnyVibration ?? false)
                      ? () => _trigger(type)
                      : null,
                  child: Text(_labelForType(type)),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityRow(String label, bool supported) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            supported ? Icons.check_circle : Icons.cancel,
            color: supported
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _labelForType(VibrationType type) {
    final buffer = StringBuffer();
    final name = type.name;

    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i == 0) {
        buffer.write(char.toUpperCase());
        continue;
      }
      if (isUpper) {
        buffer.write(' ');
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}
