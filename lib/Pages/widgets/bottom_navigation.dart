import 'package:flutter/material.dart';
import 'package:verdant/Pages/Plants/AllPlantsPage.dart';
import 'package:verdant/Pages/home_page.dart';
import 'package:verdant/Pages/CalendarPage.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({super.key, required this.selectedIndex, required this.onTap});

  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: (index) {
        // Llamar al callback onTap que viene del widget padre
        widget.onTap(index);

        // Realizamos la navegación según el índice
        switch (index) {
          case 0:
            // Navegar a la página de inicio (HomePage)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;
          case 1:
            // Navegar a la página del calendario (CalendarPage)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            );
            break;
          case 2:
            // Navegar a la página de plantas (AllPlantsPage)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlantsPage()),
            );
            break;
          default:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Plants'),
      ],
    );
  }
}
