class Order {
  final int id;
  final int userId;
  final double total;
  final String paymentStatus;
  final String stripeSessionId;
  final DateTime createdAt;
  final String address;
  final String phone;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.total,
    required this.paymentStatus,
    required this.stripeSessionId,
    required this.createdAt,
    required this.address,
    required this.phone,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      total: json['total'].toDouble(),
      paymentStatus: json['payment_status'],
      stripeSessionId: json['stripe_session_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      address: json['address'],
      phone: json['phone'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'payment_status': paymentStatus,
      'stripe_session_id': stripeSessionId,
      'created_at': createdAt.toIso8601String(),
      'address': address,
      'phone': phone,
      'status': status,
    };
  }
}
