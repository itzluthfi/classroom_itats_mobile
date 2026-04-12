import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/upload_assignment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StudentTugasPage extends StatefulWidget {
  final AcademicPeriodRepository? academicPeriodRepository;

  const StudentTugasPage({super.key, this.academicPeriodRepository});

  @override
  State<StudentTugasPage> createState() => _StudentTugasPageState();
}

class _StudentTugasPageState extends State<StudentTugasPage> {

  // Data dinamis dari API
  List<Assignment> _allAssignments = [];
  List<Assignment> _filteredAssignments = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatusFilter = 'Belum';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Jika AcademicPeriodBloc sudah loaded ketika tab ini dibuka,
    // listener tidak akan firing ulang — jadi kita trigger manual di sini.
    final periodState = context.read<AcademicPeriodBloc>().state;
    if (periodState is AcademicPeriodLoaded &&
        periodState.currentAcademicPeriod.isNotEmpty) {
      context.read<AssignmentBloc>().add(
            GetActiveAssignments(period: periodState.currentAcademicPeriod));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getBadgeCount(String filter) {
    if (filter == 'Semua') {
      return _allAssignments.length;
    } else if (filter == 'Belum') {
      return _allAssignments
          .where((item) =>
              !item.sudahSubmit && item.dueDate.isAfter(DateTime.now()))
          .length;
    } else if (filter == 'Selesai') {
      return _allAssignments.where((item) => item.sudahSubmit).length;
    } else if (filter == 'Terlambat') {
      return _allAssignments
          .where((item) =>
              !item.sudahSubmit && item.dueDate.isBefore(DateTime.now()))
          .length;
    }
    return 0;
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAssignments = _allAssignments.where((item) {
        final matkul = item.subjectName.toLowerCase();
        final judul = item.assignmentTitle.toLowerCase();

        final isSelesai = item.sudahSubmit;
        final isTerlambat = !isSelesai && item.dueDate.isBefore(DateTime.now());
        final isBelum = !isSelesai && item.dueDate.isAfter(DateTime.now());

        // Search condition
        final matchesSearch = matkul.contains(query) || judul.contains(query);

        // Status condition
        bool matchesStatus = true;
        if (_selectedStatusFilter == 'Belum') {
          matchesStatus = isBelum;
        } else if (_selectedStatusFilter == 'Selesai') {
          matchesStatus = isSelesai;
        } else if (_selectedStatusFilter == 'Terlambat') {
          matchesStatus = isTerlambat;
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AcademicPeriodBloc, AcademicPeriodState>(
            listener: (context, state) {
              if (state is AcademicPeriodLoaded &&
                  state.currentAcademicPeriod.isNotEmpty) {
                context.read<AssignmentBloc>().add(
                    GetActiveAssignments(period: state.currentAcademicPeriod));
              }
            },
          ),
          BlocListener<AssignmentBloc, AssignmentState>(
            listener: (context, state) {
              if (state is AssignmentLoaded) {
                setState(() {
                  _allAssignments = state.assignments;
                  _filterData();
                });
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor:
              const Color(0xFFF8FAFC), // Warna latar belakang terang
          body: SafeArea(
            child: Column(
              children: [
                if (widget.academicPeriodRepository != null)
                  StudentAppBar(
                      academicPeriodRepository:
                          widget.academicPeriodRepository!),
                if (widget.academicPeriodRepository == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                            String periodName = "Loading...";
                            if (periodState is AcademicPeriodLoaded) {
                              try {
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
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: const Color(0xFF1E3A8A).withOpacity(0.12)),
                              ),
                              child: Text(
                                periodName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w800,
                                ),
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
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
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
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
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
                              _selectedStatusFilter =
                                  selected ? filter : 'Semua';
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
                  child: BlocBuilder<AssignmentBloc, AssignmentState>(
                    builder: (context, state) {
                      if (state is AssignmentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _filteredAssignments.isEmpty
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
                              itemCount: _filteredAssignments.length,
                              itemBuilder: (context, index) {
                                final data = _filteredAssignments[index];
                                return _buildTugasCard(data);
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTugasCard(Assignment data) {
    final bool sudahSubmit = data.sudahSubmit;
    final bool isLate = sudahSubmit
        ? (data.submissionDate != null &&
            data.dueDate.isBefore(data.submissionDate!))
        : data.dueDate.isBefore(DateTime.now());
    
    final bool isExpired = DateTime.now().isAfter(data.endTime ?? data.dueDate);

    Color badgeBgColor;
    Color badgeTextColor;
    String badgeText;

    if (sudahSubmit) {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeText = "SUDAH DIKUMPULKAN";
    } else if (isLate) {
      badgeBgColor = const Color(0xFFFEF2F2);
      badgeTextColor = const Color(0xFFEF4444);
      badgeText = "TERLAMBAT";
    } else {
      badgeBgColor = const Color(0xFFFFF7ED);
      badgeTextColor = const Color(0xFFF97316);
      badgeText = "BELUM MENGUMPULKAN";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sudahSubmit ? const Color(0xFFBBF7D0) : Colors.grey.shade200,
        ),
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
            // Header: judul + minggu + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.subjectName,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        data.assignmentTitle,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // Slate 100
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
                      ),
                      child: Text(
                        "Minggu ${data.weekId}",
                        style: const TextStyle(
                          color: Color(0xFF475569), // Slate 600
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(14),

            // Deadline / Kelas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isLate && !sudahSubmit
                            ? Icons.warning_amber_rounded
                            : Icons.access_time_filled_rounded,
                        size: 14,
                        color: isLate && !sudahSubmit
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          "Tenggat: ${DateFormat("d MMM y, HH:mm").format(data.dueDate)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isLate && !sudahSubmit
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF334155), // Slate 700
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Icon(Icons.class_rounded,
                          size: 14, color: const Color(0xFF64748B)),
                      const Gap(4),
                      Text(
                        "Kelas: ${data.subjectClass}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (data.endTime != null && data.endTime!.isAfter(data.dueDate)) ...[
                    const Gap(8),
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: isExpired && !sudahSubmit
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF64748B),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            "Batas Terlambat: ${DateFormat("d MMM y, HH:mm").format(data.endTime!)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired && !sudahSubmit
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Gap(16),

            // ── SECTION: Info submission (mirip assignments_body.dart) ──
            if (sudahSubmit) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.task_alt,
                            color: Color(0xFF10B981), size: 16),
                        const Gap(6),
                        const Expanded(
                          child: Text(
                            "Tugas Sudah Dikumpulkan",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isLate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Terlambat",
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Tanggal dikumpulkan
                    if (data.submissionDate != null) ...[
                      const Gap(6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.grey.shade500),
                          const Gap(4),
                          Text(
                            "Dikumpulkan: ${DateFormat("d MMM y, HH:mm").format(data.submissionDate!.toLocal())}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // File submission + tombol download
                    if (data.submissionLink.isNotEmpty || data.submissionFile.isNotEmpty) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined,
                                size: 16, color: Color(0xFF10B981)),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                data.submissionFile.isNotEmpty
                                    ? data.submissionFile
                                    : data.submissionLink.split('/').last,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined,
                                  size: 18, color: Color(0xFF10B981)),
                              onPressed: () {
                                BlocProvider.of<AssignmentBloc>(context).add(
                                  DownloadStudentAssignmentSubmission(
                                    fileLink: data.submissionLink.isNotEmpty
                                        ? data.submissionLink
                                        : data.submissionFile,
                                    fileName: data.submissionFile.isNotEmpty
                                        ? data.submissionFile
                                        : data.submissionLink.split('/').last,
                                  ),
                                );
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(12),
              // Tombol ubah submission
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isExpired ? null : () => _openUploadSheet(context, data),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("Ubah Submission",
                      style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    disabledForegroundColor: Colors.grey.shade400,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else ...[
              // Tombol upload (belum submit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isExpired ? null : () => _openUploadSheet(context, data),
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text("Kumpulkan Tugas",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5AD6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openUploadSheet(BuildContext ctx, Assignment data) {
    final bloc = ctx.read<AssignmentBloc>();
    final periodState = ctx.read<AcademicPeriodBloc>().state;
    final period = periodState is AcademicPeriodLoaded
        ? periodState.currentAcademicPeriod
        : '';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Wrap(
            children: [
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  BlocProvider.value(
                    value: bloc,
                    child: UploadAssignmentBody(
                      screenWidth: MediaQuery.of(sheetCtx).size.width,
                      assignmentId: data.assignmentId,
                      assignment: data,
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (period.isNotEmpty) {
        bloc.add(GetActiveAssignments(period: period));
      }
    });
  }
}
