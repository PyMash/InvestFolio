import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;


class TestFullScreen extends StatelessWidget {
  const TestFullScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulated Fullscreen with Virtual Scroll',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: const PreferredSize(child: SizedBox(), preferredSize: Size.zero),
        bottomNavigationBar: const PreferredSize(child: SizedBox(), preferredSize: Size.zero),
        body: Center(
          child: VirtualScrollable(),
        ),
      ),
    );
  }
}

class VirtualScrollable extends StatelessWidget {
  final items = List.generate(1000, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            items[index],
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        );
      },
    );
  }
}