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
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';

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
      child: MultiBlocListener(
        listeners: [
          BlocListener<AcademicPeriodBloc, AcademicPeriodState>(
            listener: (context, state) {
              if (state is AcademicPeriodLoaded) {
                final selectedPeriod = state.currentAcademicPeriod;
                if (selectedPeriod.isNotEmpty) {
                  context
                      .read<PresensiBloc>()
                      .add(LoadActivePresences(selectedPeriod));
                  context
                      .read<AssignmentBloc>()
                      .add(GetActiveAssignments(period: selectedPeriod));
                }
              }
            },
          ),
        ],
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
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
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
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.fact_check_rounded,
                      size: _selectedIndex == 1 ? 28 : 24,
                      color: _selectedIndex == 1 ? primaryColor : unselectedColor,
                    ),
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
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.folder_rounded,
                      size: _selectedIndex == 2 ? 28 : 24,
                      color: _selectedIndex == 2 ? primaryColor : unselectedColor,
                    ),
                    BlocBuilder<AssignmentBloc, AssignmentState>(
                      builder: (context, state) {
                        if (state is AssignmentLoaded) {
                          // Filter tasks that haven't been submitted and are past or before deadline
                          // The 'Belum' status specifically is what we used in the assignments logic:
                          // totalSubmited == 0 && dueDate.isAfter(DateTime.now())
                          final unsubmittedCount = state.assignments
                              .where((item) =>
                                  item.totalSubmited == 0 &&
                                  item.dueDate.isAfter(DateTime.now()))
                              .length;

                          if (unsubmittedCount > 0) {
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
                                  '$unsubmittedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
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

  // Fungsi _buildIcon untuk gambar dihapus karena sekarang memakai native vector Icons
}
