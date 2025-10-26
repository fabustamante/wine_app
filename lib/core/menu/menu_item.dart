import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String path;

  MenuItem({
    required this.title,
    required this.icon,
    required this.path,
  });
}

List<MenuItem> menu = [
  MenuItem(title: 'Wines', icon: Icons.local_bar, path: '/wines'),
  MenuItem(title: 'Profile', icon: Icons.person, path: '/profile'),
  MenuItem(title: 'Settings', icon: Icons.settings, path: '/settings'),
];