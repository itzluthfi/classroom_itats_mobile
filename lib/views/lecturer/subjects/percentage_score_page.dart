import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/partials/persentage_score_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerPercentagePage extends StatefulWidget {
  const LecturerPercentagePage({super.key});

  @override
  State<LecturerPercentagePage> createState() => _LecturerPercentagePageState();
}

class _LecturerPercentagePageState extends State<LecturerPercentagePage> {
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
      body: PercentageScoreBody(subject: _subject!),
    );
  }
}
