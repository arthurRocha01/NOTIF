class SectorModel {
  final String id;
  final String name;

  const SectorModel({required this.id, required this.name});

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SectorModel && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
