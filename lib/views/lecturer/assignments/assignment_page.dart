import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/assignments/partials/assignment_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerAssignmentPage extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerAssignmentPage(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  State<LecturerAssignmentPage> createState() => _LecturerAssignmentPageState();
}

class _LecturerAssignmentPageState extends State<LecturerAssignmentPage> {
  String? _currentAcademicPeriod;
  String? _activeAcademicPeriod;
  String? _major;

  @override
  void initState() {
    super.initState();
    _getAcademicPeriod();
    _getMajor();
  }

  _getAcademicPeriod() async {
    var current =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    var active =
        await widget.academicPeriodRepository.getActiveAcademicPeriod();
    setState(() {
      _currentAcademicPeriod = current;
      _activeAcademicPeriod = active;
    });
  }

  _getMajor() async {
    var major = await widget.majorRepository.getlecturerMajor();
    setState(() {
      _major = major;
    });
  }

  @override
  Widget build(BuildContext context) {
    double? scrolledUnderElevation;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushNamed(context, "/lecturer/home");
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
              Navigator.pushNamed(context, "/lecturer/subject_score");
            },
            icon: const Icon(Icons.book_sharp),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/lecturer/college_report");
            },
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LecturerAssignmentBody(
          academicPeriodRepository: widget.academicPeriodRepository,
          majorRepository: widget.majorRepository),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentAcademicPeriod == _activeAcademicPeriod) {
            Navigator.pushReplacementNamed(
                context, "/lecturer/assignment/create",
                arguments: [_currentAcademicPeriod, _major]);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    const Text('Mohon maaf, periode akademik telah berakhir'),
                duration: const Duration(milliseconds: 1500),
                width: 280.0, // Width of the SnackBar.
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0, // Inner padding for SnackBar content.
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
