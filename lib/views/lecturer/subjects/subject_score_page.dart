import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/partials/lecturer_subject_score_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerSubjectScorePage extends StatelessWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerSubjectScorePage(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, "/lecturer/home");
          },
        ),
        title: Image.asset(
          "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
          height: 40,
          width: 200,
          fit: BoxFit.fill,
        ),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: null,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/lecturer/assignment");
            },
            icon: const Icon(Icons.folder_open_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/lecturer/college_report");
            },
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LecturerSubjectScoreBody(
        academicPeriodRepository: academicPeriodRepository,
        majorRepository: majorRepository,
      ),
    );
  }
}
