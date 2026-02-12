import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/list_subject/list_subject_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LecturerSubjectScoreBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerSubjectScoreBody(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  State<LecturerSubjectScoreBody> createState() =>
      _LecturerSubjectScoreBodyState();
}

class _LecturerSubjectScoreBodyState extends State<LecturerSubjectScoreBody> {
  @override
  void initState() {
    super.initState();

    _getSubjectLecturer();
  }

  _getSubjectLecturer() async {
    widget.academicPeriodRepository.getCurrentAcademicPeriod().then(
          (ac) => widget.majorRepository
              .getlecturerMajor()
              .then((value) => BlocProvider.of<ListSubjectBloc>(context).add(
                    GetLecturerSubject(academicPeriod: ac, major: value),
                  )),
        );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.95;
    double screenHeight = MediaQuery.of(context).size.height * 0.95;

    return BlocConsumer<ListSubjectBloc, ListSubjectState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                            "Daftar Mata Kuliah",
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
                        children: _getSubject(
                            context, state, screenWidth, screenHeight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));

              setState(() {
                widget.academicPeriodRepository.getCurrentAcademicPeriod().then(
                      (ac) => widget.majorRepository.getlecturerMajor().then(
                          (value) =>
                              BlocProvider.of<ListSubjectBloc>(context).add(
                                GetLecturerSubject(
                                    academicPeriod: ac, major: value),
                              )),
                    );
              });
            },
          ),
        );
      },
    );
  }
}

List<Widget> _getSubject(
    context, state, double screenWidth, double screenHeight) {
  if (state is ListSubjectLoading) {
    return [
      const Center(
        child: CircularProgressIndicator(),
      ),
    ];
  } else if (state is ListSubjectLoaded) {
    return [
      Column(
        children: _subject(context, state.subjects, screenWidth),
      )
    ];
  } else {
    return [
      SizedBox(
        width: screenWidth,
        height: screenHeight * 0.9,
        child: const Column(
          children: [
            Gap(20),
            Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
          ],
        ),
      )
    ];
  }
}

List<Widget> _subject(context, List<Subject> subjects, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var subject in subjects) {
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
                                  subject.subjectId,
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
                                  "[${subject.subjectSchedule.first["subject_type"]}] ${subject.subjectName} - ${subject.subjectClass}",
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Gap(5),
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  subject.majorName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
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
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, "/lecturer/score",
                                        arguments: subject);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(0),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: const Color(0xFF0072BB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(Icons.info_outline_rounded),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, "/lecturer/percentage",
                                        arguments: subject);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(0),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(Icons.percent_rounded),
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
