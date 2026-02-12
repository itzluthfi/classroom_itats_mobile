import 'package:accordion/accordion.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/study_achievement.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_achievement/study_achievement_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:flutter/material.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentMaterialsBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const StudentMaterialsBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<StudentMaterialsBody> createState() => _StudentMaterialsBodyState();
}

class _StudentMaterialsBodyState extends State<StudentMaterialsBody> {
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
        await widget.userRepository.getWidgetState('student_material');
    if (!loaded) {
      setState(() {
        BlocProvider.of<StudyAchievementBloc>(context).add(GetStudyAchievement(
          academicPeriod: widget.subject.academicPeriodId,
          subjectId: widget.subject.subjectId,
          subjectClass: widget.subject.subjectClass,
          masterActivityId: widget.subject.activityMasterId,
        ));
      });
      await widget.userRepository.setWidgetState('student_material', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.84;

    return BlocConsumer<StudyAchievementBloc, StudyAchievementState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Placeholder(
          color: const Color.fromRGBO(0, 0, 0, 0),
          child: RefreshIndicator(
              child: Accordion(
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
                children: state is StudyAchievementLoaded
                    ? _accordionList(
                        widget.userRepository,
                        headerStyle,
                        state.lectureWeeks,
                        state.studyAchievements,
                        state.assignments,
                        widget.subject,
                        contentStyle,
                        screenWidth,
                        context,
                      )
                    : _accordionList(
                        widget.userRepository,
                        headerStyle,
                        List<Lecture>.empty(),
                        List<StudyAchievement>.empty(),
                        List<Assignment>.empty(),
                        widget.subject,
                        contentStyle,
                        screenWidth,
                        context,
                      ),
              ),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                setState(() {
                  BlocProvider.of<StudyAchievementBloc>(context)
                      .add(GetStudyAchievement(
                    academicPeriod: widget.subject.academicPeriodId,
                    subjectId: widget.subject.subjectId,
                    subjectClass: widget.subject.subjectClass,
                    masterActivityId: widget.subject.activityMasterId,
                  ));
                });
              }),
        );
      },
    );
  }
}

List<AccordionSection> _accordionList(
    UserRepository userRepository,
    TextStyle headerStyle,
    List<Lecture> lectureWeeks,
    List<StudyAchievement> studyAchievements,
    List<Assignment> assignments,
    Subject subject,
    TextStyle contentStyle,
    double screenWidth,
    context) {
  List<AccordionSection> accordions = List.empty(growable: true);

  List<Map<String, dynamic>> accordionDataMappings = List.empty(growable: true);

  for (var i = 0; i < 16; i++) {
    var data = <String, dynamic>{};

    data["lectureWeek"] = null;
    data["studyAchievement"] = null;
    data["assignment"] = null;

    accordionDataMappings.add(data);
    if (lectureWeeks.isNotEmpty) {
      for (var lectureWeek in lectureWeeks) {
        if (lectureWeek.weekID == (i + 1)) {
          accordionDataMappings[i]["lectureWeek"] = lectureWeek;
        }
      }
    }
    if (studyAchievements.isNotEmpty) {
      for (var studyAchievement in studyAchievements) {
        if (studyAchievement.weekId == (i + 1)) {
          accordionDataMappings[i]["studyAchievement"] = studyAchievement;
        }
      }
    }
    if (assignments.isNotEmpty) {
      for (var assignment in assignments) {
        if (assignment.weekId == (i + 1)) {
          accordionDataMappings[i]["assignment"] = assignment;
        }
      }
    }
  }

  for (var accordionDataMapping in accordionDataMappings) {
    accordions.add(_accordionSection(
        context,
        screenWidth,
        accordionDataMappings.indexOf(accordionDataMapping),
        headerStyle,
        contentStyle,
        userRepository,
        subject,
        accordionDataMapping["studyAchievement"],
        accordionDataMapping["assignment"],
        accordionDataMapping["lectureWeek"]));
  }

  return accordions;
}

AccordionSection _accordionSection(
    context,
    double screenWidth,
    int index,
    TextStyle headerStyle,
    TextStyle contentStyle,
    UserRepository userRepository,
    Subject subject,
    StudyAchievement? studyAchievement,
    Assignment? assignment,
    Lecture? lecture) {
  return AccordionSection(
    isOpen: false,
    contentVerticalPadding: 20,
    leftIcon: const Icon(Icons.assignment, color: Colors.black),
    rightIcon:
        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
    header: Text("Minggu ke - ${index + 1}", style: headerStyle),
    content: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.95,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Capaian Pembelajaran :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      lecture != null
                          ? Column(
                              children: [
                                const Gap(8),
                                Badge(
                                  label: Text(lecture.collegeType == 1
                                      ? 'offline'
                                      : 'hybrid'),
                                  backgroundColor: Colors.blueAccent,
                                )
                              ],
                            )
                          : const Column(),
                    ],
                  ),
                ),
                const Gap(5),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.95,
                      child: Text(
                        studyAchievement != null
                            ? studyAchievement.studyAchievementDescription
                            : 'Belum ada informasi',
                        maxLines: 3,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Gap(10),
        const Row(
          children: [
            Text(
              "Rencana Pembelajaran :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(5),
        Row(
          children: [
            Text(
              studyAchievement != null
                  ? studyAchievement.studyPlanDescription
                  : 'Belum ada informasi',
              maxLines: 3,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lecture != null
                ? lecture.linkMeet != ''
                    ? Column(
                        children: [
                          const Gap(10),
                          const Row(
                            children: [
                              Text(
                                "Link Meet :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _launchInBrowser(
                                      Uri.parse(lecture.linkMeet!));
                                },
                                style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.white,
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: const Size(90, 10),
                                ),
                                icon: const Icon(
                                  Icons.video_camera_front_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Gap(5)
                : const Gap(5),
            lecture != null
                ? lecture.linkRecord != ''
                    ? Column(
                        children: [
                          const Gap(15),
                          const Row(
                            children: [
                              Text(
                                "Link Record :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _launchInBrowser(
                                      Uri.parse(lecture.linkRecord!));
                                },
                                style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: const Size(90, 10),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : const Gap(5)
                : const Gap(5),
          ],
        ),
        const Gap(15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            lecture != null
                ? Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          backgroundColor: const Color(0xFF0072BB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            useSafeArea: true,
                            showDragHandle: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              BlocProvider.of<StudyMaterialBloc>(context).add(
                                GetStudyMaterial(
                                  academicPeriod: subject.academicPeriodId,
                                  subjectId: subject.subjectId,
                                  subjectClass: subject.subjectClass,
                                  weekId: lecture.weekID!,
                                ),
                              );
                              return BlocConsumer<StudyMaterialBloc,
                                  StudyMaterialState>(
                                listener: (context, state) {},
                                builder: (context, state) {
                                  return SizedBox(
                                    height: 200,
                                    width: double.maxFinite,
                                    child:
                                        state is StudyMaterialLoaded &&
                                                state.studyMaterials.isNotEmpty
                                            ? ListView.separated(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                scrollDirection: Axis.vertical,
                                                itemCount:
                                                    state.studyMaterials.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    width: screenWidth,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(Icons
                                                                        .file_present_rounded),
                                                                    const Gap(
                                                                        10),
                                                                    SizedBox(
                                                                      width:
                                                                          screenWidth *
                                                                              0.8,
                                                                      child:
                                                                          Text(
                                                                        state
                                                                            .studyMaterials[index]
                                                                            .materialTitle,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    BlocProvider.of<LectureBloc>(
                                                                            context)
                                                                        .add(
                                                                      DownloadMaterial(
                                                                          fileLink: state
                                                                              .studyMaterials[index]
                                                                              .materialLink),
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .file_download_outlined),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                            int index) =>
                                                        const Divider(),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                          "Tidak ada materi yang dapat ditampilkan"),
                                                    ],
                                                  )
                                                ],
                                              ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: const Text("Materi"),
                      )
                    ],
                  )
                : const Column(),
            assignment != null
                ? Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await userRepository.setWidgetState(
                              "student_material", false);
                          await userRepository.setWidgetState("forum", false);
                          await userRepository.setWidgetState(
                              "student_presence", false);
                          await userRepository.setWidgetState(
                              "student_score_recap", false);
                          await userRepository.setWidgetState(
                              "subject_member", false);

                          List<Object?> object = List.empty(growable: true);

                          object.add(subject);
                          object.add(assignment);

                          Navigator.of(context).pushReplacementNamed(
                              "/student/assignments",
                              arguments: List<Object>.from(object));
                        },
                        child: const Text("Tugas"),
                      ),
                    ],
                  )
                : const Column(),
          ],
        ),
        const Gap(10),
      ],
    ),
    onOpenSection: () {},
  );
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

// List<Widget> _contentAccordion(
//     context,
//     UserRepository userRepository,
//     List<Widget> before,
//     StudyAchievement? studyAchievement,
//     Assignment? assignment,
//     Subject subject,
//     double screenWidth,
//     bool isMaterial,
//     bool isAssignment) {
//   List<Widget> data = before;

//   if (isMaterial) {
//     if (before.isEmpty) {
//       data.add(
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     surfaceTintColor: Colors.white,
//                     backgroundColor: const Color(0xFF0072BB),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     showModalBottomSheet<void>(
//                       useSafeArea: true,
//                       showDragHandle: true,
//                       isScrollControlled: true,
//                       context: context,
//                       builder: (BuildContext context) {
//                         BlocProvider.of<StudyMaterialBloc>(context).add(
//                           GetStudyMaterial(
//                             academicPeriod: subject.academicPeriodId,
//                             subjectId: subject.subjectId,
//                             subjectClass: subject.subjectClass,
//                             weekId: studyAchievement!.weekId,
//                           ),
//                         );
//                         return BlocConsumer<StudyMaterialBloc,
//                             StudyMaterialState>(
//                           listener: (context, state) {},
//                           builder: (context, state) {
//                             return SizedBox(
//                               height: 200,
//                               width: double.maxFinite,
//                               child: state is StudyMaterialLoaded &&
//                                       state.studyMaterials.isNotEmpty
//                                   ? ListView.separated(
//                                       padding: const EdgeInsets.all(20),
//                                       scrollDirection: Axis.vertical,
//                                       itemCount: state.studyMaterials.length,
//                                       itemBuilder: (context, index) {
//                                         return SizedBox(
//                                           width: screenWidth,
//                                           child: Column(
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Column(
//                                                     children: [
//                                                       Row(
//                                                         children: [
//                                                           const Column(
//                                                             children: [
//                                                               Icon(Icons
//                                                                   .file_present_rounded),
//                                                             ],
//                                                           ),
//                                                           const Gap(10),
//                                                           Column(
//                                                             children: [
//                                                               Text(state
//                                                                   .studyMaterials[
//                                                                       index]
//                                                                   .materialTitle),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       )
//                                                     ],
//                                                   ),
//                                                   Column(
//                                                     children: [
//                                                       IconButton(
//                                                         onPressed: () {
//                                                           BlocProvider.of<
//                                                                       LectureBloc>(
//                                                                   context)
//                                                               .add(
//                                                             DownloadMaterial(
//                                                                 fileLink: state
//                                                                     .studyMaterials[
//                                                                         index]
//                                                                     .materialLink),
//                                                           );
//                                                         },
//                                                         icon: const Icon(Icons
//                                                             .file_download_outlined),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                       separatorBuilder:
//                                           (BuildContext context, int index) =>
//                                               const Divider(),
//                                     )
//                                   : const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Column(
//                                           children: [
//                                             Text(
//                                                 "Tidak ada materi yang dapat ditampilkan"),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                   child: const Text("Materi"),
//                 )
//               ],
//             ),
//           ],
//         ),
//       );
//     } else {
//       data.add(
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     surfaceTintColor: Colors.white,
//                     backgroundColor: const Color(0xFF0072BB),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     showModalBottomSheet<void>(
//                       useSafeArea: true,
//                       showDragHandle: true,
//                       isScrollControlled: true,
//                       context: context,
//                       builder: (BuildContext context) {
//                         BlocProvider.of<StudyMaterialBloc>(context).add(
//                           GetStudyMaterial(
//                             academicPeriod: subject.academicPeriodId,
//                             subjectId: subject.subjectId,
//                             subjectClass: subject.subjectClass,
//                             weekId: studyAchievement!.weekId,
//                           ),
//                         );
//                         return BlocConsumer<StudyMaterialBloc,
//                             StudyMaterialState>(
//                           listener: (context, state) {},
//                           builder: (context, state) {
//                             return SizedBox(
//                               height: 200,
//                               width: double.maxFinite,
//                               child: state is StudyMaterialLoaded &&
//                                       state.studyMaterials.isNotEmpty
//                                   ? ListView.separated(
//                                       padding: const EdgeInsets.all(20),
//                                       scrollDirection: Axis.vertical,
//                                       itemCount: state.studyMaterials.length,
//                                       itemBuilder: (context, index) {
//                                         return SizedBox(
//                                           width: screenWidth,
//                                           child: Column(
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Column(
//                                                     children: [
//                                                       Row(
//                                                         children: [
//                                                           const Column(
//                                                             children: [
//                                                               Icon(Icons
//                                                                   .file_present_rounded),
//                                                             ],
//                                                           ),
//                                                           const Gap(10),
//                                                           Column(
//                                                             children: [
//                                                               Text(state
//                                                                   .studyMaterials[
//                                                                       index]
//                                                                   .materialTitle),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       )
//                                                     ],
//                                                   ),
//                                                   Column(
//                                                     children: [
//                                                       IconButton(
//                                                         onPressed: () {
//                                                           BlocProvider.of<
//                                                                       LectureBloc>(
//                                                                   context)
//                                                               .add(
//                                                             DownloadMaterial(
//                                                                 fileLink: state
//                                                                     .studyMaterials[
//                                                                         index]
//                                                                     .materialLink),
//                                                           );
//                                                         },
//                                                         icon: const Icon(Icons
//                                                             .file_download_outlined),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                       separatorBuilder:
//                                           (BuildContext context, int index) =>
//                                               const Divider(),
//                                     )
//                                   : const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Column(
//                                           children: [
//                                             Text(
//                                                 "Tidak ada materi yang dapat ditampilkan"),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                   child: const Text("Materi"),
//                 )
//               ],
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   if (isAssignment) {
//     if (before.isEmpty) {
//       data.add(const Column());
//       data.add(
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             surfaceTintColor: Colors.white,
//             backgroundColor: Colors.deepOrange,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onPressed: () async {
//             await userRepository.setWidgetState("student_material", false);
//             await userRepository.setWidgetState("forum", false);
//             await userRepository.setWidgetState("student_presence", false);
//             await userRepository.setWidgetState("student_score_recap", false);
//             await userRepository.setWidgetState("subject_member", false);
//             List<Object?> object = List.empty(growable: true);

//             object.add(subject);
//             object.add(assignment!);

//             Navigator.of(context).pushReplacementNamed("/student/assignments",
//                 arguments: object);
//           },
//           child: const Text("Tugas"),
//         ),
//       );
//     } else {
//       data.add(
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             surfaceTintColor: Colors.white,
//             backgroundColor: Colors.deepOrange,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onPressed: () async {
//             await userRepository.setWidgetState("student_material", false);
//             await userRepository.setWidgetState("forum", false);
//             await userRepository.setWidgetState("student_presence", false);
//             await userRepository.setWidgetState("student_score_recap", false);
//             await userRepository.setWidgetState("subject_member", false);

//             List<Object?> object = List.empty(growable: true);

//             object.add(subject);
//             object.add(assignment!);

//             Navigator.of(context).pushReplacementNamed("/student/assignments",
//                 arguments: List<Object>.from(object));
//           },
//           child: const Text("Tugas"),
//         ),
//       );
//     }
//   }

//   return data;
// }

// List<AccordionSection> _accordionList(
//     UserRepository userRepository,
//     TextStyle headerStyle,
//     List<StudyAchievement> studyAchievements,
//     List<Assignment> assignments,
//     Subject subject,
//     TextStyle contentStyle,
//     double screenWidth,
//     context) {
//   List<AccordionSection> accordions = List.empty(growable: true);

//   for (var i = 0; i < 16; i++) {
//     accordions.add(
//       AccordionSection(
//         isOpen: false,
//         contentVerticalPadding: 20,
//         leftIcon: const Icon(Icons.assignment, color: Colors.black),
//         rightIcon:
//             const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
//         header: Text("Minggu ke - ${i + 1}", style: headerStyle),
//         content: const Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Capaian Pembelajaran :",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             Gap(10),
//             Row(
//               children: [
//                 Text(
//                   "Rencana Pembelajaran :",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             Gap(10),
//           ],
//         ),
//         onOpenSection: () {},
//       ),
//     );
//     if (studyAchievements.isNotEmpty) {
//       for (var studyAchievement in studyAchievements) {
//         List<Widget> before = List.empty(growable: true);
//         if (studyAchievement.weekId == i + 1) {
//           before = _contentAccordion(context, userRepository, before,
//               studyAchievement, null, subject, screenWidth, true, false);
//           accordions[i] = AccordionSection(
//             isOpen: false,
//             contentVerticalPadding: 20,
//             leftIcon: const Icon(Icons.assignment, color: Colors.black),
//             rightIcon: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: Colors.black),
//             header: Text("Minggu ke - ${studyAchievement.weekId}",
//                 style: headerStyle),
//             content: Column(
//               children: [
//                 Row(
//                   children: [
//                     Column(
//                       children: [
//                         const Row(
//                           children: [
//                             Text(
//                               "Capaian Pembelajaran :",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Gap(5),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: screenWidth * 0.95,
//                               child: Text(
//                                 studyAchievement.studyAchievementDescription,
//                                 maxLines: 3,
//                                 textAlign: TextAlign.justify,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Badge(
//                           label: Text(studyAchievement.collegeType == 1
//                               ? 'offline'
//                               : 'hybrid'),
//                           backgroundColor: Colors.blueAccent,
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//                 const Gap(10),
//                 const Row(
//                   children: [
//                     Text(
//                       "Rencana Pembelajaran :",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Gap(5),
//                 Row(
//                   children: [
//                     Text(
//                       studyAchievement.studyPlanDescription,
//                       maxLines: 3,
//                     ),
//                   ],
//                 ),
//                 studyAchievement.linkMeet != ''
//                     ? Column(
//                         children: [
//                           const Gap(10),
//                           const Row(
//                             children: [
//                               Text(
//                                 "Link Meet :",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const Gap(5),
//                           Row(
//                             children: [
//                               Text(
//                                 studyAchievement.studyPlanDescription,
//                                 maxLines: 3,
//                               ),
//                             ],
//                           ),
//                           const Gap(20)
//                         ],
//                       )
//                     : const Gap(20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: before,
//                 )
//               ],
//             ),
//           );
//           if (assignments.isNotEmpty) {
//             for (var assignment in assignments) {
//               if (assignment.weekId == studyAchievement.weekId) {
//                 accordions[i] = AccordionSection(
//                   isOpen: false,
//                   contentVerticalPadding: 20,
//                   leftIcon: const Icon(Icons.assignment, color: Colors.black),
//                   rightIcon: const Icon(Icons.keyboard_arrow_down_rounded,
//                       color: Colors.black),
//                   header: Text("Minggu ke - ${assignment.weekId}",
//                       style: headerStyle),
//                   content: Column(
//                     children: [
//                       const Row(
//                         children: [
//                           Text(
//                             "Capaian Pembelajaran :",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Gap(5),
//                       Row(
//                         children: [
//                           SizedBox(
//                             width: screenWidth * 0.95,
//                             child: Text(
//                               studyAchievement.studyAchievementDescription,
//                               maxLines: 3,
//                               textAlign: TextAlign.justify,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Gap(10),
//                       const Row(
//                         children: [
//                           Text(
//                             "Rencana Pembelajaran :",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Gap(5),
//                       Row(
//                         children: [
//                           Text(
//                             studyAchievement.studyPlanDescription,
//                             maxLines: 3,
//                           ),
//                         ],
//                       ),
//                       const Gap(20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: _contentAccordion(
//                             context,
//                             userRepository,
//                             before,
//                             null,
//                             assignment,
//                             subject,
//                             screenWidth,
//                             false,
//                             true),
//                       )
//                     ],
//                   ),
//                 );

//                 assignments = assignments
//                     .where((element) => element.weekId != i + 1)
//                     .toList();

//                 break;
//               }
//             }
//           }
//           break;
//         }
//       }
//     }
//     if (assignments.isNotEmpty) {
//       for (var assignment in assignments) {
//         List<Widget> before = List.empty(growable: true);
//         if (assignment.weekId == i + 1) {
//           accordions[i] = AccordionSection(
//             isOpen: false,
//             contentVerticalPadding: 20,
//             leftIcon: const Icon(Icons.assignment, color: Colors.black),
//             rightIcon: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: Colors.black),
//             header:
//                 Text("Minggu ke - ${assignment.weekId}", style: headerStyle),
//             content: Column(
//               children: [
//                 const Row(
//                   children: [
//                     Text(
//                       "Capaian Pembelajaran :",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Gap(5),
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: screenWidth * 0.95,
//                       child: const Text(
//                         "",
//                         maxLines: 3,
//                         textAlign: TextAlign.justify,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Gap(10),
//                 const Row(
//                   children: [
//                     Text(
//                       "Rencana Pembelajaran :",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Gap(5),
//                 const Row(
//                   children: [
//                     Text(
//                       "",
//                       maxLines: 3,
//                     ),
//                   ],
//                 ),
//                 const Gap(20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: _contentAccordion(context, userRepository, before,
//                       null, assignment, subject, screenWidth, false, true),
//                 )
//               ],
//             ),
//           );
//           break;
//         }
//       }
//     }
//   }

//   return accordions;
// }

// showModalBottomSheet<void>(
//   useSafeArea: true,
//   showDragHandle: true,
//   isScrollControlled: true,
//   context: context,
//   builder: (BuildContext context) {
//     BlocProvider.of<AssignmentBloc>(context).add(
//         GetStudentSubmitedAssignment(
//             assignmentId: assignment!.assignmentId));
//     return BlocConsumer<AssignmentBloc, AssignmentState>(
//       listener: (context, state) {},
//       builder: (context, state) {
//         return SizedBox(
//           height: double.maxFinite,
//           width: double.maxFinite,
//           child: Center(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             assignment.assignmentTitle,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             "tenggat: ${DateFormat(
//                               "EEEE, d/M/y H:m",
//                               "id_ID",
//                             ).format(
//                               assignment.dueDate,
//                             )}",
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 400,
//                   width: double.maxFinite,
//                   child: ListView(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 20),
//                     children: [
//                       Text(
//                         assignment.description,
//                         textAlign: TextAlign.justify,
//                         maxLines: 10,
//                       ),
//                       const Gap(20),
//                       Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                         children: [
//                           assignment.fileLink != "" &&
//                                   assignment.fileName != ""
//                               ? Column(
//                                   children: [
//                                     ElevatedButton(
//                                       style:
//                                           ElevatedButton.styleFrom(
//                                         surfaceTintColor:
//                                             Colors.white,
//                                         backgroundColor:
//                                             const Color(0xFF0072BB),
//                                         foregroundColor:
//                                             Colors.white,
//                                         shape:
//                                             RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(
//                                                   10),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         BlocProvider.of<
//                                                     AssignmentBloc>(
//                                                 context)
//                                             .add(
//                                           DownloadAssignment(
//                                               fileLink: assignment
//                                                   .fileLink,
//                                               fileName: assignment
//                                                   .fileName),
//                                         );
//                                         BlocProvider.of<
//                                             AssignmentBloc>(context)
//                                           ..add(
//                                             DownloadAssignment(
//                                                 fileLink: assignment
//                                                     .fileLink,
//                                                 fileName: assignment
//                                                     .fileName),
//                                           )
//                                           ..add(GetStudentSubmitedAssignment(
//                                               assignmentId: assignment
//                                                   .assignmentId));
//                                       },
//                                       child: const Text(
//                                           "Download File Tugas"),
//                                     ),
//                                   ],
//                                 )
//                               : const Column(),
//                           Column(
//                             children: [
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   surfaceTintColor: Colors.white,
//                                   backgroundColor: Colors.amber,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   showDialog<String>(
//                                     context: context,
//                                     builder:
//                                         (BuildContext context) =>
//                                             UploadAssignmentBody(
//                                       screenWidth: screenWidth,
//                                       assignment: assignment,
//                                     ),
//                                   );
//                                 },
//                                 child: const Text("Upload Tugas"),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const Gap(10),
//                       state is AssignmentLoaded &&
//                               state.studentAssignmentSubmission !=
//                                   null
//                           ? Row(
//                               mainAxisAlignment:
//                                   MainAxisAlignment.center,
//                               children: [
//                                 Column(
//                                   children: [
//                                     ElevatedButton(
//                                       style:
//                                           ElevatedButton.styleFrom(
//                                         surfaceTintColor:
//                                             Colors.white,
//                                         backgroundColor:
//                                             Colors.green,
//                                         foregroundColor:
//                                             Colors.white,
//                                         shape:
//                                             RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(
//                                                   10),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         BlocProvider.of<
//                                                     AssignmentBloc>(
//                                                 context)
//                                             .add(
//                                           DownloadStudentAssignmentSubmission(
//                                               fileLink: state
//                                                   .studentAssignmentSubmission!
//                                                   .assignmentLink,
//                                               fileName: state
//                                                   .studentAssignmentSubmission!
//                                                   .assignmentFile),
//                                         );
//                                         BlocProvider.of<
//                                                     AssignmentBloc>(
//                                                 context)
//                                             .add(GetStudentSubmitedAssignment(
//                                                 assignmentId: assignment
//                                                     .assignmentId));
//                                       },
//                                       child: const Text(
//                                           "Download Tugas Disubmit"),
//                                     ),
//                                     Text(
//                                         "Dikumpulkan Pada ${DateFormat(
//                                       "EEEE, d/M/y H:m",
//                                       "id_ID",
//                                     ).format(state.studentAssignmentSubmission!.createdAt)}"),
//                                     Text(
//                                       assignment.dueDate.compareTo(state
//                                                   .studentAssignmentSubmission!
//                                                   .createdAt) ==
//                                               -1
//                                           ? "Terlambat"
//                                           : "",
//                                       style: const TextStyle(
//                                         color: Colors.red,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             )
//                           : const Row(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   },
// );
