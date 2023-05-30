import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/utils/utils.dart';
import 'package:chatty/common/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide FormData;


class HttpUtil {
  static HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;

  late Dio dio;
  CancelToken cancelToken = new CancelToken();


  HttpUtil._internal() {
    // BaseOptions, Options, and RequestOptions can all configure parameters, and the priority levels increase in order, and parameters can be overwritten according to the priority level
    BaseOptions options = new BaseOptions(
      // request base address, can contain subpaths
      baseUrl: SERVER_API_URL,

      // baseUrl: storage. read(key: STORAGE_KEY_APIURL) ?? SERVICE_API_BASEURL,
      //Connection server timeout, the unit is milliseconds.
      connectTimeout: 60000,

      // The interval between two received data on the response stream, in milliseconds.
      receiveTimeout: 5000,

      // Http request header.
      headers: {},

      /// Content-Type of the request, the default value is "application/json; charset=utf-8".
      /// If you want to encode request data in "application/x-www-form-urlencoded" format,
      /// You can set this option to `Headers.formUrlEncodedContentType`, so [Dio]
      /// The request body will be automatically encoded.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] indicates that the response data is expected to be accepted in that format (method).
      /// Currently [ResponseType] accepts three types `JSON`, `STREAM`, `PLAIN`.
      ///
      /// The default value is `JSON`, when the content-type in the response header is "application/json", dio will automatically convert the response content into a json object.
      /// If you want to receive the response data in binary mode, such as downloading a binary file, you can use `STREAM`.
      ///
      /// If you want to receive response data in text (string) format, please use `PLAIN`.
      responseType: ResponseType.json,
    );

    dio = new Dio(options);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Cookie management
    CookieJar cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // add interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Do something before request is sent
        return handler. next(options); //continue
        // If you want to complete the request and return some custom data, you can resolve a Response object `handler.resolve(response)`.
        // In this way, the request will be terminated, the upper layer then will be called, and the data returned in then will be your custom response.
        //
        // If you want to terminate the request and trigger an error, you can return a `DioError` object, such as `handler.reject(error)`,
        // This request will be aborted and an exception will be triggered, and the upper catchError will be called.
      },
      onResponse: (response, handler) {
        // Do something with response data
        return handler. next(response); // continue
        // If you want to terminate the request and trigger an error, you can reject a `DioError` object, such as `handler.reject(error)`,
        // This request will be aborted and an exception will be triggered, and the upper catchError will be called.
      },
      onError: (DioError e, handler) {
        // Do something with response error
        Loading. dismiss();
        ErrorEntity eInfo = createErrorEntity(e);
        onError(eInfo);
        return handler. next(e); //continue
        // If you want to complete the request and return some custom data, you can resolve a `Response`, such as `handler.resolve(response)`.
        // In this way, the request will be terminated, the upper layer then will be called, and the data returned in then will be your custom response.
      },
    ));
  }

  /*
    * Unified processing of errors
    */

  // error handling
  void onError(ErrorEntity eInfo) {
    print('error.code -> ' +
        eInfo.code.toString() +
        ', error.message -> ' +
        eInfo.message);
    switch (eInfo.code) {
      case 401:
        UserStore.to.onLogout();
        EasyLoading.showError(eInfo.message);
        break;
      default:
        EasyLoading.showError('unknown mistake');
        break;
    }
  }

  // error message
  ErrorEntity createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType. cancel:
        return ErrorEntity(code: -1, message: "Request to cancel");
      case DioErrorType. connectTimeout:
        return ErrorEntity(code: -1, message: "Connection timed out");
      case DioErrorType. sendTimeout:
        return ErrorEntity(code: -1, message: "Request timed out");
      case DioErrorType.receiveTimeout:
        return ErrorEntity(code: -1, message: "Response timed out");
      case DioErrorType. cancel:
        return ErrorEntity(code: -1, message: "Request to cancel");
      case DioErrorType. response:
        {
          try {
            int errCode =
                error.response != null ? error.response!.statusCode! : -1;
            // String errMsg = error.response.statusMessage;
            // return ErrorEntity(code: errCode, message: errMsg);
            switch (errCode) {
              case 400:
                return ErrorEntity(code: errCode, message: "Request syntax error");
              case 401:
                return ErrorEntity(code: errCode, message: "No permission");
              case 403:
                return ErrorEntity(code: errCode, message: "The server refuses to execute");
              case 404:
                return ErrorEntity(code: errCode, message: "Unable to connect to server");
              case 405:
                return ErrorEntity(code: errCode, message: "The request method is forbidden");
              case 500:
                return ErrorEntity(code: errCode, message: "Internal server error");
              case 502:
                return ErrorEntity(code: errCode, message: "Invalid request");
              case 503:
                return ErrorEntity(code: errCode, message: "The server is down");
              case 505:
                return ErrorEntity(code: errCode, message: "HTTP protocol request is not supported");
              default:
                {
                  // return ErrorEntity(code: errCode, message: "unknown mistake");
                  return ErrorEntity(
                    code: errCode,
                    message: error.response != null
                        ? error.response!.statusMessage!
                        : "",
                  );
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "unknown mistake");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: error.message);
        }
    }
  }

  /*
    * cancel request
    *
    * The same cancel token can be used for multiple requests. When a cancel token is cancelled, all requests using the cancel token will be cancelled.
    * so parameters are optional
    */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  /// Read local configuration
  Map<String, dynamic>? getAuthorizationHeader() {
    var headers = <String, dynamic>{};
    if (Get.isRegistered<UserStore>() && UserStore.to.hasToken == true) {
      headers['Authorization'] = 'Bearer ${UserStore.to.token}';
    }
    return headers;
  }

  /// restful get operation
  /// refresh whether to pull down to refresh, default false
  /// noCache Does not cache the default true
  /// Whether list is a list or not, the default is false
  /// cacheKey cache key
  /// cacheDisk is disk cache
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool refresh = false,
    bool noCache = !CACHE_ENABLE,
    bool list = false,
    String cacheKey = '',
    bool cacheDisk = false,
  }) async {
    Options requestOptions = options ?? Options();
    if (requestOptions.extra == null) {
      requestOptions.extra = Map();
    }
    requestOptions.extra!.addAll({
      "refresh": refresh,
      "noCache": noCache,
      "list": list,
      "cacheKey": cacheKey,
      "cacheDisk": cacheDisk,
    });
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }

    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  /// restful post operate
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {

    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );

    return response.data;
  }

  /// restful put operate
  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  /// restful patch operate
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  /// restful delete operate
  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  /// restful post form form submit action
  Future postForm(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.post(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }

  /// restful post Stream streaming data
  Future postStream(
    String path, {
    dynamic data,
    int dataLength = 0,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    requestOptions.headers!.addAll({
      Headers.contentLengthHeader: dataLength.toString(),
    });
    var response = await dio.post(
      path,
      data: Stream.fromIterable(data.map((e) => [e])),
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response.data;
  }
}

// exception handling
class ErrorEntity implements Exception {
  int code = -1;
  String message = "";
  ErrorEntity({required this.code, required this.message});

  String toString() {
    if (message == "") return "Exception";
    return "Exception: code $code, $message";
  }
}
