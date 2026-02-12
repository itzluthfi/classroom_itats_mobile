import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/widgets/forum_body.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/materials_body.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/presence_body.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/score_recap_body.dart';
import 'package:classroom_itats_mobile/widgets/subject_member_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentSubjectBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const StudentSubjectBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<StudentSubjectBody> createState() => _StudentSubjectBodyState();
}

class _StudentSubjectBodyState extends State<StudentSubjectBody> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageIndexCubit, int>(
        listener: (context, state) {},
        builder: (context, state) {
          return <Widget>[
            ForumBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
            StudentPresenceBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
            StudentMaterialsBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
            StudentScoreRecapBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
            SubjectMemberBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
          ][state];
        });
  }
}
