import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/presence/presence_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum StudentAnswer { tidak, ya, none }

class PresenceQuestionBody extends StatefulWidget {
  final double screenWidth;
  final Lecture lecture;
  final Subject subject;
  const PresenceQuestionBody({
    super.key,
    required this.screenWidth,
    required this.lecture,
    required this.subject,
  });

  @override
  State<PresenceQuestionBody> createState() => _PresenceQuestionBodyState();
}

class _PresenceQuestionBodyState extends State<PresenceQuestionBody> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      color: Colors.transparent,
      child: SizedBox(
        width: 40,
        height: 40,
        child: TextButton(
          style: const ButtonStyle(
            shape: WidgetStatePropertyAll(CircleBorder()),
            backgroundColor: WidgetStatePropertyAll(
              Color(0xFF0072BB),
            ),
          ),
          onPressed: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialog(
                    subject: widget.subject,
                    screenWidth: widget.screenWidth,
                    lecture: widget.lecture,
                  );
                });
          },
          child: Text(
            widget.lecture.lectureType!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatefulWidget {
  final Subject subject;
  final double screenWidth;
  final Lecture lecture;
  const CustomAlertDialog({
    super.key,
    required this.subject,
    required this.screenWidth,
    required this.lecture,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog>
    with WidgetsBindingObserver {
  Object? presence;
  int presenceScore = 0;
  List<Map<String, dynamic>> answer = List.empty(growable: true);
  List<StudentAnswer?> controller = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PresenceBloc>(context).add(
        GetPresenceQuestion(academicPeriod: widget.subject.academicPeriodId));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Column(
        children: [
          Text(
            'Presensi Mahasiswa',
            style: TextStyle(
              fontSize: 28,
            ),
          ),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocConsumer<PresenceBloc, PresenceState>(listener: (context, state) {
            if (state is PresenceLoadFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Gagal Menampilkan Pertanyaan Presensi'),
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
            if (state is PresenceLoaded) {
              setState(() {
                answer = List.filled(state.presenceQuestions.length, {});
                controller = List.generate(state.presenceQuestions.length,
                    (index) => StudentAnswer.none);
              });
            }
          }, builder: (context, state) {
            if (state is PresenceLoaded) {
              return SafeArea(
                child: SizedBox(
                  width: widget.screenWidth * 0.6795,
                  child: ListView.separated(
                    controller: ScrollController(),
                    scrollDirection: Axis.vertical,
                    itemCount: state.presenceQuestions.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: widget.screenWidth * 0.679,
                                child: Text(
                                  textAlign: TextAlign.justify,
                                  state.presenceQuestions[index].question,
                                  maxLines: 3,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: widget.screenWidth * 0.315,
                                    child: ListTile(
                                      title: const Text(
                                        'Ya',
                                        maxLines: 1,
                                      ),
                                      leading: Radio<StudentAnswer?>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity:
                                            const VisualDensity(horizontal: -4),
                                        value: StudentAnswer.ya,
                                        groupValue: controller[index],
                                        onChanged: (StudentAnswer? value) {
                                          setState(() {
                                            controller[index] = value;
                                            answer[index] = {
                                              "lecture_id":
                                                  widget.lecture.lectureID!,
                                              "presence_question_id": state
                                                  .presenceQuestions[index]
                                                  .masterQuestionId,
                                              "answer": 1,
                                              "created_at":
                                                  "${DateTime.now().toLocal().toIso8601String()}Z",
                                              "updated_at":
                                                  "${DateTime.now().toLocal().toIso8601String()}Z",
                                            };
                                            presenceScore += 1;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: widget.screenWidth * 0.36,
                                    child: ListTile(
                                      title: const Text(
                                        'Tidak',
                                        maxLines: 1,
                                      ),
                                      leading: Radio<StudentAnswer?>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity:
                                            const VisualDensity(horizontal: -4),
                                        value: StudentAnswer.tidak,
                                        groupValue: controller[index],
                                        onChanged: (StudentAnswer? value) {
                                          setState(() {
                                            controller[index] = value;
                                            answer[index] = {
                                              "lecture_id":
                                                  widget.lecture.lectureID!,
                                              "presence_question_id": state
                                                  .presenceQuestions[index]
                                                  .masterQuestionId,
                                              "answer": 0,
                                              "created_at":
                                                  "${DateTime.now().toLocal().toIso8601String()}Z",
                                              "updated_at":
                                                  "${DateTime.now().toLocal().toIso8601String()}Z",
                                            };
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  ),
                ),
              );
            } else {
              return const Column();
            }
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
            presence = {
              "presence_student": <String, dynamic>{
                "academic_period_id": widget.subject.academicPeriodId,
                "subject_id": widget.subject.subjectId,
                "major_id": widget.subject.majorId,
                "subject_class": widget.subject.subjectClass,
                "college_schedule":
                    "${widget.lecture.lectureSchedule!.toLocal().toIso8601String()}Z",
                "is_present": true,
                "college_type": widget.lecture.lectureType,
                "hour_id": widget.lecture.hourID,
                "week_id": widget.lecture.weekID,
                "is_offline": true,
                "score": presenceScore,
              },
              "presence_answers": answer,
            };
            setState(() {
              BlocProvider.of<PresenceBloc>(context, listen: false)
                  .add(SetStudentPresence(studentPresence: presence!));
              BlocProvider.of<LectureBloc>(context).add(GetStudentLecture(
                academicPeriod: widget.subject.academicPeriodId,
                subjectId: widget.subject.subjectId,
                subjectClass: widget.subject.subjectClass,
              ));
            });

            Navigator.pop(context, "OK");
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
