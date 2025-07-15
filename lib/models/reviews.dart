class Review {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String comment;
  final String createdAt;
  final String userName;
  final String? userImage; // 👈 thêm trường avatar

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.userImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
      userName: json['user_name'] ?? 'Người dùng',
      userImage: json['user_image'], // 👈 map avatar nếu có
    );
  }
}
