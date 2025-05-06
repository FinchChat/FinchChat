enum AiService { chatgpt, grok, gemini, claude }

Map<AiService, String> aiServiceLabel = {
  AiService.chatgpt: 'ChatGPT',
  AiService.grok: 'Grok',
  AiService.gemini: 'Gemini',
  AiService.claude: 'Claude',
};

class AiServiceDetails {
  final String label;
  final String storageKey;
  String? apiKey;

  AiServiceDetails({
    required this.label,
    required this.storageKey,
    this.apiKey,
  });
}
