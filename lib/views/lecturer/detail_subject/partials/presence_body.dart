import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:intl/intl.dart';

class LecturePresenceBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;
  const LecturePresenceBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<LecturePresenceBody> createState() => _LecturePresenceBodyState();
}

class _LecturePresenceBodyState extends State<LecturePresenceBody> {
  // Subject? _subject;
  static const headerStyle =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyle = TextStyle(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();

    _checkLoad();
  }

  _checkLoad() async {
    bool loaded =
        await widget.userRepository.getWidgetState('lecturer_presence');
    if (!loaded) {
      setState(() {
        BlocProvider.of<LectureBloc>(context).add(GetLecture(
          academicPeriod: widget.subject.academicPeriodId,
          subjectId: widget.subject.subjectId,
          subjectClass: widget.subject.subjectClass,
        ));
      });
      await widget.userRepository.setWidgetState('lecturer_presence', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.8;

    return BlocConsumer<LectureBloc, LectureState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LectureLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Placeholder(
          color: const Color.fromRGBO(0, 0, 0, 0),
          child: RefreshIndicator(
            child: Accordion(
              maxOpenSections: 16,
              headerBorderColor: Colors.grey,
              headerBorderWidth: 1,
              headerBorderColorOpened: Colors.grey,
              headerBackgroundColorOpened: Colors.white,
              contentBackgroundColor: Colors.white,
              contentBorderColor: Colors.grey,
              contentBorderWidth: 1,
              contentHorizontalPadding: 20,
              scaleWhenAnimating: true,
              openAndCloseAnimation: true,
              headerPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
              sectionClosingHapticFeedback: SectionHapticFeedback.light,
              headerBackgroundColor: Colors.white,
              children: state is LectureLoaded
                  ? accordionList(
                      headerStyle,
                      state.lecturerLectures,
                      widget.subject,
                      contentStyle,
                      screenWidth,
                      context,
                    )
                  : accordionList(
                      headerStyle,
                      List<List<Lecture>>.empty(),
                      widget.subject,
                      contentStyle,
                      screenWidth,
                      context,
                    ),
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));

              setState(() {
                BlocProvider.of<LectureBloc>(context).add(GetLecture(
                  academicPeriod: widget.subject.academicPeriodId,
                  subjectId: widget.subject.subjectId,
                  subjectClass: widget.subject.subjectClass,
                ));
              });
            },
          ),
        );
      },
    );
  }
}

List<AccordionSection> accordionList(
    TextStyle headerStyle,
    List<List<Lecture>> lectures,
    Subject subject,
    TextStyle contentStyle,
    double screenWidth,
    context) {
  List<AccordionSection> accordions = List.empty(growable: true);

  for (var i = 0; i < 16; i++) {
    accordions.add(
      AccordionSection(
        isOpen: false,
        contentVerticalPadding: 10,
        leftIcon: const Icon(Icons.domain_verification_rounded,
            color: Colors.black, size: 30),
        rightIcon:
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
        header: Text("Minggu ke - ${i + 1}", style: headerStyle),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth,
              height: (58.0 *
                  (i == 7 || i == 15 ? 1 : subject.subjectSchedule.length)),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                              "[${subject.subjectSchedule[index]["subject_type"]}] ${_formatTime(subject.subjectSchedule[index]["time_start"])}-${_formatTime(subject.subjectSchedule[index]["time_end"])}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.5,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.red,
                                ),
                              ),
                              onPressed: () {
                                SubjectReport report = SubjectReport(
                                  subjectClass: subject.subjectClass,
                                  subjectCredits: subject.subjectCredits,
                                  subjectId: subject.subjectId,
                                  majorName: subject.majorName,
                                  majorId: subject.majorId,
                                  academicPeriodId: subject.academicPeriodId,
                                  lecturerId: subject.lecturerId,
                                  subjectName: subject.subjectName,
                                  totalStudent: subject.totalStudent,
                                  activityMasterId: subject.activityMasterId,
                                  lecturerName: subject.lecturerName,
                                  day: subject.subjectSchedule[index]["day"] ?? "",
                                  timeStart: subject.subjectSchedule[index]["time_start"] ?? "",
                                  timeEnd: subject.subjectSchedule[index]["time_end"] ?? "",
                                  hourId: subject.subjectSchedule[index]["hour_id"]?.toString() ?? "",
                                  collegeType: subject.subjectSchedule[index]["subject_type"] ?? "",
                                  roomId: subject.subjectSchedule[index]["subject_room"] ?? "",
                                );
                                Navigator.pushNamed(context, "/lecturer/college_report/detail", arguments: report);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Belum ada laporan pertemuan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount:
                    i == 7 || i == 15 ? 1 : subject.subjectSchedule.length,
              ),
            ),
          ],
        ),
        onOpenSection: () {},
      ),
    );
  }

  if (lectures.isNotEmpty) {
    for (var lecture in lectures) {
      accordions[lecture[0].weekID! - 1] = AccordionSection(
        isOpen: true,
        contentVerticalPadding: 10,
        leftIcon: const Icon(Icons.domain_verification_rounded,
            color: Colors.black, size: 30),
        rightIcon:
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
        header: Text("Minggu ke - ${lecture[0].weekID}", style: headerStyle),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth,
              height: (58.0 * lecture.length),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                              "[${subject.subjectSchedule[index]["subject_type"]}] ${_formatTime(subject.subjectSchedule[index]["time_start"])}-${_formatTime(subject.subjectSchedule[index]["time_end"])}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.5,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.amber,
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "${lecture[index].presenceStudent} Mahasiswa Sudah Presensi",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: lecture.length,
              ),
            ),
          ],
        ),
        onOpenSection: () {},
      );
    }
  }

  return accordions;
}

String _formatTime(String? time) {
  if (time == null || time.isEmpty) return "-";
  try {
    return time.split(":").take(2).join(":");
  } catch (e) {
    return time;
  }
}
