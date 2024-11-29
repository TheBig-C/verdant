import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdant/Tema/AppColors.dart';
import 'package:verdant/Pages/Plants/AllPlantsPage.dart';
import 'package:verdant/Pages/home_page.dart';
import 'package:verdant/Pages/CalendarPage.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userId;
  int _selectedIndex = 1; 

  late Map<DateTime, List<String>> _plantDates;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

 
  DateTime _firstDay = DateTime.utc(2020, 01, 01); 
  DateTime _lastDay = DateTime.now(); 

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid ?? "";
    _plantDates = {};
    _loadPlantDates();
  }

  Stream<QuerySnapshot> _getUserPlants() {
    return _firestore.collection('plants').where('userId', isEqualTo: _userId).snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadPlantDates() async {
   
    final snapshot = await _firestore
        .collection('plants')
        .where('userId', isEqualTo: _userId)
        .get();

   
    final Map<DateTime, List<String>> plantDates = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String obtainedDateString = data['obtainedDate']; 
      final DateTime obtainedDate = DateTime.parse(obtainedDateString);  
      final plantName = data['name'];

      
      final normalizedDate = DateTime(obtainedDate.year, obtainedDate.month, obtainedDate.day);

      if (plantDates.containsKey(normalizedDate)) {
        plantDates[normalizedDate]?.add(plantName);
      } else {
        plantDates[normalizedDate] = [plantName];
      }
    }

  
    setState(() {
      _plantDates = plantDates;
    });
  }

  List<String> _getEventsForDay(DateTime day) {

    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _plantDates[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
        child: Column(
          
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.principalGreen,  // Color de fondo
                borderRadius: BorderRadius.circular(12.0),  // Border radius
              ),
              
              child: TableCalendar(
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay; 
                  });
                },
                eventLoader: _getEventsForDay, 
                firstDay: _firstDay, 
                lastDay: _lastDay,  
              
                
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, events) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: AppColors.darkGreen),
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, events) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (_getEventsForDay(date).isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.lightGreen,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              
                calendarStyle: CalendarStyle(
                  todayTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: AppColors.darkGreen, // Color de fondo del día actual
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.principalGreen, // Color de fondo cuando se selecciona un día
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: AppColors.darkGreen),
                  defaultDecoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco para todos los días no seleccionados
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: AppColors.darkGreen), // Color de texto para los fines de semana
                  
                  weekendDecoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco para los fines de semana
                    shape: BoxShape.circle,
                  ),
                ),

              
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.veryDarkGreen),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.veryDarkGreen),
                  titleTextStyle: TextStyle(color: AppColors.veryDarkGreen, fontSize: 16),
                ),
              
                // Fondo del calendario
                //
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Plantas obtenidas el ${DateFormat('yMd').format(_selectedDay)}:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Mostrar las plantas obtenidas en la fecha seleccionada
            ..._getEventsForDay(_selectedDay).map((plant) => ListTile(
                  title: Text(plant),
                )),
          ],
        ),
      ),
    );
  }
}
