import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/partials/materials_body.dart';
import 'package:classroom_itats_mobile/widgets/forum_body.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/partials/presence_body.dart';
import 'package:classroom_itats_mobile/widgets/subject_member_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerSubjectBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const LecturerSubjectBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<LecturerSubjectBody> createState() => _LecturerSubjectBodyState();
}

class _LecturerSubjectBodyState extends State<LecturerSubjectBody> {
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
            LecturePresenceBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
            LecturerMaterialsBody(
                subject: widget.subject, userRepository: widget.userRepository),
            SubjectMemberBody(
              subject: widget.subject,
              userRepository: widget.userRepository,
            ),
          ][state];
        });
  }
}
