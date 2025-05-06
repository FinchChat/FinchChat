enum ApiServiceType {
  openai, // For official OpenAI and compatible ones like LiteLLM, many self-hosted
  anthropic,
  grok,
  ollama, // Ollama has its own API structure slightly different from OpenAI's
}

extension ApiServiceTypeParser on ApiServiceType {
  static ApiServiceType fromString(String typeString) {
    return ApiServiceType.values.firstWhere((e) => e.name == typeString);
  }
}
