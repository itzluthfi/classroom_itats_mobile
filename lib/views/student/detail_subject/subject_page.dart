import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/bottom_navbar.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/subject_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentSubjectPage extends StatefulWidget {
  final SubjectRepository subjectRepository;
  final UserRepository userRepository;

  const StudentSubjectPage(
      {super.key,
      required this.subjectRepository,
      required this.userRepository});

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
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _clearLoadedWidget();
    }
  }

  _clearLoadedWidget() async {
    context.read<PageIndexCubit>().pageClicked(0);

    await widget.userRepository.setWidgetState("student_material", false);
    await widget.userRepository.setWidgetState("forum", false);
    await widget.userRepository.setWidgetState("student_presence", false);
    await widget.userRepository.setWidgetState("student_score_recap", false);
    await widget.userRepository.setWidgetState("subject_member", false);
  }

  @override
  Widget build(BuildContext context) {
    bool shadowColor = false;
    _subject = ModalRoute.of(context)!.settings.arguments! as Subject;

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
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    _clearLoadedWidget();

                    Navigator.maybePop(context);
                  },
                ),
                centerTitle: true,
                title: Image.asset(
                  "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
                  height: 40,
                  width: 200,
                  fit: BoxFit.fill,
                ),
                scrolledUnderElevation: scrolledUnderElevation,
                shadowColor: shadowColor == true
                    ? Theme.of(context).colorScheme.shadow
                    : null,
                actions: [
                  IconButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context).add(LoggedOut());
                    },
                    icon: const Icon(Icons.logout),
                  )
                ],
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
