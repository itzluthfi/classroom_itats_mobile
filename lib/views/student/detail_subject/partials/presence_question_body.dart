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

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  List<Map<String, dynamic>> answer = [];
  List<StudentAnswer?> controller = [];
  int presenceScore = 0;
  Map<String, dynamic>? presence;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PresenceBloc>().add(
        GetPresenceQuestion(academicPeriod: widget.subject.academicPeriodId));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 10,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Presensi Mahasiswa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
            const SizedBox(height: 12),

            // Content Area
            Expanded(
              child: BlocConsumer<PresenceBloc, PresenceState>(
                listener: (context, state) {
                  if (state is PresenceLoadFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Gagal Menampilkan Pertanyaan Presensi'),
                        duration: const Duration(milliseconds: 1500),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  }
                  if (state is PresenceLoaded) {
                    setState(() {
                      if (answer.isEmpty ||
                          answer.length != state.presenceQuestions.length) {
                        answer = List.generate(
                            state.presenceQuestions.length,
                            (index) => {
                                  "lecture_id": widget.lecture.lectureID!,
                                  "presence_question_id": state
                                      .presenceQuestions[index].masterQuestionId,
                                  "answer": 1,
                                  "created_at":
                                      "${DateTime.now().toLocal().toIso8601String()}Z",
                                  "updated_at":
                                      "${DateTime.now().toLocal().toIso8601String()}Z",
                                });
                        controller = List.generate(
                            state.presenceQuestions.length,
                            (index) => StudentAnswer.ya);
                        presenceScore = state.presenceQuestions.length;
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is PresenceLoaded) {
                    return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(10),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 12.0),
                        itemCount: state.presenceQuestions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final isSelectedYa =
                              controller[index] == StudentAnswer.ya;
                          final isSelectedTidak =
                              controller[index] == StudentAnswer.tidak;

                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${index + 1}. ${state.presenceQuestions[index].question}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildOptionButton(
                                        label: 'Ya',
                                        icon: Icons.check_circle_outline,
                                        isSelected: isSelectedYa,
                                        activeColor: const Color(0xFF10B981), // Emerald Green
                                        onTap: () {
                                          setState(() {
                                            if (controller[index] !=
                                                StudentAnswer.ya) {
                                              presenceScore += 1;
                                            }
                                            controller[index] =
                                                StudentAnswer.ya;
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
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildOptionButton(
                                        label: 'Tidak',
                                        icon: Icons.cancel_outlined,
                                        isSelected: isSelectedTidak,
                                        activeColor: const Color(0xFFEF4444), // Crimson Red
                                        onTap: () {
                                          setState(() {
                                            if (controller[index] ==
                                                StudentAnswer.ya) {
                                              presenceScore -= 1;
                                            }
                                            controller[index] =
                                                StudentAnswer.tidak;
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
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Submit Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Simpan Presensi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
