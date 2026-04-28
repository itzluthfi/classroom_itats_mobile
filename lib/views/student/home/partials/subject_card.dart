import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:flutter/material.dart';

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

    // Check if any schedule has an active class status
    final hasActiveStatus = widget.subject.subjectSchedule.any(
      (s) => (s["class_status"] ?? "").toString().isNotEmpty,
    );

    return Placeholder(
      color: Colors.transparent,
      child: SizedBox(
        height: hasActiveStatus ? 210 : 180,
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
                      color: const Color(0xFF0F3D3E).withOpacity(
                          0.4), // Dark greenish-blue overlay with reduced opacity
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject.lecturerName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
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
    final classStatus = (subjectSchedule["class_status"] ?? "").toString();

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
          Flexible(
            child: Text(
              "[$type] $room $day$timeStr",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    // Class status badge
    if (classStatus.isNotEmpty) {
      data.add(
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: _ClassStatusBadge(status: classStatus),
        ),
      );
    }
  }
  return data;
}

class _ClassStatusBadge extends StatefulWidget {
  final String status;

  const _ClassStatusBadge({required this.status});

  @override
  State<_ClassStatusBadge> createState() => _ClassStatusBadgeState();
}

class _ClassStatusBadgeState extends State<_ClassStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.status == "sedang_berlangsung") {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(widget.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: config.gradientColors.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == "sedang_berlangsung")
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_animation.value),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(_animation.value * 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Icon(
              config.icon,
              size: 13,
              color: Colors.white,
            ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}

_StatusConfig _getStatusConfig(String status) {
  switch (status) {
    case "sedang_berlangsung":
      return const _StatusConfig(
        label: "Sedang Berlangsung",
        icon: Icons.circle,
        gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
      );
    case "kunci_diambil":
      return const _StatusConfig(
        label: "Kunci Diambil",
        icon: Icons.vpn_key_rounded,
        gradientColors: [Color(0xFFD97706), Color(0xFFF59E0B)],
      );
    case "jadwal_aktif":
      return const _StatusConfig(
        label: "Jadwal Aktif",
        icon: Icons.access_time_filled_rounded,
        gradientColors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
      );
    default:
      return const _StatusConfig(
        label: "",
        icon: Icons.circle,
        gradientColors: [Colors.grey, Colors.grey],
      );
  }
}

