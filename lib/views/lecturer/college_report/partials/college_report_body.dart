import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LecturerCollegeReportBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerCollegeReportBody({
    super.key,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  @override
  State<LecturerCollegeReportBody> createState() =>
      _LecturerCollegeReportBodyState();
}

class _LecturerCollegeReportBodyState extends State<LecturerCollegeReportBody> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    _getHomeSubject();
  }

  _getHomeSubject() async {
    if (!mounted) return;
    var academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    var major = await widget.majorRepository.getlecturerMajor();
    if (!mounted) return;
    if (academicPeriod == "" ||
        await widget.academicPeriodRepository.getActiveAcademicPeriod() ==
            academicPeriod) {
      if (!mounted) return;
      BlocProvider.of<SubjectBloc>(context)
          .add(GetSubjectReport(context: context));
    } else {
      if (!mounted) return;
      BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressedReport(
        academicPeriod: academicPeriod,
        major: major,
        context: context,
      ));
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
              content: const Text('Gagal memuat data pelaporan'),
              duration: const Duration(milliseconds: 1500),
              width: 280.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
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
          return RefreshIndicator(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
              onRefresh: () async {
                var academicPeriod = await widget.academicPeriodRepository
                    .getCurrentAcademicPeriod();
                var major = await widget.majorRepository.getlecturerMajor();

                await Future<void>.delayed(const Duration(milliseconds: 1000));

                setState(() {
                  BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
                    academicPeriod: academicPeriod,
                    major: major,
                    context: context,
                  ));
                });
              });
        }
        return RefreshIndicator(
          child: ListView(
            controller: ScrollController(),
            scrollDirection: Axis.vertical,
            children: _getSubject(state, screenWidth, screenHeight),
          ),
          onRefresh: () async {
            var academicPeriod = await widget.academicPeriodRepository
                .getCurrentAcademicPeriod();
            var major = await widget.majorRepository.getlecturerMajor();

            await Future<void>.delayed(const Duration(milliseconds: 1000));

            setState(() {
              BlocProvider.of<SubjectBloc>(context)
                  .add(FilterButtonPressedReport(
                academicPeriod: academicPeriod,
                major: major,
                context: context,
              ));
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
        height: screenHeight * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_rounded, size: 80, color: Colors.grey),
            Gap(16),
            Text(
              "Mohon maaf, tidak ada data pelaporan yang dapat ditampilkan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  }
}
