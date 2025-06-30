import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo/Header
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),

            // App Name
            const Center(
              child: Text(
                'EcoTrack',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // About Content
            _buildSection(
              title: 'What is EcoTrack?',
              content: 'EcoTrack is a mobile application designed to empower consumers to make informed and responsible purchasing decisions by providing clear, verified insights into the sustainability of everyday products. With growing concerns about climate change, unethical labor practices, and environmental degradation, EcoTrack addresses the need for greater transparency in the retail world.',
            ),

            _buildSection(
              content: 'By simply scanning a product\'s barcode, users can instantly access critical information such as its carbon footprint, ethical certifications, packaging sustainability, and overall environmental impact.',
            ),

            _buildSection(
              title: 'Unique Features',
              content: 'Unlike other sustainability apps that focus on specific industries like fashion or cosmetics, EcoTrack offers a universal solution across multiple product categories, including food, electronics, household goods, and more. It also includes features like a personalized sustainability score, a tracker for monitoring one\'s environmental footprint over time, and community reviews that validate or challenge brands\' eco-claims.',
            ),

            _buildSection(
              content: 'EcoTrack not only empowers individuals to make greener choices but also holds businesses accountable and promotes truly sustainable brands by exposing greenwashing.',
            ),

            _buildSection(
              title: 'Our Mission',
              content: 'Whether you\'re shopping in a supermarket, browsing online, or trying to reduce your carbon footprint, EcoTrack provides a simple, reliable, and user-friendly platform to support ethical consumerism in all areas of daily life. With EcoTrack, every purchase becomes a step toward a more sustainable future.',
            ),

            const SizedBox(height: 30),

            // Version Info
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}