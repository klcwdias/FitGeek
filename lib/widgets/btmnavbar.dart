import 'package:flutter/material.dart';

class BtmNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BtmNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<BtmNavBar> createState() => _BtmNavBarState();
}

class _BtmNavBarState extends State<BtmNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Assistant',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.sports_gymnastics),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/splash_screen.png",
            width: 60,
            height: 60,
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.food_bank),
          label: 'Diet',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      iconSize: 28,
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.black,
      selectedIconTheme: const IconThemeData(
        color: Colors.blue,
      ),
      unselectedItemColor: const Color.fromARGB(255, 146, 146, 146),
      showUnselectedLabels: false,
      showSelectedLabels: false,
      onTap: (int index) {
        // Navigate to the desired page
        if (index == 0) {
          Navigator.pushNamed(context, '/assistant');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/workout');
        } else if (index == 2) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (index == 3) {
          Navigator.pushNamed(context, '/diet');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/profile');
        }
        widget.onItemSelected(index);
      },
    );
  }
}
