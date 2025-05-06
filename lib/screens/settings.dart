import 'package:flutter/material.dart';
import '../models/ai_service_manager.dart';
import '../models/ai_service_details.dart';

class SettingsScreen extends StatefulWidget {
  // Route name for navigation
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiServiceManager _aiServiceManager = AiServiceManager();
  late AiService _selectedService;
  bool _isLoading = true;
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedService =
        _aiServiceManager.getAllServices().isNotEmpty
            ? _aiServiceManager.getAllServices().first
            : AiService.values.first;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _aiServiceManager.loadApiKeys();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    print('Saving settings for $_selectedService');
    print('API Key: ${_apiKeyController.text}');
  }

  @override
  void dispose() {
    _apiKeyController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                // Use Padding for spacing around the content
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // Use Column for vertical layout
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align items left
                  children: <Widget>[
                    Text(
                      'Configure API Key:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20), // Spacing
                    // --- Dropdown to select the service ---
                    DropdownButtonFormField<AiService>(
                      value: _selectedService, // Current selection state
                      decoration: const InputDecoration(
                        labelText: 'Select AI Service',
                        border: OutlineInputBorder(),
                      ),
                      // Create items from the available services list
                      items:
                          _aiServiceManager.getAllServices().map((
                            AiService service,
                          ) {
                            // Get details from manager for display name
                            final details = _aiServiceManager
                                .getAiServiceDetails(service);
                            return DropdownMenuItem<AiService>(
                              value: service,
                              child: Text(details.label),
                            );
                          }).toList(),
                      // Handle selection change
                      onChanged: (AiService? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedService = newValue;
                            _apiKeyController.text =
                                _aiServiceManager
                                    .getAiServiceDetails(_selectedService)
                                    .apiKey ??
                                '';
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15), // Spacing
                    // --- Text field for the API key ---
                    TextField(
                      controller: _apiKeyController, // Link to controller
                      decoration: InputDecoration(
                        // Dynamic label based on selected service
                        labelText:
                            '${_aiServiceManager.getAiServiceDetails(_selectedService).label} API Key',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true, // Hide the key visually
                      keyboardType:
                          TextInputType.visiblePassword, // Appropriate keyboard
                    ),

                    const SizedBox(height: 25), // Spacing
                    // --- Save Button ---
                    ElevatedButton(
                      onPressed: _saveSettings, // Call save function
                      // Dynamic button label
                      child: Text(
                        'Save ${_aiServiceManager.getAiServiceDetails(_selectedService).label} Key',
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
