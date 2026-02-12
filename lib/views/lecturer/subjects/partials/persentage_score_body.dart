import 'package:classroom_itats_mobile/models/percentage_score.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/percentage_score/percentage_score_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PercentageScoreBody extends StatefulWidget {
  final Subject subject;
  const PercentageScoreBody({super.key, required this.subject});

  @override
  State<PercentageScoreBody> createState() => _PercentageScoreBodyState();
}

class _PercentageScoreBodyState extends State<PercentageScoreBody> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PercentageScoreBloc>(context).add(GetPercentageScoreScore(
        masterActivityId: widget.subject.activityMasterId));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.95;

    return BlocConsumer<PercentageScoreBloc, PercentageScoreState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Placeholder(
            color: Colors.transparent,
            child: RefreshIndicator(
                child: ListView(
                  controller: ScrollController(),
                  scrollDirection: Axis.vertical,
                  children: state is PercentageScoreLoaded
                      ? <Widget>[
                          const Gap(20),
                          Column(
                            children: [
                              SizedBox(
                                width: screenWidth,
                                child: Text(
                                  widget.subject.subjectName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: screenWidth,
                                child: Text(
                                  "${widget.subject.lecturerId} - ${widget.subject.lecturerName}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(20),
                          Column(
                            children: [
                              Text(
                                "progress persentase ${state.percentageScores.totalPercentage}%/100%",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: _percentageScore(
                                    state.percentageScores
                                        .percentageScoreDetails,
                                    screenWidth),
                              )
                            ],
                          ),
                        ]
                      : state is PercentageScoreLoading
                          ? [
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ]
                          : [],
                ),
                onRefresh: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));

                  setState(() {
                    BlocProvider.of<PercentageScoreBloc>(context).add(
                        GetPercentageScoreScore(
                            masterActivityId: widget.subject.activityMasterId));
                  });
                }));
      },
    );
  }
}

List<Widget> _percentageScore(
    List<PercentageScoreDetail> percentageScoreDetails, double screenWidth) {
  List<Widget> scores = List.empty(growable: true);

  for (var percentageScoreDetail in percentageScoreDetails) {
    scores.add(
      Row(
        children: [
          SizedBox(
            width: screenWidth,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  percentageScoreDetail.assignmentType,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Gap(5),
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  percentageScoreDetail.assignmentTitle,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Gap(5),
                              SizedBox(
                                width: screenWidth * 0.6,
                                child: Text(
                                  "minggu ke - ${percentageScoreDetail.weekId}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CircularPercentIndicator(
                                  radius: 40.0,
                                  lineWidth: 10.0,
                                  animation: true,
                                  percent:
                                      (percentageScoreDetail.percentage) / 100,
                                  center: Text(
                                    "${percentageScoreDetail.percentage}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: const Color(0xFF0072BB),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    scores.add(const Gap(10));
  }

  return scores;
}
