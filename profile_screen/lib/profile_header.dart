import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/me.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontSize: 28,
              color: colors.primary,
            ),
          ),
          Text(university, style: TextStyle(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
