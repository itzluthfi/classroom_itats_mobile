import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/detail_college_report_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerDetailCollegeReportPage extends StatefulWidget {
  const LecturerDetailCollegeReportPage({super.key});

  @override
  State<LecturerDetailCollegeReportPage> createState() =>
      _LecturerDetailCollegeReportPageState();
}

class _LecturerDetailCollegeReportPageState
    extends State<LecturerDetailCollegeReportPage> {
  SubjectReport? _subject;

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;
    _subject = ModalRoute.of(context)!.settings.arguments! as SubjectReport;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/lecturer/college_report/create",
              arguments: _subject,
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF0072BB),
          foregroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),
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
      body: LecturerDetailCollegeReport(subject: _subject!),
    );
  }
}
