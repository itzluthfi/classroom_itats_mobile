import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/views/lecturer/assignments/partials/create_assignment_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerCreateAssignmentPage extends StatelessWidget {
  const LecturerCreateAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;
    List<String?> data =
        ModalRoute.of(context)!.settings.arguments! as List<String?>;

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
      body: LecturerCreateAssignmentBody(
          academicPeriodId: data[0]!, major: data[1]!),
    );
  }
}
