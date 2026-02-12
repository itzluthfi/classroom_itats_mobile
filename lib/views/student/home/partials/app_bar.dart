import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentAppBar({super.key, required this.academicPeriodRepository});

  @override
  State<StudentAppBar> createState() => _StudentAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StudentAppBarState extends State<StudentAppBar> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AcademicPeriodBloc>(context).add(GetAcademicPeriod());
  }

  _onButtonFilterPressed() async {
    final prefs = await SharedPreferences.getInstance();

    final academicPeriod = prefs.getString("current_academic_period");

    setState(() {
      BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
          academicPeriod: academicPeriod ?? "", major: "", context: context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
        height: 40,
        width: 200,
        fit: BoxFit.fill,
      ),
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
      actions: [
        IconButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Fliter'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocConsumer<AcademicPeriodBloc, AcademicPeriodState>(
                      listener: (context, state) {
                    if (state is AcademicPeriodLoadFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Gagal Menampilkan Periode Akademik'),
                          duration: const Duration(milliseconds: 1500),
                          width: 280.0, // Width of the SnackBar.
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical:
                                8.0, // Inner padding for SnackBar content.
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      );
                    }
                  }, builder: (context, state) {
                    return DropdownMenu<String>(
                      textStyle: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      menuStyle: const MenuStyle(
                        fixedSize: MaterialStatePropertyAll(
                          Size.fromWidth(200),
                        ),
                        maximumSize: MaterialStatePropertyAll(
                          Size.fromWidth(200),
                        ),
                      ),
                      width: 200,
                      initialSelection: state is AcademicPeriodLoaded
                          ? state.currentAcademicPeriod
                          : "",
                      label: const Text("Tahun Ajaran"),
                      onSelected: (String? value) {
                        widget.academicPeriodRepository
                            .setAcademicPeriod(value ?? "");
                      },
                      dropdownMenuEntries: state is AcademicPeriodLoaded
                          ? state.academicPeriod
                              .map((value) => DropdownMenuEntry(
                                  value: value.academicPeriodId,
                                  label: value.academicPeriodDecription))
                              .toList()
                          : [],
                    );
                  }),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    BlocProvider.of<AcademicPeriodBloc>(context)
                        .add(GetAcademicPeriod());
                    _onButtonFilterPressed();
                    Navigator.pop(context, 'OK');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.filter_alt_rounded),
        ),
        IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/student/profile");
            },
            icon: const Icon(Icons.account_circle_outlined)),
        IconButton(
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).add(LoggedOut());
          },
          icon: const Icon(Icons.logout),
        )
      ],
    );
  }
}
