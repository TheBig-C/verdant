import 'package:flutter/material.dart';
import 'package:verdant/Pages/CalendarPage.dart';
import 'package:verdant/Pages/Plants/AllPlantsPage.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:verdant/Tema/AppColors.dart';
import 'package:verdant/pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const AllPlantsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Esto centra el contenido en el AppBar
          children: [
            Image.asset(
              'assets/images/LogoSecundario.png',
              height: 50,
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.whatshot, color: Colors.white),
                SizedBox(width: 5),
                Text('12', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Plantas',
          ),
        ],
      ),
    );
  }
}
