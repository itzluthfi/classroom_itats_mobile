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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Color Overlay to emulate the mockups (greenish/dark tint)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3D3E).withOpacity(0.4), // Dark greenish-blue overlay
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.subject.subjectCredits} SKS",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.people_alt_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.subject.totalStudent} Mhs",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subject.subjectName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _subjectRoomRows(
                                    widget.subject.subjectSchedule),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.subject.subjectClass,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
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

  if (subjectSchedules.isEmpty) {
    data.add(const Text(
      "Belum ada jadwal",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      ),
    ));
    return data;
  }

  for (var subjectSchedule in subjectSchedules) {
    // Safety check for keys
    final type = subjectSchedule["subject_type"] ?? "-";
    final room = subjectSchedule["subject_room"] ?? "-";
    final day = subjectSchedule["day"] ?? "";
    final start = subjectSchedule["time_start"];
    final end = subjectSchedule["time_end"];

    String timeStr = "";
    if (start != null && end != null) {
      try {
        final fmtStart = start.toString().split(":").take(2).join(":");
        final fmtEnd = end.toString().split(":").take(2).join(":");
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
              fontSize: 16,
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
