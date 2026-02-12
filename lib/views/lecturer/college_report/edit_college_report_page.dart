import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/edit_college_report_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerEditCollegeReportPage extends StatelessWidget {
  const LecturerEditCollegeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;
    Map<String, Object> data =
        ModalRoute.of(context)!.settings.arguments! as Map<String, Object>;
    SubjectReport subject = data["subject"] as SubjectReport;
    Lecture lecture = data["lecture"] as Lecture;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            BlocProvider.of<StudyMaterialBloc>(context)
                .add(ClearStateStudyMaterial());

            Navigator.pushNamed(context, "/lecturer/college_report/detail",
                arguments: subject);
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
              BlocProvider.of<StudyMaterialBloc>(context)
                  .add(ClearStateStudyMaterial());

              Navigator.pushNamed(context, "/lecturer/subject_score");
            },
            icon: const Icon(Icons.book_sharp),
          ),
          IconButton(
            onPressed: () {
              BlocProvider.of<StudyMaterialBloc>(context)
                  .add(ClearStateStudyMaterial());

              Navigator.pushNamed(context, "/lecturer/assignment");
            },
            icon: const Icon(Icons.folder_open_rounded),
          ),
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LecturerEditCollegeReportBody(
        subject: subject,
        lecture: lecture,
      ),
    );
  }
}
