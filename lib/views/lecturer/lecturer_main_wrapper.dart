import 'dart:io';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/assignments/assignment_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/college_report_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/home/home_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/subject_score_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LecturerMainWrapper extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerMainWrapper({
    super.key,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  @override
  State<LecturerMainWrapper> createState() => _LecturerMainWrapperState();
}

class _LecturerMainWrapperState extends State<LecturerMainWrapper> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        LecturerHomePage(
            academicPeriodRepository: widget.academicPeriodRepository,
            majorRepository: widget.majorRepository),
        LecturerSubjectScorePage(
            academicPeriodRepository: widget.academicPeriodRepository,
            majorRepository: widget.majorRepository),
        LecturerAssignmentPage(
            academicPeriodRepository: widget.academicPeriodRepository,
            majorRepository: widget.majorRepository),
        LecturerCollegeReportPage(
            academicPeriodRepository: widget.academicPeriodRepository,
            majorRepository: widget.majorRepository),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Colors.grey.shade500;

    return PopScope(
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectedColor,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard_rounded,
                size: _selectedIndex == 0 ? 28 : 24,
                color: _selectedIndex == 0 ? primaryColor : unselectedColor,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.menu_book_rounded,
                size: _selectedIndex == 1 ? 28 : 24,
                color: _selectedIndex == 1 ? primaryColor : unselectedColor,
              ),
              label: 'Buku Nilai',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.folder_rounded,
                size: _selectedIndex == 2 ? 28 : 24,
                color: _selectedIndex == 2 ? primaryColor : unselectedColor,
              ),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment_rounded, 
                size: _selectedIndex == 3 ? 28 : 24,
                color: _selectedIndex == 3 ? primaryColor : unselectedColor,
              ),
              label: 'Pelaporan',
            ),
          ],
        ),
      ),
      onPopInvokedWithResult: (isPop, _) {
        if (isPop) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          }
          if (Platform.isIOS) {
            exit(0);
          }
        }
      },
    );
  }

  // Unused _buildIcon helper removed
}
