import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/providers/image/remote_image_cache_manager.dart';
import 'package:omnigram/services/app_settings.service.dart';

import 'image_loader.dart';

/// The remote image provider for full size remote images
class ImmichRemoteImageProvider extends ImageProvider<ImmichRemoteImageProvider> {
  /// The [Book.CoverURL] of the books to fetch
  // final String identifier;
  final String coverId;

  /// The image cache manager
  final CacheManager? cacheManager;

  ImmichRemoteImageProvider({
    // required this.identifier,
    required this.coverId,
    this.cacheManager,
  });

  /// Converts an [ImageProvider]'s settings plus an [ImageConfiguration] to a key
  /// that describes the precise image to load.
  @override
  Future<ImmichRemoteImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ImmichRemoteImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final cache = cacheManager ?? RemoteImageCacheManager();
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiImageStreamCompleter(
      codec: _codec(key, cache, decode, chunkEvents),
      scale: 1.0,
      chunkEvents: chunkEvents.stream,
    );
  }

  /// Whether to load the preview thumbnail first or not
  bool get _loadPreview => IsarStore.get(
        AppSettingsEnum.loadPreview.storeKey,
        AppSettingsEnum.loadPreview.defaultValue,
      );

  // Streams in each stage of the image as we ask for it
  Stream<ui.Codec> _codec(
    ImmichRemoteImageProvider key,
    CacheManager cache,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async* {
    // Load the higher resolution version of the image
    final url = _loadPreview
        ? getImageUrlFromBookIdentifier(
            key.coverId,
            size: 'thumbnail',
          )
        : getImageUrlFromBookIdentifier(
            key.coverId,
            size: 'origin',
          );
    final codec = await ImageLoader.loadImageFromCache(
      url,
      cache: cache,
      decode: decode,
      chunkEvents: chunkEvents,
    );
    yield codec;

    await chunkEvents.close();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ImmichRemoteImageProvider) {
      return coverId == other.coverId;
    }

    return false;
  }

  @override
  int get hashCode => coverId.hashCode;
}

String getImageUrlFromBookIdentifier(
  final String coverId, {
  String size = 'preview',
}) {
  return '${IsarStore.get(StoreKey.serverEndpoint)}/img/covers/$coverId?size=$size';
}
