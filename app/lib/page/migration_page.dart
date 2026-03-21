import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/utils/get_path/macos_migration.dart';
import 'package:flutter/material.dart';

class MigrationPage extends StatefulWidget {
  final VoidCallback onMigrationComplete;

  const MigrationPage({super.key, required this.onMigrationComplete});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  String _currentItem = '';
  int _progress = 0;
  int _total = 5;
  bool _isComplete = false;
  bool _hasFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startMigration();
  }

  Future<void> _startMigration() async {
    try {
      final checkResult = await checkMigrationNeeded();

      if (!checkResult.needsMigration) {
        // No migration needed, proceed immediately
        widget.onMigrationComplete();
        return;
      }

      final success = await performMigration(
        oldPath: checkResult.oldPath!,
        newPath: checkResult.newPath!,
        onProgress: (currentItem, progress, total) {
          if (mounted) {
            setState(() {
              _currentItem = currentItem;
              _progress = progress;
              _total = total;
            });
          }
        },
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isComplete = true;
          });
          // Small delay to show completion status
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onMigrationComplete();
        } else {
          setState(() {
            _hasFailed = true;
            _errorMessage = 'Migration failed. Using original data location.';
          });
          // Continue with old path on failure
          await Future.delayed(const Duration(seconds: 2));
          widget.onMigrationComplete();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasFailed = true;
          _errorMessage = e.toString();
        });
        await Future.delayed(const Duration(seconds: 2));
        widget.onMigrationComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isComplete
                    ? Icons.check_circle_outline
                    : _hasFailed
                        ? Icons.error_outline
                        : Icons.folder_copy_outlined,
                size: 64,
                color: _isComplete
                    ? Colors.green
                    : _hasFailed
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _isComplete
                    ? l10n.migrationComplete
                    : _hasFailed
                        ? l10n.migrationFailed
                        : l10n.migrationInProgress,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!_isComplete && !_hasFailed) ...[
                Text(
                  l10n.migrationDoNotClose,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LinearProgressIndicator(
                  value: _total > 0 ? _progress / _total : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentItem.isNotEmpty
                      ? '${l10n.migrationCurrentItem}: $_currentItem'
                      : l10n.migrationPreparing,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_progress / $_total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              if (_hasFailed && _errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
