import 'dart:io';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/views/student/home/home_page.dart';
import 'package:classroom_itats_mobile/views/student/presensi/presensi_page.dart';
import 'package:classroom_itats_mobile/views/student/tugas/tugas_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/presensi/presensi_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';

class StudentMainWrapper extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentMainWrapper({super.key, required this.academicPeriodRepository});

  @override
  State<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends State<StudentMainWrapper> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        StudentHomePage(
            academicPeriodRepository: widget.academicPeriodRepository),
        StudentPresensiPage(
            academicPeriodRepository: widget.academicPeriodRepository),
        StudentTugasPage(
            academicPeriodRepository: widget.academicPeriodRepository),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna berdasarkan tema aplikasi
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Colors.grey.shade500;

    return PopScope(
      child: BlocListener<AcademicPeriodBloc, AcademicPeriodState>(
        listener: (context, state) {
          if (state is AcademicPeriodLoaded) {
            final selectedPeriod = state.currentAcademicPeriod;
            if (selectedPeriod.isNotEmpty) {
              context
                  .read<PresensiBloc>()
                  .add(LoadActivePresences(selectedPeriod));
            }
          }
        },
        child: Scaffold(
          // AnimatedSwitcher memberikan efek fade saat tap berpindah
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
            // Elevasi dan border radius untuk tampilan lebih modern
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: primaryColor,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon('assets/application_images/home.png',
                    _selectedIndex == 0, primaryColor, unselectedColor),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildIcon('assets/application_images/presensi.png',
                        _selectedIndex == 1, primaryColor, unselectedColor),
                    BlocBuilder<PresensiBloc, PresensiState>(
                      builder: (context, state) {
                        if (state is PresensiLoaded &&
                            state.belumAbsen.isNotEmpty) {
                          return Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${state.belumAbsen.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: 'Presensi',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/application_images/tugas.png',
                    _selectedIndex == 2, primaryColor, unselectedColor),
                label: 'Tugas',
              ),
            ],
          ),
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

  // Fungsi helper untuk membangun icon dengan logic ukuran dan warna (Animated)
  Widget _buildIcon(
      String assetPath, bool isSelected, Color activeColor, Color idleColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(
          isSelected ? 0 : 4), // Scale down slightly when not selected
      child: Image.asset(
        assetPath,
        width: isSelected ? 28 : 24, // Size change indicator
        height: isSelected ? 28 : 24,
        color: isSelected ? activeColor : idleColor, // Color change indicator
      ),
    );
  }
}
