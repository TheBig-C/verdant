class Plant {
  final String name;
  final List<String> species; // Cambiado a una lista
  final String description;
  final String imageUrl;
  final String additionalInfo;
  final String obtainedDate;

  Plant({
    required this.name,
    required this.species,
    required this.description,
    required this.imageUrl,
    required this.additionalInfo,
    required this.obtainedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'description': description,
      'imageUrl': imageUrl,
      'additionalInfo': additionalInfo,
      'obtainedDate': obtainedDate,
    };
  }
}
