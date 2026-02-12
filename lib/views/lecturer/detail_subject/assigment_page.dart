import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/partials/assignments_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerSubjectAssignmentPage extends StatelessWidget {
  const LecturerSubjectAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool shadowColor = false;

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
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pushReplacementNamed("/lecturer/subject", arguments: subject);
          },
        ),
        centerTitle: true,
        title: Image.asset(
          "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
          height: 40,
          width: 200,
          fit: BoxFit.fill,
        ),
        scrolledUnderElevation: null,
        shadowColor:
            shadowColor == true ? Theme.of(context).colorScheme.shadow : null,
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: LecturerSubjectAssignmentsBody(
        assignment: assignment!,
      ),
    );
  }
}
