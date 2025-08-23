import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const MarkdownPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  String _markdownData = "";
  bool isAgreed = false;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    final data = await rootBundle.loadString(widget.assetPath);
    setState(() {
      _markdownData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: _markdownData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: Markdown(
                data: _markdownData,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  Theme.of(context),
                ).copyWith(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                  h1: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  h2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
