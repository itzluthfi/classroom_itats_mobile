import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/partials/bottom_navbar.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/partials/subject_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerSubjectPage extends StatefulWidget {
  final UserRepository userRepository;
  const LecturerSubjectPage({super.key, required this.userRepository});

  @override
  State<LecturerSubjectPage> createState() => _LecturerSubjectPageState();
}

class _LecturerSubjectPageState extends State<LecturerSubjectPage>
    with WidgetsBindingObserver {
  Subject? _subject;
  bool shadowColor = false;
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
    await widget.userRepository.setWidgetState("lecturer_presence", false);
    await widget.userRepository.setWidgetState("lecturer_material", false);
    await widget.userRepository.setWidgetState("forum", false);
    await widget.userRepository.setWidgetState("subject_member", false);
  }

  @override
  Widget build(BuildContext context) {
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
                          _clearLoadedWidget();

                          Navigator.pushNamed(context, "/forum/create",
                              arguments: <String, Object?>{
                                "subject": _subject,
                                "announcement": null,
                              });
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
              bottomNavigationBar: const LecturerBottomNavbar(),
              body: LecturerSubjectBody(
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
