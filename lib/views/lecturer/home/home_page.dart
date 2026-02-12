import 'dart:io';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/home/partials/app_bar.dart';
import 'package:classroom_itats_mobile/views/lecturer/home/partials/home_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LecturerHomePage extends StatelessWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerHomePage(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: LecturerAppBar(
          academicPeriodRepository: academicPeriodRepository,
          majorRepository: majorRepository,
        ),
        body: LecturerHomeBody(
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
