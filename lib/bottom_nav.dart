import 'package:assignment/gitrepo.dart';
import 'package:assignment/photos.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Gitrepo(),
    UnsplashGallery()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40), 
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: 'Gallery',
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            selectedItemColor: Colors.blue.shade700,
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedItemColor: Colors.white,
          ),
        ),
      ),
    );
  }
}