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

  _checkLoad() async {
    bool loaded =
        await widget.userRepository.getWidgetState('student_score_recap');
    if (!loaded) {
      setState(() {
        BlocProvider.of<AssignmentBloc>(context).add(GetStudentAssignmentScore(
            masterActivityId: widget.subject.activityMasterId));
      });
      await widget.userRepository.setWidgetState('student_score_recap', true);
    }
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
                          masterActivityId: widget.subject.activityMasterId));
                });
              }),
        );
      },
    );
  }
}

List<Widget> _getStudentAssignmentScore(state, double screenWidth) {
  if (state is AssignmentLoaded) {
    return [
      Column(
        children:
            _studentAssignmentScore(state.studentAssigmentScores, screenWidth),
      )
    ];
  } else {
    return [
      const Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
    ];
  }
}

List<Widget> _studentAssignmentScore(
    List<StudentAssignmentScore> studentAssignmentScores, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var studentAssignmentScore in studentAssignmentScores) {
    scores.add(
      Row(
        children: [
          SizedBox(
            width: screenWidth,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              width: screenWidth,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    color: studentAssignmentScore.score <= 50
                        ? Colors.red
                        : studentAssignmentScore.score > 50 &&
                                studentAssignmentScore.score <= 70
                            ? Colors.amber
                            : Colors.green,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      side: BorderSide(
                          color: studentAssignmentScore.score <= 50
                              ? Colors.red
                              : studentAssignmentScore.score > 50 &&
                                      studentAssignmentScore.score <= 70
                                  ? Colors.amber
                                  : Colors.green),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.5,
                                child: Text(
                                  studentAssignmentScore.assignmentTitle,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Gap(screenWidth * 0.2),
                              SizedBox(
                                width: screenWidth * 0.2,
                                child: Text(
                                  "${studentAssignmentScore.score}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    scores.add(const Gap(10));
  }

  return scores;
}
