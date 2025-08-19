import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PageController _pageController = PageController();
  final List<String> _galleryImages = [
    'assets/gallery-img-2.webp',
    'assets/gallery-img-3.webp',
    'assets/gallery-img-4.webp',
    'assets/gallery-img-5.webp',
    'assets/gallery-img-6.webp',
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _galleryImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _galleryImages[index],
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_galleryImages.length, (index) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.orange : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}