import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './api_config.dart';
import './api_config_viewmodel.dart'; // Adjust import path
import './api_service_type.dart';
import './api_header.dart';

class ApiConfigForm extends StatefulWidget {
  final ApiConfig? initialConfig; // Null if adding new

  const ApiConfigForm({super.key, this.initialConfig});

  @override
  State<ApiConfigForm> createState() => _ApiConfigFormState();
}

class _ApiConfigFormState extends State<ApiConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceNameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _defaultModelController;

  late ApiServiceType _selectedServiceType;
  late bool _isEnabled;
  late List<ApiHeader> _additionalHeaders;

  @override
  void initState() {
    super.initState();
    final config = widget.initialConfig;
    _serviceNameController = TextEditingController(
      text: config?.serviceName ?? '',
    );
    _baseUrlController = TextEditingController(
      text:
          config?.baseUrl ??
          _getDefaultBaseUrl(config?.serviceType ?? ApiServiceType.openai),
    );
    _apiKeyController = TextEditingController(
      text: config?.apiKey ?? '',
    ); // API key is for input, not directly from stored config.apiKey here
    _defaultModelController = TextEditingController(
      text: config?.defaultModel ?? '',
    );
    _selectedServiceType = config?.serviceType ?? ApiServiceType.openai;
    _isEnabled = config?.isEnabled ?? true;
    _additionalHeaders = List<ApiHeader>.from(
      config?.additionalHeaders.map(
            (h) => ApiHeader(key: h.key, value: h.value),
          ) ??
          [],
    );

    // Pre-fill base URL if a standard type is selected and no initial config or empty base URL
    if (config == null || config.baseUrl.isEmpty) {
      _baseUrlController.text = _getDefaultBaseUrl(_selectedServiceType);
    }
  }

  String _getDefaultBaseUrl(ApiServiceType type) {
    switch (type) {
      case ApiServiceType.openai:
        return 'https://api.openai.com/v1';
      case ApiServiceType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ApiServiceType.grok:
        return 'https://api.x.ai/v1'; // Placeholder, check actual Grok API
      case ApiServiceType.ollama:
        return 'http://localhost:11434/api'; // Common local Ollama, user might change
      default:
        return '';
    }
  }

  void _addHeaderField() {
    setState(() {
      _additionalHeaders.add(ApiHeader(key: '', value: ''));
    });
  }

  void _removeHeaderField(int index) {
    setState(() {
      _additionalHeaders.removeAt(index);
    });
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _defaultModelController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newConfig = ApiConfig(
        serviceName: _serviceNameController.text.trim(),
        serviceType: _selectedServiceType,
        baseUrl: _baseUrlController.text.trim(),
        defaultModel:
            _defaultModelController.text.trim().isNotEmpty
                ? _defaultModelController.text.trim()
                : null,
        isEnabled: _isEnabled,
        additionalHeaders:
            _additionalHeaders.where((h) => h.key.isNotEmpty).toList(),
        // apiKey is passed separately to the view model
      );

      final apiKey = _apiKeyController.text.trim();
      final viewModel = Provider.of<ApiConfigViewModel>(context, listen: false);
      bool success;

      if (widget.initialConfig == null) {
        success = await viewModel.addConfig(
          newConfig,
          apiKey.isNotEmpty ? apiKey : null,
        );
      } else {
        success = await viewModel.updateConfig(
          newConfig,
          apiKey.isNotEmpty ? apiKey : null,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Configuration ${widget.initialConfig == null ? "added" : "updated"} successfully!',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${widget.initialConfig == null ? "add" : "update"} configuration: ${viewModel.errorMessage ?? "Unknown error"}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialConfig == null
              ? 'Add API Configuration'
              : 'Edit API Configuration',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name (e.g., My OpenAI GPT-4)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ApiServiceType>(
                value: _selectedServiceType,
                decoration: const InputDecoration(labelText: 'Service Type'),
                items:
                    ApiServiceType.values.map((ApiServiceType type) {
                      return DropdownMenuItem<ApiServiceType>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                onChanged: (ApiServiceType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedServiceType = newValue;
                      // Optionally update base URL if it's one of the defaults and user hasn't changed it much
                      if (_baseUrlController.text ==
                              _getDefaultBaseUrl(
                                ApiServiceType.values.firstWhere(
                                  (t) => t != newValue,
                                  orElse: () => _selectedServiceType,
                                ),
                              ) ||
                          _baseUrlController.text.isEmpty) {
                        _baseUrlController.text = _getDefaultBaseUrl(newValue);
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText:
                      'e.g., https://api.openai.com/v1 or http://localhost:11434',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a base URL';
                  }

                  final Uri? uri = Uri.tryParse(value.trim());

                  if (uri == null) {
                    return 'Invalid URL format'; // URI couldn't be parsed at all
                  }

                  if (!uri.isAbsolute) {
                    return 'Please enter an absolute URL (e.g., http://... or https://...)';
                  }

                  return null; // Validation passed
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText:
                      'API Key (leave blank if not applicable or to clear)',
                  hintText:
                      widget.initialConfig?.apiKey != null &&
                              widget.initialConfig!.apiKey!.isNotEmpty
                          ? '******** (stored securely, enter to change)'
                          : 'Enter API Key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _defaultModelController,
                decoration: const InputDecoration(
                  labelText: 'Default Model ID (Optional)',
                  hintText: 'e.g., gpt-4-turbo, llama3-8b-8192',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enabled'),
                value: _isEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Custom Headers (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _additionalHeaders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _additionalHeaders[index].key,
                            decoration: InputDecoration(
                              labelText: 'Header ${index + 1} Name',
                            ),
                            onChanged:
                                (value) =>
                                    _additionalHeaders[index].key =
                                        value.trim(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _additionalHeaders[index].value,
                            decoration: InputDecoration(
                              labelText: 'Header ${index + 1} Value',
                            ),
                            onChanged:
                                (value) =>
                                    _additionalHeaders[index].value =
                                        value.trim(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeHeaderField(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Header'),
                onPressed: _addHeaderField,
              ),

              const SizedBox(height: 24),
              // TODO: Add a "Test Connection" button here
              // This would require making an actual API call (e.g., list models)
              // using the provided details and showing success/failure.
              // Center(child: ElevatedButton(onPressed: _saveForm, child: const Text('Save Configuration'))),
            ],
          ),
        ),
      ),
    );
  }
}
