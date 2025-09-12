import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:sui_dart/constants.dart';

class ApiInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Constants.enableDebugLog) {
      print("");
      print("--------------- request ---------------");
      print(options.uri.toString());
      print(options.headers.toString());
      print(options.contentType == "application/json"
          ? jsonEncode(options.data)
          : options.data.toString());
      print("--------------- request end -------------");
      print("");
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Constants.enableDebugLog) {
      print("");
      print("--------------- response ---------------");
      print(response.data.toString());
      print("------------- response end -------------");
      print("");
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Constants.enableDebugLog) {
      print("");
      print("--------------- error ---------------");
      print(err.toString());
      print(err.response.toString());
      print("------------- error end ------------");
      print("");
    }
    super.onError(err, handler);
  }
}
