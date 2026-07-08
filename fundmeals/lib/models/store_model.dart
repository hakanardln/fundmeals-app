class Store {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String category;
  final String? logo;
  final String? banner;
  final double rating;
  final bool isOpen;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.category,
    this.logo,
    this.banner,
    this.rating = 0.0,
    this.isOpen = false,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      category: json['category'] ?? '',
      logo: json['logo'],
      banner: json['banner'],
      rating: (json['rating'] ?? 0).toDouble(),
      isOpen: json['is_open'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'category': category,
      'logo': logo,
      'banner': banner,
      'rating': rating,
      'is_open': isOpen,
    };
  }
}
