import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/utils/semester_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomeBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentHomeBody({super.key, required this.academicPeriodRepository});

  @override
  State<StudentHomeBody> createState() => _StudentHomeBodyState();
}

class _StudentHomeBodyState extends State<StudentHomeBody> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    _getSubjectHome();
  }

  _getSubjectHome() async {
    var academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();

    // Always use specific period filter to ensure consistency
    if (academicPeriod != "") {
      setState(() {
        BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
          academicPeriod: academicPeriod,
          major: "",
          context: context,
        ));
      });
    } else {
      // Fallback if no period found (should rarely happen if repo init is correct)
      setState(() {
        BlocProvider.of<SubjectBloc>(context).add(GetSubject(context: context));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.948;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      String userNpm = "";
      if (authState is AuthAuthenticated) {
        userNpm = authState.user.name;
      }

      return BlocConsumer<AcademicPeriodBloc, AcademicPeriodState>(
        listener: (context, apState) {
          if (apState is AcademicPeriodLoaded) {
            BlocProvider.of<SubjectBloc>(context).add(GetSubject(
                period: apState.currentAcademicPeriod, context: context));
          }
        },
        builder: (context, apState) {
          String currentSemesterStr = "Memuat...";
          if (apState is AcademicPeriodLoaded) {
            final activePeriod = apState.academicPeriod.firstWhere(
                (p) => p.academicPeriodId == apState.currentAcademicPeriod,
                orElse: () => apState.academicPeriod.first);

            final semNum = SemesterHelper.calculateSemester(
                userNpm, activePeriod.yearStart, activePeriod.oddEven);
            final calYear = SemesterHelper.calculateCalendarYear(
                activePeriod.yearStart, activePeriod.oddEven);
            currentSemesterStr = "Semester $semNum $calYear";
          }

          return BlocConsumer<SubjectBloc, SubjectState>(
            listener: (context, state) {
              if (state is SubjectLoadFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Mohon maaf, terjadi kesalahan dalam mengambil data mata kuliah anda'),
                    duration: const Duration(milliseconds: 1500),
                    width: 280.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SubjectLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return RefreshIndicator(
                child: ListView(
                  controller: ScrollController(),
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  children: _getSubject(
                      state, currentSemesterStr, screenWidth, screenHeight),
                ),
                onRefresh: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final academicPeriod =
                      prefs.getString("current_academic_period");
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));
                  setState(() {
                    BlocProvider.of<SubjectBloc>(context).add(GetSubject(
                        period: academicPeriod ?? "", context: context));
                  });
                },
              );
            },
          );
        },
      );
    });
  }
}

List<Widget> _getSubject(SubjectState state, String currentSemesterStr,
    double screenWidth, double screenHeight) {
  if (state is SubjectLoaded) {
    int subjectCount = state.subjects.length;

    // Custom Header
    Widget header = Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Anda Memiliki $subjectCount Mata Kuliah",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A), // Very dark slate color
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentSemesterStr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B), // Slate gray color
            ),
          ),
        ],
      ),
    );

    return [header, ...state.data];
  } else if (state is SubjectLoadFailed) {
    return [
      SizedBox(
        width: screenWidth,
        height: screenHeight * 0.9,
        child: const Column(
          children: [
            Gap(20),
            Text("Gagal memuat data (Format Salah/Error)"),
            Icon(Icons.error_outline, color: Colors.red),
          ],
        ),
      )
    ];
  } else {
    return [
      SizedBox(
        width: screenWidth,
        height: screenHeight * 0.9,
        child: const Column(
          children: [
            Gap(20),
            Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
          ],
        ),
      )
    ];
  }
}
