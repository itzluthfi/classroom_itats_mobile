import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class LecturerSubjectCard extends StatefulWidget {
  final String imagePath;
  final Subject subject;
  final void Function() onTap;

  const LecturerSubjectCard({
    super.key,
    required this.imagePath,
    required this.subject,
    required this.onTap,
  });

  @override
  State<LecturerSubjectCard> createState() => _LecturerSubjectCardState();
}

class _LecturerSubjectCardState extends State<LecturerSubjectCard> {
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
            color: Colors.transparent,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            clipBehavior: Clip.hardEdge,
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
                              "${widget.subject.subjectCredits} ${"SKS"}",
                              textAlign: TextAlign.start,
                              softWrap: true,
                              maxLines: 1,
                              textWidthBasis: TextWidthBasis.parent,
                              style: const TextStyle(
                                height: 1.5,
                                fontSize: 18,
                                color: Colors.white,
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
                            height: 1.5,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              children: _subjectRoomRows(
                                  widget.subject.subjectSchedule),
                            )
                          ],
                        ),
                        Gap(widget.subject.subjectSchedule.length <= 1
                            ? 20
                            : 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Column(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.amber,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          widget.subject.totalStudent
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            height: 1.8,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
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
                            )
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
    // Safety check for keys
    final type = subjectSchedule["subject_type"] ?? "-";
    final room = subjectSchedule["subject_room"] ?? "-";
    final day = subjectSchedule["day"] ?? "";
    final start = subjectSchedule["time_start"]?.toString();
    final end = subjectSchedule["time_end"]?.toString();

    String timeStr = "";
    if (start != null && end != null) {
      try {
        final fmtStart = start.split(":").take(2).join(":");
        final fmtEnd = end.split(":").take(2).join(":");
        if (fmtStart.isNotEmpty && fmtEnd.isNotEmpty) {
          timeStr = ", $fmtStart-$fmtEnd";
        }
      } catch (e) {
        timeStr = "";
      }
    }

    data.add(
      Row(
        children: [
          Text(
            "[$type] $room $day$timeStr",
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
