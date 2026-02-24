import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentTugasPage extends StatefulWidget {
  final AcademicPeriodRepository? academicPeriodRepository;

  const StudentTugasPage({super.key, this.academicPeriodRepository});

  @override
  State<StudentTugasPage> createState() => _StudentTugasPageState();
}

class _StudentTugasPageState extends State<StudentTugasPage> {
  // Enum untuk status tugas (Sesuai mockup)
  // ignore: constant_identifier_names
  static const int STATUS_BELUM = 0;
  // ignore: constant_identifier_names
  static const int STATUS_TERLAMBAT = 1;
  // ignore: constant_identifier_names
  static const int STATUS_SELESAI = 2;

  // Data Hardcode untuk menguji desain
  final List<Map<String, dynamic>> mockData = [
    {
      "mata_kuliah": "KECERDASAN BUATAN",
      "judul_tugas": "Tugas 1: Neural Networks Architectures",
      "minggu": "Minggu 8",
      "deadline": "25 Okt, 23:59",
      "kelas": "IF-44-01",
      "status": STATUS_BELUM,
    },
    {
      "mata_kuliah": "PEMROGRAMAN WEB",
      "judul_tugas": "Project 2: RESTful API Integration",
      "minggu": "Minggu 7",
      "deadline": "18 Okt, 23:59",
      "kelas": "IF-44-01",
      "status": STATUS_TERLAMBAT,
    },
    {
      "mata_kuliah": "BASIS DATA",
      "judul_tugas": "Latihan: Normalisasi Database",
      "minggu": "Minggu 7",
      "dikumpulkan": "17 Okt",
      "kelas": "IF-44-01",
      "status": STATUS_SELESAI,
      "file_name": "tugas_basis_data_v1.pdf",
      "file_info": "Uploaded 17 Oct • 2.4 MB",
    },
    {
      "mata_kuliah": "KEAMANAN SIBER",
      "judul_tugas": "Analisis: Vulnerability Scanning",
      "minggu": "Minggu 9",
      "deadline": "1 Nov, 23:59",
      "kelas": "IF-44-01",
      "status": STATUS_BELUM,
    },
  ];

  late List<Map<String, dynamic>> _filteredData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(mockData);
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = mockData.where((item) {
        final matkul = item['mata_kuliah'].toString().toLowerCase();
        final judul = item['judul_tugas'].toString().toLowerCase();
        return matkul.contains(query) || judul.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar belakang terang
      body: SafeArea(
        child: Column(
          children: [
            if (widget.academicPeriodRepository != null)
              StudentAppBar(
                  academicPeriodRepository: widget.academicPeriodRepository!),
            if (widget.academicPeriodRepository == null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                color: Colors.white,
                child: const Text('Daftar Tugas',
                    style: TextStyle(
                        color: Color(0xFF14307E),
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            // Bagian Search Bar Custom
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari tugas...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                ),
              ),
            ),

            // List Tugas Berupa Custom Cards
            Expanded(
              child: _filteredData.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ditemukan tugas\ndengan kata kunci tersebut.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        final data = _filteredData[index];
                        return _buildTugasCard(data);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> data) {
    int status = data['status'];
    Color badgeBgColor;
    Color badgeTextColor;
    String badgeText;

    if (status == STATUS_BELUM) {
      badgeBgColor = const Color(0xFFFFF7ED); // Sangat light orange
      badgeTextColor = const Color(0xFFF97316); // Orange tegas
      badgeText = "BELUM MENGUMPULKAN";
    } else if (status == STATUS_TERLAMBAT) {
      badgeBgColor = const Color(0xFFFEF2F2); // Sangat light red
      badgeTextColor = const Color(0xFFEF4444); // Merah tegas
      badgeText = "TERLAMBAT";
    } else {
      badgeBgColor = const Color(0xFFECFDF5); // Sangat light green
      badgeTextColor = const Color(0xFF10B981); // Hijau cerah
      badgeText = "SUDAH DIKUMPULKAN";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Minggu saja
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  data['minggu'],
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Gap(8),

            // Konten Tengah: Mata Kuliah & Judul Tugas
            Text(
              data['mata_kuliah'],
              style: const TextStyle(
                color: Color(0xFF3B82F6), // Biru Cyan seperti desain
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(4),
            Text(
              data['judul_tugas'],
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const Gap(12),

            // Baris Detail info
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        status == STATUS_SELESAI
                            ? Icons.check_circle_outline
                            : Icons.access_time,
                        size: 14,
                        color: status == STATUS_SELESAI
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade600),
                    const Gap(4),
                    Text(
                      status == STATUS_SELESAI
                          ? "Dikumpulkan: ${data['dikumpulkan']}"
                          : "Deadline: ${data['deadline']}",
                      style: TextStyle(
                        color: status == STATUS_SELESAI
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 14, color: Colors.grey.shade600),
                    const Gap(4),
                    Text(
                      "Kelas: ${data['kelas']}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(12),

            // Badge Status ditempatkan di atas aksi (Upload file)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Gap(16),

            // Baris Aksi Bawah
            if (status == STATUS_SELESAI)
              // Tampilan File yg sudah Uploaded
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7), // Sangat light green
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.insert_drive_file,
                          color: Color(0xFF10B981), size: 18),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['file_name'],
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data['file_info'],
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download_outlined,
                          color: Color(0xFF64748B)),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )
            else
              // Tampilan Tombol Upload
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text(
                    "Unggah Tugas",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
