import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentPage({required this.paymentUrl, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentResult = 'Đang xử lý thanh toán...';

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final url = request.url;

                if (url.contains('/payment-result')) {
                  final uri = Uri.parse(url);
                  final status = uri.queryParameters['status'];

                  switch (status) {
                    case 'success':
                      _paymentResult = 'Thanh toán thành công 🎉';
                      break;
                    case 'failed':
                      _paymentResult = 'Thanh toán thất bại hoặc bị hủy ❌';
                      break;
                    case 'already_paid':
                      _paymentResult = 'Đơn hàng đã thanh toán trước đó.';
                      break;
                    case 'order_not_found':
                      _paymentResult = 'Không tìm thấy đơn hàng.';
                      break;
                    case 'server_error':
                      _paymentResult = 'Lỗi hệ thống, vui lòng thử lại.';
                      break;
                    case 'invalid_signature':
                      _paymentResult = 'Chữ ký không hợp lệ.';
                      break;
                    default:
                      _paymentResult = 'Kết quả thanh toán không xác định.';
                  }

                  // Thoát WebView và trở về với kết quả
                  Navigator.pop(context, _paymentResult);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán VNPAY')),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
