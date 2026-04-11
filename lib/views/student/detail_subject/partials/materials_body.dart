import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/study_achievement.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_achievement/study_achievement_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/assignments_body.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();

    _checkLoad();
  }

  _checkLoad() async {
    // Selalu load jika bloc belum dalam state Loaded
    final currentState = BlocProvider.of<StudyAchievementBloc>(context).state;
    print("DEBUG _checkLoad: state = $currentState");

    if (currentState is! StudyAchievementLoaded) {
      print("DEBUG _checkLoad: Triggering GetStudyAchievement...");
      setState(() {
        BlocProvider.of<StudyAchievementBloc>(context).add(GetStudyAchievement(
          academicPeriod: widget.subject.academicPeriodId,
          subjectId: widget.subject.subjectId,
          subjectClass: widget.subject.subjectClass,
        ));
      });
    } else {
      print("DEBUG _checkLoad: Already loaded, assignments count = ${currentState.assignments.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.84;

    return BlocConsumer<StudyAchievementBloc, StudyAchievementState>(
      listener: (context, state) {},
      builder: (context, state) {
        return RefreshIndicator(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: state is StudyAchievementLoaded
                  ? _buildWeeklyCards(
                      widget.userRepository,
                      state.lectureWeeks,
                      state.studyAchievements,
                      state.assignments,
                      widget.subject,
                      screenWidth,
                      context,
                    )
                  : _buildWeeklyCards(
                      widget.userRepository,
                      List<Lecture>.empty(),
                      List<StudyAchievement>.empty(),
                      List<Assignment>.empty(),
                      widget.subject,
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
                ));
              });
            });
      },
    );
  }
}

List<Widget> _buildWeeklyCards(
    UserRepository userRepository,
    List<Lecture> lectureWeeks,
    List<StudyAchievement> studyAchievements,
    List<Assignment> assignments,
    Subject subject,
    double screenWidth,
    context) {
  List<Widget> cards = List.empty(growable: true);

  List<Map<String, dynamic>> cardDataMappings = List.empty(growable: true);

  for (var i = 0; i < 16; i++) {
    var data = <String, dynamic>{};

    data["lectureWeek"] = null;
    data["studyAchievement"] = null;
    data["assignment"] = null;

    cardDataMappings.add(data);
    if (lectureWeeks.isNotEmpty) {
      for (var lectureWeek in lectureWeeks) {
        if (lectureWeek.weekID == (i + 1)) {
          cardDataMappings[i]["lectureWeek"] = lectureWeek;
        }
      }
    }
    if (studyAchievements.isNotEmpty) {
      for (var studyAchievement in studyAchievements) {
        if (studyAchievement.weekId == (i + 1)) {
          cardDataMappings[i]["studyAchievement"] = studyAchievement;
        }
      }
    }
    if (assignments.isNotEmpty) {
      for (var assignment in assignments) {
        if (assignment.weekId == (i + 1)) {
          cardDataMappings[i]["assignment"] = assignment;
        }
      }
    }
  }

  for (var mapping in cardDataMappings) {
    cards.add(_buildWeeklyCard(
      context,
      screenWidth,
      cardDataMappings.indexOf(mapping),
      userRepository,
      subject,
      mapping["studyAchievement"],
      mapping["assignment"],
      mapping["lectureWeek"],
    ));
  }

  return cards;
}

Widget _buildWeeklyCard(
    context,
    double screenWidth,
    int index,
    UserRepository userRepository,
    Subject subject,
    StudyAchievement? studyAchievement,
    Assignment? assignment,
    Lecture? lecture) {
  String weekStr = (index + 1).toString().padLeft(2, '0');

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade100, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04), // or withAlpha(10)
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: const Color(0xFF8692A6),
        collapsedIconColor: const Color(0xFF8692A6),
        title: Row(
          children: [
            Container(
              width: 44, // Slightly increased size
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0FE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  weekStr,
                  style: const TextStyle(
                    color: Color(0xFF1E5AD6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Back to normal font
                  ),
                ),
              ),
            ),
            const Gap(14),
            Text(
              "Minggu ke - ${index + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF222B45),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Capaian Pembelajaran
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "CAPAIAN PEMBELAJARAN",
              style: TextStyle(
                color: Color(0xFF8692A6),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Gap(6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              studyAchievement != null
                  ? studyAchievement.studyAchievementDescription
                  : 'Belum ada informasi',
              style: const TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const Gap(12),

          // Rencana Pembelajaran
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "RENCANA PEMBELAJARAN",
              style: TextStyle(
                color: Color(0xFF8692A6),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Gap(6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              studyAchievement != null
                  ? studyAchievement.studyPlanDescription
                  : 'Belum ada informasi',
              style: const TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const Gap(16),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Materi Button
                ElevatedButton.icon(
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
                            weekId: index + 1,
                          ),
                        );
                        return BlocConsumer<StudyMaterialBloc,
                            StudyMaterialState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            return SizedBox(
                              height: 200,
                              width: double.maxFinite,
                              child: state is StudyMaterialLoaded &&
                                      state.studyMaterials.isNotEmpty
                                  ? ListView.separated(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: state.studyMaterials.length,
                                      itemBuilder: (context, matIndex) {
                                        return SizedBox(
                                          width: screenWidth,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .file_present_rounded,
                                                        color:
                                                            Color(0xFF0072BB)),
                                                    const Gap(10),
                                                    Expanded(
                                                      child: Text(
                                                        state
                                                            .studyMaterials[
                                                                matIndex]
                                                            .materialTitle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  BlocProvider.of<LectureBloc>(
                                                          context)
                                                      .add(
                                                    DownloadMaterial(
                                                        fileLink: state
                                                            .studyMaterials[
                                                                matIndex]
                                                            .materialLink),
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons
                                                        .file_download_outlined,
                                                    color: Color(0xFF0072BB)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, i) =>
                                          const Divider(),
                                    )
                                  : const Center(
                                      child: Text(
                                          "Tidak ada materi yang dapat ditampilkan")),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text("Materi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5AD6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                // Tugas Button (only show if assignment exists)
                if (assignment != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.85,
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(
                                        top: 12, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Expanded(
                                    child: StudentAssignmentsBody(
                                      assignment: assignment,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.assignment_outlined, size: 18),
                    label: const Text("Tugas"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                // Hybrid Button (only show if it's NOT offline)
                if (lecture != null && lecture.collegeType != 1)
                  ElevatedButton.icon(
                    onPressed: lecture.linkMeet != null &&
                            lecture.linkMeet!.isNotEmpty
                        ? () => _launchInBrowser(Uri.parse(lecture.linkMeet!))
                        : null,
                    icon: const Icon(Icons.videocam, size: 18),
                    label: const Text("Hybrid"),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF9032EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                // Rekaman Button (only show if it's NOT offline and link exists)
                if (lecture != null &&
                    lecture.collegeType != 1 &&
                    lecture.linkRecord != null &&
                    lecture.linkRecord!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _launchInBrowser(Uri.parse(lecture.linkRecord!)),
                    icon: const Icon(Icons.play_circle_fill, size: 18),
                    label: const Text("Rekaman"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    ),
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
