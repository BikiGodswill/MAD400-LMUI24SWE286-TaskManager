import 'package:flutter/material.dart';

// ProfileScreen is a StatelessWidget because nothing on this screen changes.
// It just displays fixed personal information.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // CircleAvatar shows initials when there is no photo
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.teal,
              child: Text(
                // *** REPLACE with your actual initials ***
                'AB',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'BIKI GODs WILL BETHA',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Student ID: LMUI24SWE286',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 4),

            Text(
              'B.tech Software Engineering | Level 400 direct b.tech',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Bio section
            _sectionTitle('About Me'),
            const SizedBox(height: 10),

            // *** REPLACE with 2-3 sentences about yourself ***
            const Text(
              'I am a passionate software engineering student with a keen interest in mobile and web development. '
              'I enjoy solving real-world problems through code and am always eager to learn new technologies. '
              'Outside of school, I love reading tech blogs and participating in hackathons.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            _sectionTitle('My Top 3 Goals This Semester'),
            const SizedBox(height: 12),

            _goalCard('🎯', 'Complete all assignments before deadlines'),
            const SizedBox(height: 10),
            _goalCard('📱', 'Build a fully functional Flutter app for my portfolio'),
            const SizedBox(height: 10),
            _goalCard('📚', 'Achieve a GPA of at least 3.5 this semester'),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper method to build a section title — reused to keep code DRY
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  // Helper method to build each goal card
  Widget _goalCard(String emoji, String goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(goal, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
