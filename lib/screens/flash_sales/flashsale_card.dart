import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_service.dart';
import '../../models/flash_sale.dart';
import '../../providers/flash_sale_provider.dart';

class FlashSaleCard extends StatefulWidget {
  final FlashSaleProduct flashSale;

  FlashSaleCard({required this.flashSale});

  @override
  State<FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<FlashSaleCard> {
  @override
  Widget build(BuildContext context) {
    final flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String formatCurrency(String amountStr) {
      final amount = double.tryParse(amountStr) ?? 0;
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
    }
    final role = userProvider.role;
    final flashSale = widget.flashSale;
    final percent = ((flashSale.originalPrice - flashSale.flashPrice) /
        flashSale.originalPrice *
        100)
        .round();
    print(percent);
    print(flashSale.originalPrice);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  flashSale.product?.image ?? "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flashSale.product!.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Giá gốc: ',
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextSpan(
                          text:
                          formatCurrency(flashSale.originalPrice.toString()),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: '  (-$percent%)',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Giá giảm: ${formatCurrency(flashSale.flashPrice.toString())}',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),

                  /// ✅ Nếu là seller và chưa được duyệt thì hiển thị Switch
                  if (role == 'seller' && flashSale.status == 'approved')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          flashSale.isActive ? 'Đang bật' : 'Đã tắt',
                          style: TextStyle(fontSize: 12),
                        ),
                        Switch(
                          value: flashSale.isActive,
                          onChanged: (value) async {
                            try {
                              await flashSaleProvider.toggleActiveStatus(flashSale.id);
                              ToastService.showToast(context, message: "Cập nhật trạng thái thành công");
                            } catch (e) {
                              ToastService.showToast(context, message: "Lỗi: $e");
                            }
                          },
                        ),
                      ],
                    ),
                  if (role == 'admin' && flashSale.status == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await flashSaleProvider.approveFlashSale(flashSale.id);
                                ToastService.showToast(context, message: "Đã duyệt Flash Sale");
                                await notificationProvider.sendNotification(
                                  receivers: [flashSale.product!.sellerId!],
                                  title: 'Giảm giá đã duyệt',
                                  message: 'Sản phẩm "${flashSale.product!.name}" đã duyệt bởi Admin.',
                                  type: 'flash-sale',
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              child: Icon(Icons.check, color: Colors.green,),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await flashSaleProvider.rejectFlashSale(
                                  flashSale.id,
                                  flashSale.product!.sellerId!,
                                );

                                await notificationProvider.sendNotification(
                                  receivers: [flashSale.product!.sellerId!],
                                  title: 'Giảm giá bị từ chối',
                                  message: 'Sản phẩm "${flashSale.product!.name}" đã bị từ chối bởi Admin.',
                                  type: 'flash-sale',
                                );

                                await notificationProvider.loadUnreadCount();

                                ToastService.showToast(context, message: "Đã từ chối và gửi thông báo cho seller");
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              child: Icon(Icons.highlight_remove, color: Colors.red,),
                            ),
                          ),
                        ],
                      ),
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
