import 'package:flutter/foundation.dart';
import './api_config.dart';
import './api_config_service.dart'; // Adjust import path

class ApiConfigViewModel extends ChangeNotifier {
  final ApiConfigService _apiConfigService = ApiConfigService();
  List<ApiConfig> _configs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApiConfig> get configs => _configs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ApiConfigViewModel() {
    loadConfigs();
  }

  Future<void> loadConfigs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _configs = await _apiConfigService.getAllConfigs();
    } catch (e) {
      _errorMessage = "Failed to load configurations: ${e.toString()}";
      print(_errorMessage); // Log error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addConfig(ApiConfig config, String? apiKey) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiConfigService.saveConfig(config, apiKey);
      await loadConfigs(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = "Failed to add configuration: ${e.toString()}";
      print(_errorMessage); // Log error
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateConfig(ApiConfig config, String? apiKey) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiConfigService.updateConfig(config, apiKey);
      await loadConfigs(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = "Failed to update configuration: ${e.toString()}";
      print(_errorMessage); // Log error
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteConfig(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiConfigService.deleteConfig(id);
      await loadConfigs(); // Refresh list
    } catch (e) {
      _errorMessage = "Failed to delete configuration: ${e.toString()}";
      print(_errorMessage); // Log error
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleEnableConfig(String id, bool currentStatus) async {
    _isLoading = true;
    _errorMessage = null;
    // No need to notify for isLoading here, as it's a quick operation
    // and the list will be re-fetched anyway for visual update.
    try {
      await _apiConfigService.toggleConfigEnabled(id, !currentStatus);
      await loadConfigs(); // Refresh list to show updated status
    } catch (e) {
      _errorMessage = "Failed to toggle configuration: ${e.toString()}";
      _isLoading = false; // Set loading to false only on error for this case
      notifyListeners();
    }
    // _isLoading = false; // Should be handled by loadConfigs if it sets it
    // notifyListeners(); // Handled by loadConfigs
  }
}
