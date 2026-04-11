import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/create_college_report_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerCreateCollegeReportPage extends StatelessWidget {
  const LecturerCreateCollegeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;
    SubjectReport data =
        ModalRoute.of(context)!.settings.arguments! as SubjectReport;

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
      body: LecturerCreateCollegeReportBody(subject: data),
    );
  }
}
