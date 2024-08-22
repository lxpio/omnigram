
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/utils/url_helper.dart';
import 'package:openapi/api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

part 'api.provider.g.dart';


@Riverpod(keepAlive: true)
class ApiService extends _$ApiService {

  // late ApiClient _apiClient;

  final log = Logger("ApiService");

  @override
  DefaultApi build() {

    final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);

     if (endpoint != null && endpoint.isNotEmpty) {
      final apiClient = ApiClient(basePath: endpoint, authentication: APIAuthentication());
      setDeviceHeaders(apiClient);
      return DefaultApi(apiClient);
    }

    return DefaultApi(ApiClient(basePath: "https://api.omnigram.app", authentication: APIAuthentication()));
    
  }


  setEndpoint(String endpoint)  {
    final apiClient = ApiClient(basePath: endpoint, authentication: APIAuthentication());
    setDeviceHeaders(apiClient);
    state = DefaultApi(apiClient);
  }



Future<String> resolveAndSetEndpoint(String serverUrl) async {
    final endpoint = await _resolveEndpoint(serverUrl);
    await setEndpoint(endpoint);

    // Save in hivebox for next startup
    IsarStore.put(StoreKey.serverEndpoint, endpoint);
    return endpoint;
  }

  setDeviceHeaders(ApiClient apiClient)  {
    // Make sign-in request
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();


    try {
      if (Platform.isIOS) {
      
        deviceInfoPlugin.iosInfo.then((iosInfo) {
             apiClient.addDefaultHeader('deviceModel', iosInfo.utsname.machine);
            apiClient.addDefaultHeader('deviceType', 'iOS');
        });
     
      } else {

        deviceInfoPlugin.androidInfo.then((androidInfo){
        apiClient.addDefaultHeader('deviceModel', androidInfo.model);
        apiClient.addDefaultHeader('deviceType', 'Android');
        });
    
      }
    } catch (e) {
      log.warning("Failed to set device headers: $e");
    }

  }
  

   /// Takes a server URL and attempts to resolve the API endpoint.
  ///
  /// Input: [schema://]host[:port][/path]
  ///  schema - optional (default: https)
  ///  host   - required
  ///  port   - optional (default: based on schema)
  ///  path   - optional
  Future<String> _resolveEndpoint(String serverUrl) async {
    final url = sanitizeUrl(serverUrl);

    if (!await _isEndpointAvailable(serverUrl)) {
      throw ApiException(503, "Server is not reachable");
    }

    // Check for /.well-known/immich
    final wellKnownEndpoint = await _getWellKnownEndpoint(url);
    if (wellKnownEndpoint.isNotEmpty) return wellKnownEndpoint;

    // Otherwise, assume the URL provided is the api endpoint
    return url;
  }


Future<String> _getWellKnownEndpoint(String baseUrl) async {
    final Client client = Client();

    try {
      var headers = {"Accept": "application/json"};
      headers.addAll(getRequestHeaders());

      final res = await client.get(
        Uri.parse("$baseUrl/.well-known/immich"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final endpoint = data['api']['endpoint'].toString();

        if (endpoint.startsWith('/')) {
          // Full URL is relative to base
          return "$baseUrl$endpoint";
        }
        return endpoint;
      }
    } catch (e) {
      debugPrint("Could not locate /.well-known/immich at $baseUrl");
    }

    return "";
  }

  Future<bool> _isEndpointAvailable(String serverUrl) async {
    
    final Client client = Client();

    if (!serverUrl.endsWith('/api')) {
      serverUrl += '/api';
    }

    try {
      final response = await client
          .get(
            Uri.parse("$serverUrl/server-info/ping"),
            headers: getRequestHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      log.info("Pinging server with response code ${response.statusCode}");
      if (response.statusCode != 200) {
        log.severe(
          "Server Gateway Error: ${response.body} - Cannot communicate to the server",
        );
        return false;
      }
    } on TimeoutException catch (_) {
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (error, stackTrace) {
      log.severe(
        "Error while checking server availability",
        error,
        stackTrace,
      );
      return false;
    }
    return true;
  }
 
}

class APIAuthentication extends Authentication {
   @override
  Future<void> applyToParams(
    List<QueryParam> queryParams,
    Map<String, String> headerParams,
  ) {
    return Future<void>(() {
      var headers = getRequestHeaders();
      headerParams.addAll(headers);
    });
  }


}



Map<String, String> getRequestHeaders() {
    var accessToken = IsarStore.get(StoreKey.accessToken, "");
    var customHeadersStr = IsarStore.get(StoreKey.customHeaders, "");
    var header = <String, String>{};
    if (accessToken.isNotEmpty) {
      header['x-omnigram-token'] = accessToken;
    }

    if (customHeadersStr.isEmpty) {
      return header;
    }

    var customHeaders = jsonDecode(customHeadersStr) as Map;
    customHeaders.forEach((key, value) {
      header[key] = value;
    });

    return header;
  }