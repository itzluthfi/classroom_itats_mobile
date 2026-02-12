import 'dart:io';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/college_app_bar.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/college_report_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LecturerCollegeReportPage extends StatelessWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerCollegeReportPage(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: LecturerCollegeAppBar(
          academicPeriodRepository: academicPeriodRepository,
          majorRepository: majorRepository,
        ),
        body: LecturerCollegeReportBody(
            academicPeriodRepository: academicPeriodRepository,
            majorRepository: majorRepository),
      ),
      onPopInvokedWithResult: (isPop, _) {
        if (isPop) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          }
          if (Platform.isIOS) {
            exit(0);
          }
        }
      },
    );
  }
}
