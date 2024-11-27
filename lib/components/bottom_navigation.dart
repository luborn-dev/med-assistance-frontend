import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Perfil",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          label: "FAQ",
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
