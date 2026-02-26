import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/assignments_body.dart';
import 'package:flutter/material.dart';

import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';

class StudentAssignmentPage extends StatelessWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentAssignmentPage(
      {super.key, required this.academicPeriodRepository});

  @override
  Widget build(BuildContext context) {
    List<Object?> argumentObjects =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;

    Assignment? assignment;
    Subject? subject;

    for (var element in argumentObjects) {
      if (element is Subject) {
        subject = element;
      }
      if (element is Assignment) {
        assignment = element;
      }
    }

    return Scaffold(
      appBar: StudentAppBar(
        academicPeriodRepository: academicPeriodRepository,
        showBackButton: true,
        onBackPressed: () {
          Navigator.of(context)
              .pushReplacementNamed("/student/subject", arguments: subject);
        },
      ),
      body: StudentAssignmentsBody(
        assignment: assignment!,
      ),
    );
  }
}
