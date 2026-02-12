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
                child: ListView(
                  controller: ScrollController(),
                  scrollDirection: Axis.vertical,
                  children: const [
                    Gap(20),
                    Column(
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
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                              "Mohon maaf, tidak ada data yang dapat ditampilkan"),
                        )
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
              child: const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Column(
                      children: [
                        Gap(20),
                        Column(
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
                        Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                  "Mohon maaf, tidak ada data yang dapat ditampilkan"),
                            )
                          ],
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
                    color: assignment.jNilDesc == 'UTS' ||
                            assignment.jNilDesc == 'UAS'
                        ? Colors.amber
                        : Colors.lightBlue,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      side: BorderSide(
                          color: assignment.jNilDesc == 'UTS' ||
                                  assignment.jNilDesc == 'UAS'
                              ? Colors.amber
                              : Colors.lightBlue),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.85,
                            child: Text(
                              assignment.assignmentTitle,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Gap(20),
                          SizedBox(
                            width: screenWidth * 0.85,
                            child: Text(
                              "${assignment.subjectName} (${assignment.subjectClass}) - Minggu Ke ${assignment.weekId}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Gap(10),
                          SizedBox(
                            width: screenWidth * 0.85,
                            child: Text(
                              "${assignment.totalSubmited} mahasiswa telah mengumpulkan",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Gap(10),
                          SizedBox(
                            width: screenWidth * 0.85,
                            child: Text(
                              "Tenggat - ${DateFormat.yMd().add_Hm().format(assignment.dueDate)}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
