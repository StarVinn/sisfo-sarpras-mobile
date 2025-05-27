class Denda {
  final int id;
  final String name;
  final String description;
  final String nominal;

  Denda({
    required this.id,
    required this.name,
    required this.description,
    required this.nominal,
  });

  factory Denda.fromJson(Map<String, dynamic> json) {
    return Denda(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      nominal: json['nominal'],
    );
  }
}
