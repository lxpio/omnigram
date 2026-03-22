import 'dart:ui';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Validates and adjusts window position to ensure it's visible on screen.
///
/// This utility helps prevent windows from being positioned off-screen,
/// which can happen when:
/// - A secondary monitor is disconnected after the app was positioned there
/// - Display configuration changes between sessions
/// - The saved window position is otherwise invalid
class WindowPositionValidator {
  /// Validates if the given window position is visible on any available display.
  ///
  /// A position is considered valid if the window's center point falls within
  /// any of the available screen's visible areas.
  static Future<bool> isPositionValid(
    Offset position,
    Size windowSize,
  ) async {
    try {
      final displays = await screenRetriever.getAllDisplays();

      final windowRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        windowSize.width,
        windowSize.height,
      );

      final windowCenter = windowRect.center;

      for (final display in displays) {
        final screenRect = Rect.fromLTWH(
          display.visiblePosition?.dx ?? 0,
          display.visiblePosition?.dy ?? 0,
          display.visibleSize?.width ?? display.size.width,
          display.visibleSize?.height ?? display.size.height,
        );

        // Check if window center is within this screen's visible area
        if (screenRect.contains(windowCenter)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      AnxLog.warning('Failed to validate window position: $e');
      return false;
    }
  }

  /// Calculates a safe centered position on the primary display.
  static Future<Offset> getCenteredPosition(Size windowSize) async {
    try {
      final primaryDisplay = await screenRetriever.getPrimaryDisplay();

      final visibleWidth =
          primaryDisplay.visibleSize?.width ?? primaryDisplay.size.width;
      final visibleHeight =
          primaryDisplay.visibleSize?.height ?? primaryDisplay.size.height;
      final visibleStartX = primaryDisplay.visiblePosition?.dx ?? 0;
      final visibleStartY = primaryDisplay.visiblePosition?.dy ?? 0;

      return Offset(
        visibleStartX + (visibleWidth / 2) - (windowSize.width / 2),
        visibleStartY + (visibleHeight / 2) - (windowSize.height / 2),
      );
    } catch (e) {
      AnxLog.warning('Failed to calculate centered position: $e');
      // Fallback to origin if screen retrieval fails
      return const Offset(100, 100);
    }
  }

  /// Validates the saved window position and adjusts if necessary.
  ///
  /// Returns a validated position that is guaranteed to be visible.
  /// If the saved position is off-screen, returns a centered position instead.
  static Future<Offset> validateAndAdjust(
    Offset savedPosition,
    Size windowSize,
  ) async {
    final isValid = await isPositionValid(savedPosition, windowSize);

    if (isValid) {
      AnxLog.info(
        'Window position valid: (${savedPosition.dx}, ${savedPosition.dy})',
      );
      return savedPosition;
    }

    final centeredPosition = await getCenteredPosition(windowSize);
    AnxLog.info(
      'Window position invalid (${savedPosition.dx}, ${savedPosition.dy}), '
      'adjusted to centered position (${centeredPosition.dx}, ${centeredPosition.dy})',
    );
    return centeredPosition;
  }
}

/// Initializes the desktop window with validated position and size.
///
/// This function:
/// 1. Retrieves saved window information from preferences
/// 2. Validates the saved position is visible on current displays
/// 3. Adjusts position if necessary (e.g., after display disconnection)
/// 4. Applies the window configuration
///
/// Should be called during app initialization on desktop platforms
/// (Windows and macOS).
Future<void> initializeDesktopWindow() async {
  await windowManager.ensureInitialized();

  final savedSize = Size(
    Prefs().windowInfo.width,
    Prefs().windowInfo.height,
  );
  final savedOffset = Offset(
    Prefs().windowInfo.x,
    Prefs().windowInfo.y,
  );
  final isMaximized = Prefs().windowInfo.isMaximized;

  WindowManager.instance.setTitle('Omnigram');

  if (isMaximized) {
    await WindowManager.instance.maximize();
  } else if (savedSize.width > 0 && savedSize.height > 0) {
    // Validate and adjust position if needed
    final validatedOffset = await WindowPositionValidator.validateAndAdjust(
      savedOffset,
      savedSize,
    );

    await WindowManager.instance.setSize(savedSize);
    await WindowManager.instance.setPosition(validatedOffset);
  }

  await WindowManager.instance.setPreventClose(true);
  await WindowManager.instance.focus();
}
