import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class StudentScoreRecapBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const StudentScoreRecapBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<StudentScoreRecapBody> createState() => _StudentScoreRecapBodyState();
}

class _StudentScoreRecapBodyState extends State<StudentScoreRecapBody> {
  @override
  void initState() {
    super.initState();

    _checkLoad();
  }

  _checkLoad() {
    // Selalu reload — cek 'state is! AssignmentLoaded' salah karena
    // AssignmentBloc global bisa punya data Loaded dari subject lain.
    if (!mounted) return;
    BlocProvider.of<AssignmentBloc>(context).add(GetStudentAssignmentScore(
      academicPeriod: widget.subject.academicPeriodId,
      subjectId: widget.subject.subjectId,
      subjectClass: widget.subject.subjectClass,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.948;

    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is AssignmentLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Placeholder(
          color: Colors.transparent,
          child: RefreshIndicator(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: ListView(
                      controller: ScrollController(),
                      scrollDirection: Axis.vertical,
                      children: [
                        const Gap(20),
                        const Column(
                          children: [
                            Text(
                              "Rekap Nilai",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              _getStudentAssignmentScore(state, screenWidth),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));

                setState(() {
                  BlocProvider.of<AssignmentBloc>(context).add(
                      GetStudentAssignmentScore(
                        academicPeriod: widget.subject.academicPeriodId,
                        subjectId: widget.subject.subjectId,
                        subjectClass: widget.subject.subjectClass,
                      ));
                });
              }),
        );
      },
    );
  }
}

List<Widget> _getStudentAssignmentScore(state, double screenWidth) {
  if (state is AssignmentLoaded) {
    if (state.studentAssigmentScores.isEmpty) {
      return [
        SizedBox(
          width: screenWidth,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 80, color: Colors.grey.shade400),
              const Gap(16),
              Text(
                "Belum Ada Nilai",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const Gap(8),
              Text(
                "Nilai tugas atau kuis belum tersedia.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        )
      ];
    }

    return [
      Column(
        children:
            _studentAssignmentScore(state.studentAssigmentScores, screenWidth),
      )
    ];
  } else {
    return [
      SizedBox(
        width: screenWidth,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade400),
            const Gap(16),
            Text(
              "Mohon maaf, nilai tugas atau ujian belum tersedia",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
    ];
  }
}

List<Widget> _studentAssignmentScore(
    List<StudentAssignmentScore> studentAssignmentScores, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var studentAssignmentScore in studentAssignmentScores) {
    Color mainColor = const Color(0xFF1E5AD6);
    Color bgColor = const Color(0xFFE8F0FE);
    IconData iconData = Icons.assignment_outlined;
    Color progressColor;

    if (studentAssignmentScore.score <= 50) {
      progressColor = Colors.red;
    } else if (studentAssignmentScore.score <= 70) {
      progressColor = Colors.amber.shade700;
    } else {
      progressColor = const Color(0xFF00A389); // Match green theme
    }

    scores.add(
      Container(
        margin: const EdgeInsets.only(bottom: 10), // Minimal gap
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Very tight vertical padding
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Rounded Icon
            Container(
              width: 38, // Compressed size
              height: 38, // Compressed size
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(iconData, color: mainColor, size: 20),
              ),
            ),
            const Gap(12),
            // Middle Content: Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentAssignmentScore.assignmentTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    "Tugas / Kuis",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            // Right Content: Score and Progress Line
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${studentAssignmentScore.score}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const Gap(8),
                // Tiny Progress Bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 40 *
                            (studentAssignmentScore.score / 100)
                                .clamp(0.0, 1.0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  return scores;
}
