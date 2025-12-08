import 'package:flutter/material.dart';
import 'package:sustainable_tracker/Views/Pages/Home.dart';
import 'package:sustainable_tracker/Views/Pages/Profile.dart';
import 'package:sustainable_tracker/Views/Pages/Progress.dart';
import 'package:sustainable_tracker/Views/Pages/Search.dart';
import 'package:sustainable_tracker/Views/widgets/navbar_widget.dart';
import 'package:sustainable_tracker/data/notifiiers.dart';

List<Widget> pages = [Home(), searchPage(), ProgressPage(), ProfilePage()];

class widgetTree extends StatelessWidget {
  const widgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
