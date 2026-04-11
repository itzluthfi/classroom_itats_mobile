import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/major/major_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LecturerCollegeAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerCollegeAppBar({
    super.key,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  @override
  State<LecturerCollegeAppBar> createState() => _LecturerCollegeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LecturerCollegeAppBarState extends State<LecturerCollegeAppBar> {
  bool shadowColor = false;
  double? scrolledUnderElevation;
  String currentAcademicPeriod = "";

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AcademicPeriodBloc>(context).add(GetAcademicPeriod());
    BlocProvider.of<MajorBloc>(context).add(GetMajor());
  }

  _filterButtonPressed() async {
    String academicPeriod = "";
    String major = "";
    academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    major = await widget.majorRepository.getlecturerMajor();

    setState(() {
      BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
        academicPeriod: academicPeriod,
        major: major,
        context: context,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: BackButton(
        onPressed: () {
          Navigator.pushNamed(context, "/lecturer/home");
        },
      ),
      title: Image.asset(
        "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Filter Data',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
              ),
              content: SizedBox(
                height: 160,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocConsumer<AcademicPeriodBloc, AcademicPeriodState>(
                          listener: (context, state) {
                            if (state is AcademicPeriodLoadFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Gagal Menampilkan Periode Akademik'),
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
                          },
                          builder: (context, state) {
                            return DropdownMenu<String>(
                                inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade400),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                ),
                                menuStyle: const MenuStyle(
                                  fixedSize: WidgetStatePropertyAll(
                                    Size.fromWidth(220),
                                  ),
                                  maximumSize: WidgetStatePropertyAll(
                                    Size.fromWidth(220),
                                  ),
                                ),
                                width: 220,
                                initialSelection: state is AcademicPeriodLoaded
                                    ? state.currentAcademicPeriod
                                    : "",
                                label: const Text("Tahun Ajaran"),
                                onSelected: (String? value) {
                                  widget.academicPeriodRepository
                                      .setAcademicPeriod(value ?? "");
                                },
                                dropdownMenuEntries: state
                                        is AcademicPeriodLoaded
                                    ? state.academicPeriod
                                        .map((value) => DropdownMenuEntry(
                                            value: value.academicPeriodId,
                                            label:
                                                value.academicPeriodDecription))
                                        .toList()
                                    : []);
                          },
                        ),
                      ],
                    ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocConsumer<MajorBloc, MajorState>(
                          listener: (context, state) {
                            if (state is MajorLoadFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Gagal Menampilkan Jurusan'),
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
                          },
                          builder: (context, state) {
                            return DropdownMenu<String>(
                                inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade400),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                ),
                                menuStyle: const MenuStyle(
                                  fixedSize: WidgetStatePropertyAll(
                                    Size.fromWidth(220),
                                  ),
                                  maximumSize: WidgetStatePropertyAll(
                                    Size.fromWidth(220),
                                  ),
                                ),
                                width: 220,
                                initialSelection: state is MajorLoaded
                                    ? state.currentMajor
                                    : "",
                                label: const Text("Jurusan"),
                                onSelected: (String? value) async {
                                  widget.majorRepository
                                      .setlecturerMajor(value ?? "");
                                },
                                dropdownMenuEntries: state is MajorLoaded
                                    ? state.major
                                        .map<DropdownMenuEntry<String>>(
                                            (value) {
                                        return DropdownMenuEntry<String>(
                                          value: value.realMajorId,
                                          label: value.majorName.toUpperCase(),
                                        );
                                      }).toList()
                                    : []);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    BlocProvider.of<AcademicPeriodBloc>(context)
                        .add(GetAcademicPeriod());
                    BlocProvider.of<MajorBloc>(context).add(GetMajor());

                    _filterButtonPressed();
                    Navigator.pop(context, 'OK');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3D3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.filter_alt_rounded),
        ),
        IconButton(
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).add(LoggedOut());
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
