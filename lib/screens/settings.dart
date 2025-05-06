import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import '../view_models/api_config_viewmodel.dart';
import '../widgets/api_config_form.dart'; // Adjust import paths

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const String routeName = '/settings';

  void _navigateToAddEditForm(BuildContext context, [ApiConfig? config]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => ApiConfigForm(initialConfig: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ApiConfigViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configurations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddEditForm(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadConfigs(),
        child: Consumer<ApiConfigViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.configs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null && vm.configs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${vm.errorMessage}'),
                    ElevatedButton(
                      onPressed: () => vm.loadConfigs(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (vm.configs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No API configurations found.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _navigateToAddEditForm(context),
                      child: const Text('Add New Configuration'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: vm.configs.length,
              itemBuilder: (ctx, index) {
                final config = vm.configs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(
                      config.isEnabled
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      color:
                          config.isEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                    ),
                    title: Text(config.serviceName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${config.serviceType.name}'),
                        Text('URL: ${config.baseUrl}'),
                        if (config.defaultModel != null &&
                            config.defaultModel!.isNotEmpty)
                          Text('Default Model: ${config.defaultModel}'),
                        if (config.apiKey == null || config.apiKey!.isEmpty)
                          Text(
                            'API Key: Not Set',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddEditForm(context, config);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(
                            context,
                            viewModel,
                            config.id,
                            config.serviceName,
                          );
                        } else if (value == 'toggle') {
                          viewModel.toggleEnableConfig(
                            config.id,
                            config.isEnabled,
                          );
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: const [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    config.isEnabled
                                        ? Icons.toggle_off_outlined
                                        : Icons.toggle_on_outlined,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(config.isEnabled ? 'Disable' : 'Enable'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red[700],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                    isThreeLine:
                        (config.defaultModel != null &&
                            config.defaultModel!.isNotEmpty) ||
                        (config.apiKey == null || config.apiKey!.isEmpty),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    ApiConfigViewModel viewModel,
    String configId,
    String serviceName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete the configuration "$serviceName"?',
                ),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                viewModel.deleteConfig(configId);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuration "$serviceName" deleted.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
