import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StudentSubjectCard extends StatefulWidget {
  final String imagePath;
  final Subject subject;
  final void Function() onTap;

  const StudentSubjectCard({
    super.key,
    required this.imagePath,
    required this.subject,
    required this.onTap,
  });

  @override
  State<StudentSubjectCard> createState() => _StudentSubjectCardState();
}

class _StudentSubjectCardState extends State<StudentSubjectCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.9;

    return Placeholder(
      color: Colors.transparent,
      child: SizedBox(
        height: 180,
        width: screenWidth,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Card(
            clipBehavior: Clip.hardEdge,
            borderOnForeground: true,
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: widget.onTap,
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(10),
                        Row(
                          children: [
                            Text(
                              widget.subject.lecturerName.toUpperCase(),
                              textAlign: TextAlign.start,
                              softWrap: true,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.subject.subjectName,
                          textAlign: TextAlign.start,
                          softWrap: true,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.white,
                          ),
                        ),
                        Gap(widget.subject.subjectSchedule.length > 1
                            ? 30
                            : 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _subjectRoomRows(
                                  widget.subject.subjectSchedule),
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.subject.subjectClass,
                                  style: const TextStyle(
                                    height: 1.8,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _subjectRoomRows(List<Map<String, dynamic>> subjectSchedules) {
  List<Widget> data = List.empty(growable: true);
  for (var subjectSchedule in subjectSchedules) {
    data.add(
      Row(
        children: [
          Text(
            "[${subjectSchedule["subject_type"]}] ${subjectSchedule["subject_room"]} ${subjectSchedule["day"]}, ${DateFormat("HH:mm").format(DateFormat().add_Hms().parse(subjectSchedule["time_start"]))}-${DateFormat("HH:mm").format(DateFormat().add_Hms().parse(subjectSchedule["time_end"]))}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
  return data;
}
