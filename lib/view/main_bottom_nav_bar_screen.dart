import 'package:flutter/material.dart';
import 'package:trippy_customer/view/home_screen.dart';
import 'package:trippy_customer/view/myTrip_screen.dart';
import 'package:trippy_customer/view/offer_screen.dart';
import 'package:trippy_customer/view/profile_screen.dart';

class MainBottomNavBarScreen extends StatefulWidget {
  const MainBottomNavBarScreen({super.key});

  @override
  State<MainBottomNavBarScreen> createState() => _MainBottomNavBarScreenState();
}

class _MainBottomNavBarScreenState extends State<MainBottomNavBarScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(), 
    MytripScreen(),
    OfferScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.grey
        ),
        child: BottomNavigationBar(
          selectedFontSize: 14,
          unselectedFontSize: 14,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: IconTheme(data: IconThemeData(
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey
              ),
              child: Icon(Icons.home_outlined)),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: IconTheme(data: IconThemeData(
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey
              ),
              child: Icon(Icons.train_sharp)),
              label: "My Trip",
            ),
            BottomNavigationBarItem(
              icon: IconTheme(data: IconThemeData(
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey
              ),
              child: Icon(Icons.home_outlined)),
              label: "Offers",
            ),
            BottomNavigationBarItem(icon: IconTheme(data: IconThemeData(
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey
              ),
            child: Icon(Icons.person)), label: "Profile"),
          ],
        ),
      ),
      // bottomNavigationBar: NavigationBar(
      //   indicatorColor: Colors.transparent,
      //   backgroundColor: Colors.white,
      //   selectedIndex: _selectedIndex,
      //   destinations: const [
      //     NavigationDestination(icon: Icon(Icons.home_outlined,), label: 'Home'),
      //     NavigationDestination(
      //       icon: Icon(Icons.train_sharp),
      //       label: 'My Trip',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Offers',
      //     ),
      //     NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      // ),
    );
  }
}
