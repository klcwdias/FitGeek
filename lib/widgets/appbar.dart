import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/homepage.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const Appbar({super.key, required this.title});

  @override
  State<Appbar> createState() => _AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarState extends State<Appbar> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  late bool unreadNoti;

  Future<void> checkNotifications() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('notifications')
        .where('uid', isEqualTo: currentUser!.uid)
        .where('readstatus', isEqualTo: false)
        .get();
    if (qs.docs.isNotEmpty) {
      print(qs.docs);

      setState(() {
        unreadNoti = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu_sharp,
            size: 30,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          widget.title,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_sharp, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 30,
            ),
            onPressed: () {
              // Open the settings page.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
