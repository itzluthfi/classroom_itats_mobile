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
      BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
        academicPeriod: academicPeriod,
        major: "",
        context: context,
      ));
    } else {
      // Fallback if no period found (should rarely happen if repo init is correct)
      BlocProvider.of<SubjectBloc>(context).add(GetSubject(context: context));
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
  if (state is SubjectLoading) {
    Widget header = Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Anda Memiliki ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              ShimmerEffect(
                child: Container(
                  width: 40,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const Text(
                " Mata Kuliah",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                Text(
                  currentSemesterStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    List<Widget> skeletonCards = List.generate(3, (index) {
      return Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: ShimmerEffect(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: screenWidth * 0.85,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 180,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 45,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });

    return [header, ...skeletonCards];
  }

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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                Text(
                  currentSemesterStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
        height: screenHeight * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
            Gap(16),
            Text(
              "Gagal memuat jadwal (Format Salah/Error)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  } else {
    return [
      SizedBox(
        width: screenWidth,
        height: screenHeight * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
            Gap(16),
            Text(
              "Mohon maaf, Anda belum memiliki jadwal mata kuliah",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent - 0.5) * 2, 0.0, 0.0);
  }
}
