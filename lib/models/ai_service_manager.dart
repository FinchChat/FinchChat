import './ai_service_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiServiceManager {
  final Map<AiService, AiServiceDetails> _serviceDetails = {};

  bool _isApiKeysLoaded = false;

  static final AiServiceManager _instance = AiServiceManager._internal();
  factory AiServiceManager() {
    return _instance;
  }
  AiServiceManager._internal() {
    _initializeServices();
  }

  void _initializeServices() {
    for (final service in AiService.values) {
      _serviceDetails[service] = AiServiceDetails(
        label: aiServiceLabel[service]!,
        storageKey: 'apiKey_${service.name}',
        apiKey: '',
      );
    }
  }

  Future<void> loadApiKeys() async {
    if (_isApiKeysLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    for (final service in _serviceDetails.keys) {
      final details = _serviceDetails[service]!;
      final storedValue = prefs.getString(details.storageKey);
      details.apiKey = storedValue ?? '';
    }
    _isApiKeysLoaded = true;
  }

  AiServiceDetails getAiServiceDetails(AiService service) {
    return _serviceDetails[service]!;
  }

  List<AiService> getAllServices() {
    return _serviceDetails.keys.toList();
  }
}
