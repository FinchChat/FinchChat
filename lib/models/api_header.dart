class ApiHeader {
  String key;
  String value;

  ApiHeader({required this.key, required this.value});

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  factory ApiHeader.fromJson(Map<String, dynamic> json) =>
      ApiHeader(key: json['key'] as String, value: json['value'] as String);
}
