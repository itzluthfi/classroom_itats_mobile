import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/partials/student_score_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerStudentScorePage extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerStudentScorePage(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  State<LecturerStudentScorePage> createState() =>
      _LecturerStudentScorePageState();
}

class _LecturerStudentScorePageState extends State<LecturerStudentScorePage> {
  Subject? _subject;

  @override
  Widget build(BuildContext context) {
    _subject = ModalRoute.of(context)!.settings.arguments! as Subject;
    double? scrolledUnderElevation;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
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
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SubjectScoreBody(subject: _subject!),
    );
  }
}
