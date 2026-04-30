import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/bottom_navbar.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/subject_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentSubjectPage extends StatefulWidget {
  final SubjectRepository subjectRepository;
  final UserRepository userRepository;
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentSubjectPage(
      {super.key,
      required this.subjectRepository,
      required this.userRepository,
      required this.academicPeriodRepository});

  @override
  State<StudentSubjectPage> createState() => _StudentSubjectPageState();
}

class _StudentSubjectPageState extends State<StudentSubjectPage>
    with WidgetsBindingObserver {
  Subject? _subject;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Subject && _subject?.subjectId != args.subjectId) {
      // Subject baru (atau pertama kali dibuka) → reset semua state
      _subject = args;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _clearLoadedWidget();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _clearLoadedWidget();
    }
  }

  _clearLoadedWidget() async {
    if (!mounted) return;
    context.read<PageIndexCubit>().pageClicked(0);

    // Key lama (backward compat)
    await widget.userRepository.setWidgetState("student_material", false);
    await widget.userRepository.setWidgetState("forum", false);
    await widget.userRepository.setWidgetState("student_presence", false);
    await widget.userRepository.setWidgetState("student_score_recap", false);
    await widget.userRepository.setWidgetState("subject_member", false);

    // Key baru per-subject (yang digunakan setelah perbaikan bug)
    if (_subject != null) {
      await widget.userRepository.setWidgetState(
          'forum_${_subject!.activityMasterId}', false);
      await widget.userRepository.setWidgetState(
          'student_presence_${_subject!.subjectId}_${_subject!.subjectClass}', false);
      await widget.userRepository.setWidgetState(
          'subject_member_${_subject!.subjectId}', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _subject sudah di-set di didChangeDependencies, tapi fallback aman jika belum
    _subject ??= ModalRoute.of(context)!.settings.arguments! as Subject;

    return BlocConsumer<PageIndexCubit, int>(
        listener: (context, state) {},
        builder: (context, state) {
          return PopScope(
            child: Scaffold(
              floatingActionButton: state == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/forum/create",
                            arguments: <String, Object?>{
                              "subject": _subject,
                              "announcement": null,
                            },
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF0072BB),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.add_comment_outlined),
                      ),
                    )
                  : null,
              appBar: StudentAppBar(
                academicPeriodRepository: widget.academicPeriodRepository,
                showBackButton: true,
                onBackPressed: () {
                  _clearLoadedWidget();
                  Navigator.maybePop(context);
                },
              ),
              bottomNavigationBar: const StudentBottomNavbar(),
              body: StudentSubjectBody(
                subject: _subject!,
                userRepository: widget.userRepository,
              ),
            ),
            onPopInvoked: (isPop) {
              if (isPop) {
                _clearLoadedWidget();
              }
            },
          );
        });
  }
}
