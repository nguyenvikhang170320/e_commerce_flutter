import 'package:app_ecommerce/screens/login_page.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> introData = [
    {
      'text': 'Chào mừng bạn đến với ứng dụng',
      'image': 'assets/images/screen1.png',
    },
    {
      'text': 'Quản lý sản phẩm & danh mục dễ dàng',
      'image': 'assets/images/screen2.png',
    },
    {'text': 'Hãy bắt đầu nào!', 'image': 'assets/images/screen3.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: introData.length,
            itemBuilder: (context, index) {
              return IntroScreen(
                text: introData[index]['text']!,
                image: introData[index]['image']!,
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child:
                _currentPage == 2
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          ),
                      child: Text('Bắt đầu', style: TextStyle(fontSize: 18)),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        introData.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  final String text;
  final String image;

  const IntroScreen({required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250, fit: BoxFit.contain),
          SizedBox(height: 30),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
