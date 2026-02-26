import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String _selectedStatusFilter = 'Semua';

  // Get status options
  final List<String> _statusOptions = [
    'Semua',
    'Belum',
    'Selesai',
    'Terlambat'
  ];

  @override
  void initState() {
    super.initState();
    _filterData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getBadgeCount(String filter) {
    if (filter == 'Semua') {
      return mockData.length;
    } else if (filter == 'Belum') {
      return mockData.where((item) => item['status'] == STATUS_BELUM).length;
    } else if (filter == 'Selesai') {
      return mockData.where((item) => item['status'] == STATUS_SELESAI).length;
    } else if (filter == 'Terlambat') {
      return mockData
          .where((item) => item['status'] == STATUS_TERLAMBAT)
          .length;
    }
    return 0;
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = mockData.where((item) {
        final matkul = item['mata_kuliah'].toString().toLowerCase();
        final judul = item['judul_tugas'].toString().toLowerCase();
        final status = item['status'] as int;

        // Search condition
        final matchesSearch = matkul.contains(query) || judul.contains(query);

        // Status condition
        bool matchesStatus = true;
        if (_selectedStatusFilter == 'Belum') {
          matchesStatus = status == STATUS_BELUM;
        } else if (_selectedStatusFilter == 'Selesai') {
          matchesStatus = status == STATUS_SELESAI;
        } else if (_selectedStatusFilter == 'Terlambat') {
          matchesStatus = status == STATUS_TERLAMBAT;
        }

        return matchesSearch && matchesStatus;
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
            // Header "Tugas Aktif"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
              color: const Color(0xFFF8FAFC),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      "Tugas Aktif (${_getBadgeCount('Semua')})",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.academicPeriodRepository != null)
                    BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
                      builder: (context, periodState) {
                        String periodName = "Memuat periode...";
                        if (periodState is AcademicPeriodLoaded) {
                          try {
                            // Find the currently active academic period description safely
                            final matched =
                                periodState.academicPeriod.firstWhere(
                              (p) =>
                                  p.academicPeriodId ==
                                  periodState.currentAcademicPeriod,
                            );
                            periodName = matched.academicPeriodDecription;
                          } catch (e) {
                            periodName = periodState.currentAcademicPeriod;
                          }
                        }
                        return Text(
                          periodName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            // Bagian Search Bar Custom
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari tugas atau matakuliah...",
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF14307E)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFF14307E), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Status & Matkul Rows
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _statusOptions.map((String filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(filter),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selectedStatusFilter == filter
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getBadgeCount(filter).toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _selectedStatusFilter == filter
                                    ? Colors.white
                                    : Colors.blueGrey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      selected: _selectedStatusFilter == filter,
                      selectedColor: const Color(0xFF1E3A8A),
                      checkmarkColor: Colors.transparent,
                      showCheckmark: false,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      labelStyle: TextStyle(
                        color: _selectedStatusFilter == filter
                            ? Colors.white
                            : Colors.blueGrey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _selectedStatusFilter == filter
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedStatusFilter = selected ? filter : 'Semua';
                          _filterData();
                        });
                      },
                    ),
                  );
                }).toList(),
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
