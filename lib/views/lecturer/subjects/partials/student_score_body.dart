import 'package:classroom_itats_mobile/models/student_score.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/student_score/student_score_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SubjectScoreBody extends StatefulWidget {
  final Subject subject;

  const SubjectScoreBody({super.key, required this.subject});

  @override
  State<SubjectScoreBody> createState() => _SubjectScoreBodyState();
}

class _SubjectScoreBodyState extends State<SubjectScoreBody> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<StudentScoreBloc>(context).add(
      GetStudentScore(
          academicPeriod: widget.subject.academicPeriodId,
          subjectId: widget.subject.subjectId,
          subjectClass: widget.subject.subjectClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.95;

    return BlocConsumer<StudentScoreBloc, StudentScoreState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Placeholder(
          color: Colors.transparent,
          child: RefreshIndicator(
            child: ListView(
              controller: ScrollController(),
              scrollDirection: Axis.vertical,
              children: [
                const Gap(20),
                Column(
                  children: [
                    SizedBox(
                      width: screenWidth,
                      child: Text(
                        widget.subject.subjectName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: screenWidth,
                      child: Text(
                        "${widget.subject.lecturerId} - ${widget.subject.lecturerName}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getPercentageScore(state, screenWidth),
                ),
              ],
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));

              setState(() {
                BlocProvider.of<StudentScoreBloc>(context).add(
                  GetStudentScore(
                      academicPeriod: widget.subject.academicPeriodId,
                      subjectId: widget.subject.subjectId,
                      subjectClass: widget.subject.subjectClass),
                );
              });
            },
          ),
        );
      },
    );
  }
}

List<Widget> _getPercentageScore(state, double screenWidth) {
  if (state is StudentScoreLoading) {
    return [
      const Center(
        child: CircularProgressIndicator(),
      ),
    ];
  } else if (state is StudentScoreLoaded) {
    return [
      Column(
        children: _percentage(state.studentScores, screenWidth),
      )
    ];
  } else {
    return [
      Column(
        children: _percentage(List.empty(), screenWidth),
      )
    ];
  }
}

List<Widget> _percentage(List<StudentScore> studentScores, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var studentScore in studentScores) {
    scores.add(
      Row(
        children: [
          SizedBox(
            width: screenWidth,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  studentScore.studentId,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Gap(5),
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  studentScore.sudentName,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  studentScore.numericScore,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(5),
                                Text(
                                  studentScore.alphabeticScore,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
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
