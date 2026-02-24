import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/utils/semester_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentAppBar({super.key, required this.academicPeriodRepository});

  @override
  State<StudentAppBar> createState() => _StudentAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StudentAppBarState extends State<StudentAppBar> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AcademicPeriodBloc>(context).add(GetAcademicPeriod());
  }

  _onButtonFilterPressed() async {
    final prefs = await SharedPreferences.getInstance();

    final academicPeriod = prefs.getString("current_academic_period");

    setState(() {
      BlocProvider.of<SubjectBloc>(context)
          .add(GetSubject(period: academicPeriod ?? "", context: context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kiri: Logo & Text
            Row(
              children: [
                Image.asset(
                  "assets/application_images/Logo_Classroom_Square-no_bg.png", // Using square logo for the graduation cap
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                const Text(
                  "ITATS CLASSROOM",
                  style: TextStyle(
                    color: Color(0xFF14307E), // Dark blue color from the image
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            // Kanan: Filter Icon & Profile Avatar
            Row(
              children: [
                // Filter Icon Custom
                InkWell(
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Filter Semester'),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                            String userNpm = "";
                            if (authState is AuthAuthenticated) {
                              userNpm = authState.user.name;
                            }
                            return BlocConsumer<AcademicPeriodBloc,
                                    AcademicPeriodState>(
                                listener: (context, state) {
                              if (state is AcademicPeriodLoadFailed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Gagal Menampilkan Periode Akademik'),
                                    duration:
                                        const Duration(milliseconds: 1500),
                                  ),
                                );
                              }
                            }, builder: (context, state) {
                              return DropdownMenu<String>(
                                width: 220,
                                initialSelection: state is AcademicPeriodLoaded
                                    ? state.currentAcademicPeriod
                                    : "",
                                label: const Text("Tahun Ajaran"),
                                onSelected: (String? value) {
                                  widget.academicPeriodRepository
                                      .setAcademicPeriod(value ?? "");
                                },
                                dropdownMenuEntries: state
                                        is AcademicPeriodLoaded
                                    ? state.academicPeriod.map((value) {
                                        final semNum =
                                            SemesterHelper.calculateSemester(
                                                userNpm,
                                                value.yearStart,
                                                value.oddEven);
                                        final calYear = SemesterHelper
                                            .calculateCalendarYear(
                                                value.yearStart, value.oddEven);
                                        return DropdownMenuEntry(
                                            value: value.academicPeriodId,
                                            label: "Semester $semNum $calYear");
                                      }).toList()
                                    : [],
                              );
                            });
                          }),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            BlocProvider.of<AcademicPeriodBloc>(context)
                                .add(GetAcademicPeriod());
                            _onButtonFilterPressed();
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('Terapkan'),
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/application_images/filter.png",
                      height: 24, // Reasonable size for filter icon
                      color: const Color(0xFF14307E), // Match logo color
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Profile Avatar (Clickable for logout/profile)
                GestureDetector(
                  onTap: () {
                    // Show simple bottom sheet or navigation
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text('Profil Saya'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                        context, "/student/profile");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout,
                                      color: Colors.red),
                                  title: const Text('Keluar',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    BlocProvider.of<AuthBloc>(context)
                                        .add(LoggedOut());
                                  },
                                ),
                              ],
                            ));
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Color(0xFFF0B384), // Skin tone base color from image
                    child: Icon(Icons.person,
                        color: Colors.white), // Placeholder if no real image
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
