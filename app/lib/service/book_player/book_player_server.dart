import 'dart:io';
import 'dart:typed_data';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

class Server {
  static final Server _singleton = Server._internal();

  factory Server() {
    return _singleton;
  }

  Server._internal();

  HttpServer? _server;

  Future start() async {
    if (_server != null) {
      AnxLog.info(
        'Server: Existing instance detected on port ${_server?.port}, restarting',
      );
      await stop();
    }

    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_handleRequests);

    int port = Prefs().lastServerPort;

    try {
      _server = await io.serve(handler, '127.0.0.1', port);
    } catch (e, s) {
      AnxLog.warning(
          'Server: Failed to bind to port $port, trying random port $e', s);
      _server = await io.serve(handler, '127.0.0.1', 0);
    }

    Prefs().lastServerPort = _server!.port;
    AnxLog.info(
        'Server: Serving at http://${_server?.address.host}:${_server?.port}');
  }

  int get port {
    return _server!.port;
  }

  Future stop() async {
    if (_server == null) {
      return;
    }
    final stoppedPort = _server!.port;
    await _server?.close(force: true);
    _server = null;
    AnxLog.info('Server: Server stopped (port $stoppedPort)');
  }

  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  File? _tempFile;
  String? _tempFileName;

  String setTempFile(File file) {
    _tempFile = file;
    _tempFileName =
        '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    return _tempFileName!;
  }

  Future<shelf.Response> _handleRequests(shelf.Request request) async {
    final uriPath = request.requestedUri.path;
    AnxLog.info('Server: Request for $uriPath');

    if (_tempFileName != null && uriPath == "/${_tempFileName!}") {
      return shelf.Response.ok(
        _tempFile?.openRead(),
        headers: {
          'Content-Type': 'application/epub+zip',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    if (uriPath.startsWith('/book/')) {
      return _handleBookRequest(request);
    } else if (uriPath.startsWith('/js/')) {
      String content = await _loadAsset('assets/js/${path.basename(uriPath)}');
      return shelf.Response.ok(
        content,
        headers: {'Content-Type': 'application/javascript'},
      );
    } else if (uriPath.startsWith('/fonts/')) {
      Directory fontDir = getFontDir();
      final file = File(
          '${fontDir.path}/${path.basename(Uri.decodeComponent(uriPath))}');
      if (!file.existsSync()) {
        return shelf.Response.notFound('Font not found');
      }
      return shelf.Response.ok(
        file.openRead(),
        headers: {
          'Content-Type': 'font/opentype',
          'Access-Control-Allow-Origin': '*',
          'cache-control': 'public, max-age=31536000',
        },
      );
    } else if (uriPath.startsWith('/foliate-js/')) {
      if (uriPath.endsWith('.epub')) {
        final file =
            await rootBundle.load('assets/foliate-js/${uriPath.substring(12)}');
        return shelf.Response.ok(
          file.buffer.asUint8List(),
          headers: {
            'Content-Type': 'application/epub+zip',
            'Access-Control-Allow-Origin': '*', // Add this line
          },
        );
      }
      String content =
          await _loadAsset('assets/foliate-js/${uriPath.substring(12)}');

      // Determine content type based on file extension
      String contentType;
      if (uriPath.endsWith('.html')) {
        contentType = 'text/html';
      } else if (uriPath.endsWith('.css')) {
        contentType = 'text/css';
      } else if (uriPath.endsWith('.js')) {
        contentType = 'application/javascript';
      } else if (uriPath.endsWith('.json')) {
        contentType = 'application/json';
      } else {
        contentType = 'application/octet-stream';
      }

      return shelf.Response.ok(
        content,
        headers: {
          'Content-Type': contentType,
        },
      );
    } else if (uriPath.startsWith('/bgimg/')) {
      return await _handleBgimgRequest(request);
    } else {
      return shelf.Response.ok(
        'Request for "${request.url}"',
        headers: {
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  shelf.Response _handleBookRequest(shelf.Request request) {
    final bookPath = Uri.decodeComponent(request.url.path.substring(5));
    final file = File(bookPath);
    AnxLog.info('Server: Request for book: $bookPath');
    if (!file.existsSync()) {
      return shelf.Response.notFound('Book not found');
    }
    final headers = {
      'Content-Type': 'application/epub+zip',
      'Access-Control-Allow-Origin': '*',
    };
    return shelf.Response.ok(file.openRead(), headers: headers);
  }

  Future<shelf.Response> _handleBgimgRequest(shelf.Request request) async {
    final bgimgPath = Uri.decodeComponent(request.url.path.substring(6));
    ByteBuffer? file;
    if (bgimgPath.startsWith('assets/')) {
      file = (await rootBundle.load(bgimgPath.substring(7))).buffer;
    } else if (bgimgPath.startsWith('local/')) {
      final path =
          getBgimgDir().path + Platform.pathSeparator + bgimgPath.substring(6);
      file = (await File(path).readAsBytes()).buffer;
    } else {
      return shelf.Response.notFound('Bgimg not found');
    }
    final headers = {
      'Content-Type': 'image/png',
      'Access-Control-Allow-Origin': '*',
    };
    return shelf.Response.ok(file.asUint8List(), headers: headers);
  }
}
