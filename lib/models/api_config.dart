import 'package:finch_chat/models/api_header.dart';
import 'package:finch_chat/models/api_service_type.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class ApiConfig {
  final String id; // Unique identifier, used as key for secure storage
  String serviceName; // User-defined friendly name
  ApiServiceType serviceType;
  String?
  apiKey; // Nullable if not yet set or if service doesn't require one (e.g. some local Ollama setups)
  String baseUrl;
  String? defaultModel;
  bool isEnabled;
  List<ApiHeader> additionalHeaders;

  ApiConfig({
    required this.serviceName,
    required this.serviceType,
    this.apiKey, // API key will be fetched from secure storage separately
    required this.baseUrl,
    this.defaultModel,
    this.isEnabled = true,
    List<ApiHeader>? additionalHeaders,
  }) : additionalHeaders = additionalHeaders ?? [],
       id = const Uuid().v4();

  // For SQLite storage (API key is not stored here)
  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'serviceType': serviceType.name, // Use the extension getter
      'baseUrl': baseUrl,
      'defaultModel': defaultModel,
      'isEnabled': isEnabled ? 1 : 0,
      'additionalHeaders': jsonEncode(
        additionalHeaders.map((h) => h.toJson()).toList(),
      ),
    };
  }

  factory ApiConfig.fromMap(Map<String, dynamic> map) {
    return ApiConfig(
      serviceName: map['serviceName'] as String,
      serviceType: ApiServiceTypeParser.fromString(
        map['serviceType'] as String,
      ),
      baseUrl: map['baseUrl'] as String,
      defaultModel: map['defaultModel'] as String?,
      isEnabled: (map['isEnabled'] as int? ?? 1) == 1,
      additionalHeaders:
          (jsonDecode(map['additionalHeaders'] as String? ?? '[]') as List)
              .map((h) => ApiHeader.fromJson(h as Map<String, dynamic>))
              .toList(),
    );
  }
}
