import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class LecturerDetailCollegeReport extends StatefulWidget {
  final SubjectReport subject;
  const LecturerDetailCollegeReport({super.key, required this.subject});

  @override
  State<LecturerDetailCollegeReport> createState() =>
      _LecturerDetailCollegeReportState();
}

class _LecturerDetailCollegeReportState
    extends State<LecturerDetailCollegeReport> {
  @override
  void initState() {
    super.initState();

    _getLecture();
  }

  _getLecture() async {
    setState(() {
      BlocProvider.of<LectureBloc>(context).add(GetLectureReport(
        subjectId: widget.subject.subjectId,
        subjectClass: widget.subject.subjectClass,
        hourId: widget.subject.hourId,
        collegeType: widget.subject.collegeType,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.95;
    double screenHeight = MediaQuery.of(context).size.height * 0.95;

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
                      "Daftar Pelaporan Kuliah",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                // Row(
                //   children: [
                //     SizedBox(
                //       width: screenWidth,
                //       child: Container(
                //         decoration: const BoxDecoration(
                //           borderRadius: BorderRadius.all(
                //             Radius.circular(10),
                //           ),
                //         ),
                //         width: screenWidth,
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.end,
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           children: [
                //             ElevatedButton(
                //               onPressed: () {},
                //               style: ElevatedButton.styleFrom(
                //                 padding: const EdgeInsets.all(5),
                //                 surfaceTintColor: Colors.white,
                //                 backgroundColor: const Color(0xFF0072BB),
                //                 foregroundColor: Colors.white,
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(10),
                //                 ),
                //                 fixedSize: const Size.fromWidth(120),
                //               ),
                //               child: const Text("Tambah"),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getSubject(context, state, widget.subject,
                      screenWidth, screenHeight),
                ),
                const Gap(80),
              ],
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));

              setState(() {
                BlocProvider.of<LectureBloc>(context).add(GetLectureReport(
                  subjectId: widget.subject.subjectId,
                  subjectClass: widget.subject.subjectClass,
                  hourId: widget.subject.hourId,
                  collegeType: widget.subject.collegeType,
                ));
              });
            },
          ),
        );
      },
    );
  }
}

List<Widget> _getSubject(context, state, SubjectReport subject,
    double screenWidth, double screenHeight) {
  if (state is LectureLoading) {
    return [
      const Center(
        child: CircularProgressIndicator(),
      ),
    ];
  } else if (state is LectureLoaded) {
    if (state.lectureReports.isEmpty) {
      return [
        SizedBox(
          width: screenWidth,
          height: screenHeight * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.snippet_folder_rounded, size: 80, color: Colors.grey),
              Gap(16),
              Text(
                "Mohon maaf, belum ada laporan kuliah untuk kelas ini.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        )
      ];
    }
    return [
      Column(
        children: _subject(context, state.lectureReports, subject, screenWidth),
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
            Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey),
            Gap(16),
            Text(
              "Mohon maaf, tidak ada data rincian pelaporan yang dapat ditampilkan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  }
}

List<Widget> _subject(context, List<Lecture> lectures, SubjectReport subject,
    double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var lecture in lectures) {
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
                                  "Minggu Ke - ${lecture.weekID!}",
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Gap(5),
                              lecture.presenceStudent != 0
                                  ? SizedBox(
                                      width: screenWidth * 0.8,
                                      child: Text(
                                        "[${subject.collegeType}] ${subject.subjectName} - ${subject.subjectClass}",
                                        maxLines: 2,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: screenWidth * 0.6,
                                      child: Text(
                                        "[${subject.collegeType}] ${subject.subjectName} - ${subject.subjectClass}",
                                        maxLines: 2,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              const Gap(5),
                              lecture.presenceStudent != 0
                                  ? SizedBox(
                                      width: screenWidth * 0.8,
                                      child: Text(
                                        "${DateFormat("EEE, MMM d, yyyy").format(lecture.lectureSchedule!)} ${subject.timeStart} - ${subject.timeEnd}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: screenWidth * 0.5,
                                      child: Text(
                                        "${DateFormat("EEE, MMM d, yyyy").format(lecture.lectureSchedule!)} ${subject.timeStart} - ${subject.timeEnd}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                          lecture.presenceStudent == 0
                              ? SizedBox(
                                  width: screenWidth * 0.25,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              "/lecturer/college_report/edit",
                                              arguments: <String, Object>{
                                                "subject": subject,
                                                "lecture": lecture,
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          surfaceTintColor: Colors.white,
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Icon(Icons.edit),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          BlocProvider.of<LectureBloc>(context)
                                              .add(GetLectureReport(
                                            subjectId: subject.subjectId,
                                            subjectClass: subject.subjectClass,
                                            hourId: subject.hourId,
                                            collegeType: subject.collegeType,
                                          ));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          surfaceTintColor: Colors.white,
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  width: screenWidth * 0.05,
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
