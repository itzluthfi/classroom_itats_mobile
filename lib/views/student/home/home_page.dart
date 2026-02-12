import 'dart:io';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/home_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentHomePage extends StatelessWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentHomePage({super.key, required this.academicPeriodRepository});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: StudentAppBar(
          academicPeriodRepository: academicPeriodRepository,
        ),
        body:
            StudentHomeBody(academicPeriodRepository: academicPeriodRepository),
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
