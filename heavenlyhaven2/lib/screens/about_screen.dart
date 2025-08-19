import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'assets/about-img-1.jpg', // Best Staff image
      'text': 'Best Staff',
    },
    {
      'image': 'assets/about-img-2.jpg', // Placeholder for Best Food image
      'text': 'Best Food',
    },
    {
      'image': 'assets/about-img-3.jpg', // Placeholder for Swimming Pool image
      'text': 'Swimming Pool',
    },
  ];

  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'About Heavenly Havens',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nestled in the heart of the city, Heavenly Havens offers luxurious accommodations with modern amenities. Our hotel features world-class service and facilities to make your stay unforgettable.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 350,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _carouselItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _carouselItems[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['text']!,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_carouselItems.length, (index) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentCarouselIndex == index
                          ? Colors.orange
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAmenity(Icons.pool, 'Infinity Pool'),
            _buildAmenity(Icons.restaurant, 'Gourmet Dining'),
            _buildAmenity(Icons.spa, 'Spa Services'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAmenity(Icons.wifi, 'Free WiFi'),
            _buildAmenity(Icons.fitness_center, 'Gym'),
            _buildAmenity(Icons.local_bar, 'Bar'),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Colors.orange),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}