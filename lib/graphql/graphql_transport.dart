import 'dart:convert';

import 'package:dio/dio.dart';

/// GraphQL-over-HTTP transport for Sui queries.
class GraphQLTransport {
  GraphQLTransport(this.endpoint, {Dio? dio, this.headers = const {}})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final String endpoint;
  final Map<String, String> headers;
  final Dio _dio;

  /// Executes [document] without discarding partial data or structured errors.
  Future<GraphQLResponse> request(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
    Map<String, dynamic>? extensions,
    CancelToken? cancelToken,
  }) async {
    late Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        endpoint,
        data: {
          'query': document,
          if (variables != null) 'variables': variables,
          if (operationName != null) 'operationName': operationName,
          if (extensions != null) 'extensions': extensions,
        },
        cancelToken: cancelToken,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {'accept': Headers.jsonContentType, ...headers},
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (error) {
      throw GraphQLRequestException(
        error.type == DioExceptionType.cancel
            ? 'GraphQL request cancelled'
            : 'GraphQL request failed${error.message == null ? '' : ': ${error.message}'}',
        statusCode: error.response?.statusCode,
        isCancelled: error.type == DioExceptionType.cancel,
      );
    }

    final statusCode = response.statusCode;
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw GraphQLRequestException(
        'GraphQL request failed (HTTP ${statusCode ?? 'unknown'})',
        statusCode: statusCode,
      );
    }

    dynamic rawBody = response.data;
    if (rawBody is String) {
      try {
        rawBody = jsonDecode(rawBody);
      } on FormatException {
        throw const GraphQLRequestException('Invalid GraphQL JSON response');
      }
    }
    if (rawBody is! Map) {
      throw const GraphQLRequestException('Invalid GraphQL response body');
    }

    final body = Map<String, dynamic>.from(rawBody);
    final rawData = body['data'];
    final rawErrors = body['errors'];
    return GraphQLResponse(
      data: rawData is Map ? Map<String, dynamic>.from(rawData) : null,
      errors: rawErrors is List
          ? rawErrors
                .map(GraphQLError.fromJson)
                .whereType<GraphQLError>()
                .toList()
          : const [],
      extensions: body['extensions'] is Map
          ? Map<String, dynamic>.from(body['extensions'] as Map)
          : null,
    );
  }

  /// Executes [document] and returns its `data`, throwing on GraphQL errors.
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
    Map<String, dynamic>? extensions,
    CancelToken? cancelToken,
  }) async {
    final response = await request(
      document,
      variables: variables,
      operationName: operationName,
      extensions: extensions,
      cancelToken: cancelToken,
    );
    if (response.errors.isNotEmpty) {
      throw GraphQLException(response.errors);
    }
    if (response.data == null) {
      throw const GraphQLRequestException('GraphQL response missing "data"');
    }
    return response.data!;
  }
}

class GraphQLResponse {
  const GraphQLResponse({
    required this.data,
    required this.errors,
    this.extensions,
  });

  final Map<String, dynamic>? data;
  final List<GraphQLError> errors;
  final Map<String, dynamic>? extensions;

  bool get hasErrors => errors.isNotEmpty;
}

class GraphQLError {
  const GraphQLError({
    required this.message,
    this.locations = const [],
    this.path,
    this.extensions,
  });

  final String message;
  final List<GraphQLErrorLocation> locations;
  final List<dynamic>? path;
  final Map<String, dynamic>? extensions;

  static GraphQLError? fromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    return GraphQLError(
      message: json['message']?.toString() ?? 'Unknown GraphQL error',
      locations: json['locations'] is List
          ? (json['locations'] as List)
                .map(GraphQLErrorLocation.fromJson)
                .whereType<GraphQLErrorLocation>()
                .toList()
          : const [],
      path: json['path'] is List
          ? List<dynamic>.from(json['path'] as List)
          : null,
      extensions: json['extensions'] is Map
          ? Map<String, dynamic>.from(json['extensions'] as Map)
          : null,
    );
  }
}

class GraphQLErrorLocation {
  const GraphQLErrorLocation({required this.line, required this.column});

  final int line;
  final int column;

  static GraphQLErrorLocation? fromJson(dynamic value) {
    if (value is! Map || value['line'] is! num || value['column'] is! num) {
      return null;
    }
    return GraphQLErrorLocation(
      line: (value['line'] as num).toInt(),
      column: (value['column'] as num).toInt(),
    );
  }
}

class GraphQLRequestException implements Exception {
  const GraphQLRequestException(
    this.message, {
    this.statusCode,
    this.isCancelled = false,
  });

  final String message;
  final int? statusCode;
  final bool isCancelled;

  @override
  String toString() => 'GraphQLRequestException: $message';
}

class GraphQLException implements Exception {
  GraphQLException(this.errors)
    : message = errors.map((error) => error.message).join('; ');

  final String message;
  final List<GraphQLError> errors;

  @override
  String toString() => 'GraphQLException: $message';
}
