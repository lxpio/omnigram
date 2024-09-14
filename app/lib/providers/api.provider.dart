
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/utils/url_helper.dart';
import 'package:openapi/openapi.dart';

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

    log.info("ApiService build");

    return _createApi();
    
  }

  setEndpoint(String endpoint)  {

    final apiClient = _createApi();
    state = apiClient;
  }


  Future<String> resolveAndSetEndpoint(String serverUrl) async {


    final endpoint = await _resolveEndpoint(serverUrl);
    await setEndpoint(endpoint);

    // Save in hivebox for next startup
    IsarStore.put(StoreKey.serverEndpoint, endpoint);
    return endpoint;
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

    await _isEndpointAvailable(serverUrl);


    // Otherwise, assume the URL provided is the api endpoint
    return url;
  }




  Future<bool> _isEndpointAvailable(String serverUrl) async {
    
    final dio = _createDio(serverUrl);

    try {
      final response = await dio.get("/sys/ping");

      log.info("Pinging server with response code ${response.statusCode}");
      if (response.statusCode != 200) {
        log.severe(
          "Server Gateway Error: ${response.data} - Cannot communicate to the server",
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
 

 Dio _createDio(String? baseUrl) {
    return Dio(BaseOptions(
              baseUrl: baseUrl ?? r'http://localhost',
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 10),
            ));
  }

  DefaultApi _createApi() {
    final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);
    final accessToken = IsarStore.get(StoreKey.accessToken, "");
    // final customHeadersStr = IsarStore.get(StoreKey.customHeaders, "");

    final dio = _createDio(endpoint);


    final interceptors = [setDeviceHeadersInterceptor(),BearerAuthInterceptor()];


    final api = Openapi(dio: dio,interceptors: interceptors);

    api.setBearerAuth('bearer', accessToken);
    return api.getDefaultApi();
  }



  DeviceHeaderInterceptor setDeviceHeadersInterceptor()  {
    // Make sign-in request
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

   final Map<String,String> headers = {};

    try {
      if (Platform.isIOS) {
      
        deviceInfoPlugin.iosInfo.then((iosInfo) {
             headers['deviceModel'] = iosInfo.utsname.machine;
             headers['deviceType'] = 'iOS';
        });
     
      } else {

        deviceInfoPlugin.androidInfo.then((androidInfo){
             headers['deviceModel'] = androidInfo.model;
             headers['deviceType'] = 'Android';
        });
    
      }
    } catch (e) {
      // log.warning("Failed to set device headers: $e");
    }


    return DeviceHeaderInterceptor(headers: headers);

  }

}



  


class DeviceHeaderInterceptor extends Interceptor {
  final Map<String, String> headers;

  DeviceHeaderInterceptor({Map<String, String>? headers}): headers = headers ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(headers);
    super.onRequest(options, handler);
  }

}
