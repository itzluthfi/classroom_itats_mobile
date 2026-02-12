import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class LecturerSubjectReportCard extends StatefulWidget {
  final String imagePath;
  final SubjectReport subject;
  final void Function() onTap;

  const LecturerSubjectReportCard({
    super.key,
    required this.imagePath,
    required this.subject,
    required this.onTap,
  });

  @override
  State<LecturerSubjectReportCard> createState() =>
      _LecturerSubjectReportCardState();
}

class _LecturerSubjectReportCardState extends State<LecturerSubjectReportCard> {
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
                            Text(
                              "[${widget.subject.collegeType}] ${widget.subject.roomId} ${widget.subject.day}, ${DateFormat("HH:mm").format(DateFormat().add_Hms().parse(widget.subject.timeStart))}-${DateFormat("HH:mm").format(DateFormat().add_Hms().parse(widget.subject.timeEnd))}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        const Gap(20),
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
