import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/upload_assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StudentAssignmentsBody extends StatefulWidget {
  final Assignment assignment;

  const StudentAssignmentsBody({
    super.key,
    required this.assignment,
  });

  @override
  State<StudentAssignmentsBody> createState() => _StudentAssignmentsBodyState();
}

class _StudentAssignmentsBodyState extends State<StudentAssignmentsBody> {
  static const headerStyle =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AssignmentBloc>(context).add(GetStudentAssignmentWeek(
        masterActivityId: widget.assignment.activityMasterId,
        weekId: widget.assignment.weekId));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.84;

    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Placeholder(
          color: const Color.fromRGBO(0, 0, 0, 0),
          child: RefreshIndicator(
              child: Accordion(
                headerBorderColor: Colors.grey,
                headerBorderWidth: 1,
                headerBorderColorOpened: Colors.grey,
                headerBackgroundColorOpened: Colors.white,
                contentBackgroundColor: Colors.white,
                contentBorderColor: Colors.grey,
                contentBorderWidth: 1,
                contentHorizontalPadding: 20,
                scaleWhenAnimating: true,
                openAndCloseAnimation: true,
                headerPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                sectionClosingHapticFeedback: SectionHapticFeedback.light,
                headerBackgroundColor: Colors.white,
                children: state is AssignmentLoaded
                    ? _assignmentList(context, state, headerStyle,
                        state.assignmentsJoin, screenWidth)
                    : _assignmentList(
                        context, state, headerStyle, List.empty(), screenWidth),
              ),
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                setState(() {
                  BlocProvider.of<AssignmentBloc>(context).add(
                      GetStudentAssignmentWeek(
                          masterActivityId: widget.assignment.activityMasterId,
                          weekId: widget.assignment.weekId));
                });
              }),
        );
      },
    );
  }
}

List<AccordionSection> _assignmentList(context, state, TextStyle headerStyle,
    List<StudentAssignmentJoin> assignments, screenWidth) {
  List<AccordionSection> accordionSections = List.empty(growable: true);

  for (var assignment in assignments) {
    accordionSections.add(
      AccordionSection(
        isOpen: false,
        contentVerticalPadding: 20,
        leftIcon: const Icon(Icons.assignment, color: Colors.black),
        rightIcon:
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.assignmentTitle, style: headerStyle),
            Text(
              "tenggat: ${DateFormat(
                "EEEE, d/M/y H:mm",
                "id_ID",
              ).format(
                assignment.dueDate,
              )}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: assignment.dueDate.compareTo(DateTime.now()) >= 0
                    ? Colors.green
                    : Colors.red,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
        content: SizedBox(
          child: Center(
            child: Column(
              children: [
                Text(
                  assignment.description,
                  textAlign: TextAlign.justify,
                  maxLines: 10,
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    assignment.fileLink != "" && assignment.fileName != ""
                        ? Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.white,
                                  backgroundColor: const Color(0xFF0072BB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  BlocProvider.of<AssignmentBloc>(context)
                                    ..add(
                                      DownloadAssignment(
                                          fileLink: assignment.fileLink,
                                          fileName: assignment.fileName),
                                    )
                                    ..add(GetStudentSubmitedAssignment(
                                        assignmentId: assignment.assignmentId));
                                },
                                child: const Text("Download File Tugas"),
                              ),
                            ],
                          )
                        : const Column(),
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.white,
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  UploadAssignmentBody(
                                screenWidth: screenWidth,
                                assignmentId: assignment.assignmentId,
                              ),
                            );
                          },
                          child: const Text("Upload Tugas"),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(10),
                assignment.assignmentSubmissionId != 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  BlocProvider.of<AssignmentBloc>(context).add(
                                    DownloadStudentAssignmentSubmission(
                                        fileLink: state
                                            .studentAssignmentSubmission!
                                            .assignmentLink,
                                        fileName: state
                                            .studentAssignmentSubmission!
                                            .assignmentFile),
                                  );
                                  BlocProvider.of<AssignmentBloc>(context).add(
                                      GetStudentSubmitedAssignment(
                                          assignmentId: state
                                              .studentAssignmentSubmission!
                                              .assignmentId));
                                },
                                child: const Text("Download Tugas Disubmit"),
                              ),
                              Text("Dikumpulkan Pada ${DateFormat(
                                "EEEE, d/M/y H:m",
                                "id_ID",
                              ).format(assignment.createdAt)}"),
                              Text(
                                assignment.dueDate
                                            .compareTo(assignment.createdAt) ==
                                        -1
                                    ? "Terlambat"
                                    : "",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Row()
              ],
            ),
          ),
        ),
      ),
    );
  }

  return accordionSections;
}
