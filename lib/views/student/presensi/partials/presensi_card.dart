import 'package:classroom_itats_mobile/models/active_presence.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PresensiCard extends StatelessWidget {
  final ActivePresence presence;
  final VoidCallback onCardTap;

  const PresensiCard({
    super.key,
    required this.presence,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final kul = presence.kul;

    // Format the date (e.g., 2026-02-24T00:00:00Z -> Sel, 24 Feb 2026)
    String dateStr = "";
    try {
      final date = DateTime.parse(kul.lectureSchedule);
      dateStr = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      dateStr = kul.lectureSchedule.split('T').first;
    }

    // Border color logic
    final borderColor = presence.sudahPresensi
        ? const Color(0xFFA5D6A7) // Light Green Border
        : const Color(0xFFFFCC80); // Light Orange Border

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Subject Name & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${kul.subjectName} (Kelas ${kul.subjectClass})",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        "Minggu ke-${kul.weekId}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7), // Sky blue
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: presence.sudahPresensi
                        ? const Color(0xFFD1FAE5) // Light Emerald
                        : (presence.isHabisWaktu
                            ? const Color(0xFFFEE2E2) // Light Red
                            : const Color(0xFFFFEDD5)), // Light Orange
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    presence.sudahPresensi
                        ? "Hadir"
                        : (presence.isHabisWaktu
                            ? "Waktu Habis"
                            : "Belum Absen"),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: presence.sudahPresensi
                          ? const Color(0xFF059669) // Emerald Green
                          : (presence.isHabisWaktu
                              ? const Color(0xFFDC2626) // Red Text
                              : const Color(0xFFEA580C)), // Orange Text
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Details section rows
            _buildDetailRow(Icons.access_time_outlined,
                "$dateStr,  ${kul.timeStart} - ${kul.timeEnd}"),
            const Gap(8),
            _buildDetailRow(Icons.class_outlined,
                "${kul.collegeTypeName} (${kul.lectureTypeName})"),
            const Gap(8),
            _buildDetailRow(
                Icons.menu_book,
                kul.materialRealization.isNotEmpty
                    ? kul.materialRealization
                    : "Materi belum diisi",
                maxLines: 2),

            const Gap(20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (presence.sudahPresensi || presence.isHabisWaktu)
                    ? null
                    : onCardTap,
                icon: Icon(
                  presence.sudahPresensi
                      ? Icons.check_circle_outline
                      : (presence.isHabisWaktu
                          ? Icons.timer_off
                          : Icons.fingerprint),
                  size: 20,
                  color: (presence.sudahPresensi || presence.isHabisWaktu)
                      ? const Color(0xFF64748B)
                      : Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (presence.sudahPresensi || presence.isHabisWaktu)
                          ? const Color(0xFFE2E8F0) // Gray disabled background
                          : const Color(0xFF1E3A8A), // Deep Blue Button color
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                label: Text(
                  presence.sudahPresensi
                      ? "Sudah Melakukan Presensi"
                      : (presence.isHabisWaktu
                          ? "Batas Waktu Habis"
                          : "Isi Presensi Sekarang"),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const Gap(12),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569), // Slate gray medium
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
