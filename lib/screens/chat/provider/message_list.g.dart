// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageListHash() => r'6577cbe6ba827fa98057d0d9d905a6fc5d280e33';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MessageList
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final int id;

  Future<List<Message>> build(
    int id,
  );
}

/// See also [MessageList].
@ProviderFor(MessageList)
const messageListProvider = MessageListFamily();

/// See also [MessageList].
class MessageListFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [MessageList].
  const MessageListFamily();

  /// See also [MessageList].
  MessageListProvider call(
    int id,
  ) {
    return MessageListProvider(
      id,
    );
  }

  @override
  MessageListProvider getProviderOverride(
    covariant MessageListProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageListProvider';
}

/// See also [MessageList].
class MessageListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MessageList, List<Message>> {
  /// See also [MessageList].
  MessageListProvider(
    int id,
  ) : this._internal(
          () => MessageList()..id = id,
          from: messageListProvider,
          name: r'messageListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageListHash,
          dependencies: MessageListFamily._dependencies,
          allTransitiveDependencies:
              MessageListFamily._allTransitiveDependencies,
          id: id,
        );

  MessageListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Future<List<Message>> runNotifierBuild(
    covariant MessageList notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(MessageList Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageListProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MessageList, List<Message>>
      createElement() {
    return _MessageListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageListProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessageListRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `id` of this provider.
  int get id;
}

class _MessageListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MessageList, List<Message>>
    with MessageListRef {
  _MessageListProviderElement(super.provider);

  @override
  int get id => (origin as MessageListProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
