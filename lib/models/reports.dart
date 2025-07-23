class Report {
  final int id;
  final int userId;
  final int productId;
  final String reason;
  final String status;
  final DateTime createdAt;

  // Thêm nếu bạn muốn hiển thị thêm thông tin liên quan
  final String? productName;
  final String? userName;

  Report({
    required this.id,
    required this.userId,
    required this.productId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.productName,
    this.userName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      reason: json['reason'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'], // nếu backend trả kèm
      userName: json['user_name'],       // nếu backend trả kèm
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'product_name': productName,
      'user_name': userName,
    };
  }
}
