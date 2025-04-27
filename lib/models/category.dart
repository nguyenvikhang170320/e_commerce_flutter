class Category {
  final int id;
  final String name;
  final String description;
  final String createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}
