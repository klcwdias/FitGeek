import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../pages/homepage.dart';

class ExampleSidebarX extends StatelessWidget {
  // Get the current user
  final User? user = FirebaseAuth.instance.currentUser;

  ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;
  adminpanel() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // The user is signed in
      final String email = user.email!;
      return email;
    } else {
      // No user is signed in
      print('No user signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: const TextStyle(color: primaryColor, fontSize: 18),
        selectedTextStyle: const TextStyle(color: primaryColor, fontSize: 18),
        itemTextPadding: const EdgeInsets.only(left: 22),
        selectedItemTextPadding: const EdgeInsets.only(left: 22),
        iconTheme: const IconThemeData(
          color: primaryColor,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: primaryColor,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 300,
        padding: EdgeInsets.only(bottom: 12),
        itemPadding: EdgeInsets.only(top: 5, left: 20),
        selectedItemPadding: EdgeInsets.only(top: 5, left: 20),
        decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30))),
      ),
      footerDivider: divider,
      /*footerBuilder: (context, extended) {
        return Container(
          //color: Colors.amber,
          //padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: const Text('Powered by Dart Squad'),
        );
      },*/ /*
      headerBuilder: (context, extended) {
        return const SizedBox(
          height: 35,
        );
      },*/
      items: [
        //SidebarXItem()
        SidebarXItem(
          icon: Icons.arrow_back,
          label: 'Services',
          onTap: () {
            Scaffold.of(context).closeDrawer();
          },
        ),
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ],
    );
  }
}

/*
class ScreensExample extends StatelessWidget {
  const ScreensExample({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) => Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  //color: Theme.of(context).canvasColor,
                  //boxShadow: const [BoxShadow()],
                ),
              ),
            );
          default:
            return const Text('');
        }
      },
    );
  }
}
*/
const white = Colors.white;
const primaryColor = Color.fromARGB(255, 0, 0, 0);
const canvasColor = Color.fromARGB(255, 244, 244, 244);
const scaffoldBackgroundColor = Color(0xFF464667);

final divider = Divider(color: Colors.black.withOpacity(0.3), height: 1);
//ThemeProvider().getThemeMode() != ThemeMode.dark