import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/lecture_presence.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/presence_partial.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/presence_question_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class StudentPresenceBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const StudentPresenceBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<StudentPresenceBody> createState() => _StudentPresenceBodyState();
}

class _StudentPresenceBodyState extends State<StudentPresenceBody> {
  // Subject? _subject;

  @override
  void initState() {
    super.initState();

    _checkLoad();
  }

  _checkLoad() async {
    bool loaded =
        await widget.userRepository.getWidgetState('student_presence');
    if (!loaded) {
      setState(() {
        BlocProvider.of<LectureBloc>(context).add(GetStudentLecture(
          academicPeriod: widget.subject.academicPeriodId,
          subjectId: widget.subject.subjectId,
          subjectClass: widget.subject.subjectClass,
        ));
      });
      await widget.userRepository.setWidgetState('student_presence', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.948;

    return BlocConsumer<LectureBloc, LectureState>(
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
                  const Column(
                    children: [
                      Text(
                        "Presensi",
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
                    children: _getPresence(
                      context,
                      state,
                      screenWidth,
                      widget.subject,
                    ),
                  )
                ],
              ),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                setState(() {
                  BlocProvider.of<LectureBloc>(context).add(GetStudentLecture(
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

List<Widget> _getPresence(
  context,
  state,
  double screenWidth,
  Subject subject,
) {
  if (state is LectureLoading) {
    return [
      const Center(
        child: CircularProgressIndicator(),
      ),
    ];
  } else if (state is LectureLoaded) {
    return [
      Column(
        children: _weekPresence(
          context,
          screenWidth,
          state.lectures,
          state.responsiLectures,
          subject,
        ),
      )
    ];
  } else {
    return [
      Column(
        children: _weekPresence(
          context,
          screenWidth,
          List<LecturePresence>.empty(),
          List.empty(),
          subject,
        ),
      )
    ];
  }
}

List<Widget> _weekPresence(
  context,
  double screenWidth,
  List<LecturePresence> lectures,
  List<List<LecturePresence>> responsiLectures,
  Subject subject,
) {
  List<Widget> weeks = List.empty(growable: true);

  List<List<Widget>> before = List.filled(16, List.empty(growable: true));

  for (var i = 0; i < 16; i++) {
    weeks.add(
      StudentPresencePartial(
        button: SizedBox(
          child: Row(
            children: [
              const Column(
                children: [
                  Icon(
                    Icons.domain_verification,
                    size: 30,
                  )
                ],
              ),
              const Gap(10),
              Text(
                "Minggu ke - ${i + 1}${i < 9 ? "  " : ""}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  for (var i = 0; i < lectures.length; i++) {
    if (lectures[i].presence != null) {
      before[lectures[i].presence!.weekID - 1] = _addNewButton(
          context,
          List.empty(growable: true),
          lectures[i],
          subject,
          screenWidth,
          true,
          true);
      weeks[lectures[i].presence!.weekID - 1] = StudentPresencePartial(
        button: Row(
          children: before[lectures[i].presence!.weekID - 1],
        ),
      );
    } else if (lectures[i].lecture != null) {
      if (lectures[i].lecture!.presenceLimit!.compareTo(DateTime.now()) >= 0) {
        before[lectures[i].lecture!.weekID! - 1] = _addNewButton(
            context,
            List.empty(growable: true),
            lectures[i],
            subject,
            screenWidth,
            true,
            false);
        weeks[lectures[i].lecture!.weekID! - 1] = StudentPresencePartial(
          button: Row(
            children: before[lectures[i].lecture!.weekID! - 1],
          ),
        );
      } else {
        before[lectures[i].lecture!.weekID! - 1] = _addNewButton(
            context,
            List.empty(growable: true),
            lectures[i],
            subject,
            screenWidth,
            false,
            false);
        weeks[lectures[i].lecture!.weekID! - 1] = StudentPresencePartial(
          button: Row(
            children: before[lectures[i].lecture!.weekID! - 1],
          ),
        );
      }
    }
  }

  if (responsiLectures.isNotEmpty) {
    for (var responsi in responsiLectures) {
      for (var i = 0; i < responsi.length; i++) {
        if (responsi[i].presence != null) {
          before[responsi[i].presence!.weekID - 1] = _addNewButton(
              context,
              before[responsi[i].presence!.weekID - 1],
              responsi[i],
              subject,
              screenWidth,
              true,
              true);
          weeks[responsi[i].presence!.weekID - 1] = StudentPresencePartial(
            button: Row(
              children: before[responsi[i].presence!.weekID - 1],
            ),
          );
        } else if (responsi[i].lecture != null) {
          if (responsi[i].lecture!.presenceLimit!.compareTo(DateTime.now()) >=
              0) {
            before[responsi[i].lecture!.weekID! - 1] = _addNewButton(
                context,
                before[responsi[i].lecture!.weekID! - 1],
                responsi[i],
                subject,
                screenWidth,
                true,
                false);
            weeks[responsi[i].lecture!.weekID! - 1] = StudentPresencePartial(
              button: Row(
                children: before[responsi[i].lecture!.weekID! - 1],
              ),
            );
          } else {
            before[responsi[i].lecture!.weekID! - 1] = _addNewButton(
                context,
                before[responsi[i].lecture!.weekID! - 1],
                responsi[i],
                subject,
                screenWidth,
                false,
                false);
            weeks[responsi[i].lecture!.weekID! - 1] = StudentPresencePartial(
              button: Row(
                children: before[responsi[i].lecture!.weekID! - 1],
              ),
            );
          }
        }
      }
    }
  }

  return weeks;
}

List<Widget> _addNewButton(
  context,
  List<Widget> before,
  LecturePresence lecture,
  Subject subject,
  double screenWidth,
  bool notLate,
  bool isPresence,
) {
  List<Widget> data = before;

  if (isPresence) {
    if (before.isEmpty) {
      data.add(
        Expanded(
          child: Row(
            children: [
              const Column(
                children: [
                  Icon(
                    Icons.domain_verification,
                    size: 30,
                  )
                ],
              ),
              const Gap(10),
              Row(
                children: [
                  Text(
                    "Minggu ke - ${lecture.presence!.weekID}${lecture.presence!.weekID < 10 ? "  " : ""}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      data.add(
        SizedBox(
          height: 40,
          width: 40,
          child: TextButton(
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(CircleBorder()),
              backgroundColor: MaterialStatePropertyAll(
                Colors.green,
              ),
            ),
            onPressed: () {},
            child: Text(
              lecture.presence!.collegeType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      data.add(const Gap(5));
    } else {
      data.add(
        SizedBox(
          height: 40,
          width: 40,
          child: TextButton(
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(CircleBorder()),
              backgroundColor: MaterialStatePropertyAll(
                Colors.green,
              ),
            ),
            onPressed: () {},
            child: Text(
              lecture.presence!.collegeType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      data.add(const Gap(5));
    }
  } else {
    if (notLate) {
      if (before.isEmpty) {
        data.add(
          Expanded(
            child: Row(
              children: [
                const Column(
                  children: [
                    Icon(
                      Icons.domain_verification,
                      size: 30,
                    )
                  ],
                ),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Minggu ke - ${lecture.lecture!.weekID!}${lecture.lecture!.weekID! < 10 ? "  " : ""}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "${lecture.lecture!.presenceLimit}",
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        data.add(PresenceQuestionBody(
          subject: subject,
          lecture: lecture.lecture!,
          screenWidth: screenWidth,
        ));
        data.add(const Gap(5));
      } else {
        data.add(PresenceQuestionBody(
          screenWidth: screenWidth,
          lecture: lecture.lecture!,
          subject: subject,
        ));
        data.add(const Gap(5));
      }
    } else {
      if (before.isEmpty) {
        data.add(
          Expanded(
            child: Row(
              children: [
                const Column(
                  children: [
                    Icon(
                      Icons.domain_verification,
                      size: 30,
                    )
                  ],
                ),
                const Gap(10),
                Row(
                  children: [
                    Text(
                      "Minggu ke - ${lecture.lecture!.weekID!}${lecture.lecture!.weekID! < 10 ? "  " : ""}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        data.add(
          SizedBox(
            height: 40,
            width: 40,
            child: TextButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(CircleBorder()),
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFFDC3545),
                ),
              ),
              onPressed: () {},
              child: Text(
                lecture.lecture!.lectureType!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
        data.add(const Gap(5));
      } else {
        data.add(
          SizedBox(
            height: 40,
            width: 40,
            child: TextButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(CircleBorder()),
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFFDC3545),
                ),
              ),
              onPressed: () {},
              child: Text(
                lecture.lecture!.lectureType!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
        data.add(const Gap(5));
      }
    }
  }

  return data;
}
