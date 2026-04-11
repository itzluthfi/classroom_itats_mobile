import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class LecturerAssignmentBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerAssignmentBody({
    super.key,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  @override
  State<LecturerAssignmentBody> createState() => _LecturerAssignmentBodyState();
}

class _LecturerAssignmentBodyState extends State<LecturerAssignmentBody> {
  String? _currentAcademicPeriod;
  // String? _activeAcademicPeriod;
  // String? _major;

  @override
  void initState() {
    super.initState();
    _getAcademicPeriod().then((value) =>
        BlocProvider.of<AssignmentBloc>(context).add(GetLecturerAssignment(
            academicPeriodId: _currentAcademicPeriod ?? "")));
  }

  Future _getAcademicPeriod() async {
    var current =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    // var active =
    //     await widget.academicPeriodRepository.getActiveAcademicPeriod();
    setState(() {
      _currentAcademicPeriod = current;
      // _activeAcademicPeriod = active;
    });
    // widget.academicPeriodRepository.getCurrentAcademicPeriod().then((value) {
    //   _currentAcademicPeriod = value;
    // });
    // widget.academicPeriodRepository.getActiveAcademicPeriod().then((value) {
    //   _activeAcademicPeriod = value;
    // });
  }

  // Future _getMajor() async {
  //   var major = await widget.majorRepository.getlecturerMajor();
  //   setState(() {
  //     _major = major;
  //   });
  //   // widget.majorRepository.getlecturerMajor().then((value) {
  //   //   _major = value;
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.95;

    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is AssignmentLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AssignmentLoaded) {
          if (state.assignments.isEmpty) {
            return Placeholder(
              color: Colors.transparent,
              child: RefreshIndicator(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const Gap(20),
                          const Text(
                            "Tugas Dibuat",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.snippet_folder_rounded, size: 80, color: Colors.grey),
                                Gap(16),
                                Text(
                                  "Mohon maaf, tidak ada tugas yang dapat ditampilkan",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onRefresh: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));

                  setState(() {
                    _getAcademicPeriod().then((value) =>
                        BlocProvider.of<AssignmentBloc>(context).add(
                            GetLecturerAssignment(
                                academicPeriodId:
                                    _currentAcademicPeriod ?? "")));
                  });
                },
              ),
            );
          } else {
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
                          "Tugas Dibuat",
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
                      children: [
                        Column(
                          children: _assignment(state.assignments, screenWidth),
                        ),
                      ],
                    ),
                  ],
                ),
                onRefresh: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));

                  setState(() {
                    _getAcademicPeriod().then((value) =>
                        BlocProvider.of<AssignmentBloc>(context).add(
                            GetLecturerAssignment(
                                academicPeriodId:
                                    _currentAcademicPeriod ?? "")));
                  });
                },
              ),
            );
          }
        } else if (state is AssignmentLoadFailed) {
          return Placeholder(
            color: Colors.transparent,
            child: RefreshIndicator(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const Gap(20),
                        const Text(
                          "Tugas Dibuat",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error_outline_rounded, size: 80, color: Colors.grey),
                              Gap(16),
                              Text(
                                "Gagal memuat tugas, silakan coba lagi.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));

                setState(() {
                  _getAcademicPeriod().then((value) =>
                      BlocProvider.of<AssignmentBloc>(context).add(
                          GetLecturerAssignment(
                              academicPeriodId: _currentAcademicPeriod ?? "")));
                });
              },
            ),
          );
        } else {
          return Center(
            child: RefreshIndicator(
              child: const CircularProgressIndicator(),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));

                setState(() {
                  _getAcademicPeriod().then((value) =>
                      BlocProvider.of<AssignmentBloc>(context).add(
                          GetLecturerAssignment(
                              academicPeriodId: _currentAcademicPeriod ?? "")));
                });
              },
            ),
          );
        }
      },
    );
  }
}

List<Widget> _assignment(List<Assignment> assignments, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var assignment in assignments) {
    scores.add(
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           assignment.subjectName,
                           style: const TextStyle(
                             color: Color(0xFF3B82F6),
                             fontSize: 12,
                             fontWeight: FontWeight.w700,
                             letterSpacing: 0.5,
                           ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                         const Gap(4),
                         Text(
                           assignment.assignmentTitle,
                           style: const TextStyle(
                             color: Color(0xFF0F172A),
                             fontSize: 16,
                             fontWeight: FontWeight.w800,
                             height: 1.3,
                           ),
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),
                   const Gap(8),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         "Minggu ${assignment.weekId}",
                         style: TextStyle(
                           color: Colors.grey.shade500,
                           fontSize: 12,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       const Gap(4),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: assignment.jNilDesc == 'UTS' || assignment.jNilDesc == 'UAS' ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           assignment.jNilDesc,
                           style: TextStyle(
                             fontSize: 10,
                             fontWeight: FontWeight.w800,
                             color: assignment.jNilDesc == 'UTS' || assignment.jNilDesc == 'UAS' ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                             letterSpacing: 0.5,
                           ),
                         ),
                       ),
                     ]
                   ),
                ]
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13, color: Colors.grey.shade500),
                  const Gap(4),
                  Text(
                    "Tenggat: ${DateFormat("d MMM y, HH:mm").format(assignment.dueDate)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(12),
                  Icon(Icons.bookmark_border, size: 13, color: Colors.grey.shade500),
                  const Gap(4),
                  Text(
                    "Kelas: ${assignment.subjectClass}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt, color: Color(0xFF64748B), size: 16),
                    const Gap(8),
                    Text(
                      "${assignment.totalSubmited} mahasiswa telah mengumpulkan",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  return scores;
}
