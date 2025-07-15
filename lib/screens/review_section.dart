import 'package:app_ecommerce/models/reviews.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_ecommerce/services/review_service.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ReviewSection extends StatefulWidget {
  final int productId;
  final bool allowReview;

  const ReviewSection({Key? key, required this.productId,  this.allowReview = false }) : super(key: key);

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  List<Review> reviews = [];
  Review? userReview;
  int rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final fetched = await ReviewService.fetchReviews(
        widget.productId,
        token: userProvider.accessToken,
      );

      final userId = userProvider.userId;
      final found = fetched.firstWhereOrNull((r) => r.userId == userId);

      setState(() {
        reviews = fetched;
        userReview = found;
        if (userReview != null) {
          rating = userReview!.rating;
          _commentController.text = userReview!.comment;
        } else {
          rating = 5;
          _commentController.clear();
        }
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi loadReviews: $e');
      setState(() {
        reviews = [];
        userReview = null;
        isLoading = false;
      });
    }
  }



  Future<void> submitReview() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final success = await ReviewService.submitReview(
      productId: widget.productId,
      rating: rating,
      comment: _commentController.text,
      token: token!,
    );

    if (success) {
      await loadReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đánh giá')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Đánh giá sản phẩm', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          const Text('Chưa có đánh giá')
        else
          Column(
            children: reviews.map((review) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: review.userImage != null
                      ? NetworkImage(review.userImage!)
                      : null,
                  child: review.userImage == null ? const Icon(Icons.person) : null,
                ),
                title: Text(review.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.comment),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(review.createdAt)),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Text('${review.rating}/5'),
              );
            }).toList(),
          ),

        const Divider(height: 30),

        if (userProvider.role == 'user'&& widget.allowReview)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userReview != null ? 'Cập nhật đánh giá của bạn:' : 'Gửi đánh giá của bạn:'),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => rating = i + 1),
                  );
                }),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(hintText: 'Viết nhận xét...'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: submitReview,
                child: Text(userReview != null ? 'Cập nhật đánh giá' : 'Gửi đánh giá'),
              )
            ],
          ),
      ],
    );
  }
}
