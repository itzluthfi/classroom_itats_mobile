import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomeBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentHomeBody({super.key, required this.academicPeriodRepository});

  @override
  State<StudentHomeBody> createState() => _StudentHomeBodyState();
}

class _StudentHomeBodyState extends State<StudentHomeBody> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    _getSubjectHome();
  }

  _getSubjectHome() async {
    var academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    if (academicPeriod == "" ||
        await widget.academicPeriodRepository.getActiveAcademicPeriod() ==
            academicPeriod) {
      setState(() {
        BlocProvider.of<SubjectBloc>(context).add(GetSubject(context: context));
      });
    } else {
      setState(() {
        BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
          academicPeriod: academicPeriod,
          major: "",
          context: context,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.948;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<SubjectBloc, SubjectState>(
      listener: (context, state) {
        if (state is SubjectLoadFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Mohon maaf, terjadi kesalahan dalam mengambil data mata kuliah anda'),
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
      builder: (context, state) {
        if (state is SubjectLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return RefreshIndicator(
          child: ListView(
            controller: ScrollController(),
            scrollDirection: Axis.vertical,
            children: _getSubject(state, screenWidth, screenHeight),
          ),
          onRefresh: () async {
            final prefs = await SharedPreferences.getInstance();
            final academicPeriod = prefs.getString("current_academic_period");
            await Future<void>.delayed(const Duration(milliseconds: 1000));
            setState(() {
              BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
                  academicPeriod: academicPeriod ?? "",
                  major: "",
                  context: context));
            });
          },
        );
      },
    );
  }
}

List<Widget> _getSubject(
    SubjectState state, double screenWidth, double screenHeight) {
  if (state is SubjectLoaded) {
    return state.data;
  } else {
    return [
      SizedBox(
        width: screenWidth,
        height: screenHeight * 0.9,
        child: const Column(
          children: [
            Gap(20),
            Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
          ],
        ),
      )
    ];
  }
}
