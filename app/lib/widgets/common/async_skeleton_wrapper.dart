import 'package:omnigram/utils/log/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A wrapper widget that automatically handles AsyncValue states with Skeletonizer.
///
/// This widget simplifies the handling of Riverpod AsyncValue by automatically:
/// - Showing a skeleton screen during loading state
/// - Rendering the actual content when data is available
/// - Displaying an error message when an error occurs
///
/// Usage:
/// ```dart
/// AsyncSkeletonWrapper(
///   asyncValue: ref.watch(myProvider),
///   builder: (data, isDataReady) => MyWidget(data: data, showLoadingState: !isDataReady),
/// )
/// ```
class AsyncSkeletonWrapper<T> extends StatelessWidget {
  /// The AsyncValue to handle
  final AsyncValue<T> asyncValue;

  /// Builder function that creates the widget from the data.
  /// [isDataReady] indicates whether the provided data is real or mock.
  final Widget Function(T data, bool isDataReady) builder;

  /// Optional custom skeleton widget. If not provided, the builder will be
  /// called with mock data to generate the skeleton automatically.
  final Widget? skeleton;

  /// Optional mock data provider for generating skeleton.
  /// If not provided and no skeleton is given, a default mock will be attempted.
  final T? mock;

  /// Optional custom error widget builder
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// Whether to enable the skeleton effect
  final bool enabled;

  const AsyncSkeletonWrapper({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.skeleton,
    this.mock,
    this.errorBuilder,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) => builder(data, true),
      loading: () {
        if (!enabled) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use custom skeleton if provided
        if (skeleton != null) {
          return Skeletonizer(
            enabled: true,
            child: skeleton!,
          );
        }

        // Try to generate skeleton with mock data
        try {
          final mockData = mock ?? _createDefaultMock<T>();
          return Skeletonizer(
            enabled: true,
            child: builder(mockData, false),
          );
        } catch (e) {
          // Fallback to circular progress if mock generation fails
          return const Center(child: CircularProgressIndicator());
        }
      },
      error: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder!(error, stackTrace);
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Attempts to create a default mock value for common types
  static T _createDefaultMock<T>() {
    // Handle common types
    if (T == int) return 1 as T;
    if (T == double) return 1.0 as T;
    if (T == String) return 'a ' * 5 as T;
    if (T == bool) return false as T;
    AnxLog.severe('No default mock available for type $T');

    throw Exception('No default mock available for type $T');
  }
}

/// Combines multiple AsyncValues into a single AsyncValue<List>.
///
/// This helper function simplifies handling multiple providers:
/// - If ANY provider is loading, returns AsyncValue.loading()
/// - If ANY provider has an error, returns that AsyncValue.error()
/// - If ALL providers have data, returns AsyncValue.data([...])
///
/// Usage:
/// ```dart
/// return AsyncSkeletonWrapper<List>(
///   asyncValue: combineAsyncValues([
///     ref.watch(provider1),
///     ref.watch(provider2),
///     ref.watch(provider3),
///   ]),
///   mockBuilder: () => [mock1, mock2, mock3],
///   builder: (data) {
///     final [value1, value2, value3] = data;
///     return MyWidget(value1, value2, value3);
///   },
/// );
/// ```
AsyncValue<List<dynamic>> combineAsyncValues(List<AsyncValue> values) {
  // Check if any is loading
  if (values.any((v) => v.isLoading && !v.hasValue)) {
    return const AsyncValue.loading();
  }

  // Check for errors and return the first one found
  for (final value in values) {
    if (value.hasError) {
      return AsyncValue.error(value.error!, value.stackTrace!);
    }
  }

  // All have data, extract values
  final data = values.map((v) => v.requireValue).toList();
  return AsyncValue.data(data);
}
