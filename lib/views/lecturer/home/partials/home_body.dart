import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LecturerHomeBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerHomeBody({
    super.key,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  @override
  State<LecturerHomeBody> createState() => _LecturerHomeBodyState();
}

class _LecturerHomeBodyState extends State<LecturerHomeBody> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    _getHomeSubject();
  }

  _getHomeSubject() async {
    var academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    var major = await widget.majorRepository.getlecturerMajor();
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
          major: major,
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
              content: const Text('Load Subjects Failed'),
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
              BlocProvider.of<SubjectBloc>(context).add(FilterButtonPressed(
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
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
            Gap(16),
            Text(
              "Mohon maaf, tidak ada jadwal kelas saat ini",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  }
}
