class Barang {
  final int id;
  final String nama;
  final int quantity;
  final String kondisi;
  final String? image;
  final String? categoryName;

  Barang({
    required this.id,
    required this.nama,
    required this.quantity,
    required this.kondisi,
    this.image,
    this.categoryName,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      nama: json['nama'],
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity']),
      kondisi: json['kondisi'],
      image: json['image'],
      categoryName: json['category_name'],
    );
  }
}
