import 'package:classroom_itats_mobile/models/study_material.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/microsoft_repository.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class LecturerCreateCollegeReportBody extends StatefulWidget {
  final SubjectReport subject;
  const LecturerCreateCollegeReportBody({super.key, required this.subject});

  @override
  State<LecturerCreateCollegeReportBody> createState() =>
      _LecturerCreateCollegeReportBodyState();
}

class _LecturerCreateCollegeReportBodyState
    extends State<LecturerCreateCollegeReportBody> {
  var collegeDateTextEditingController = TextEditingController();
  var weekTextEditingController = TextEditingController();
  var timeRealizationTextEditingController = TextEditingController();
  var multiSelectController = MultiSelectController<String>();
  var presenceLimitTextEditingController = TextEditingController();
  var collegeTypeEditingController = TextEditingController(text: "1");
  var materialRealizationTextEditingController = TextEditingController();
  List<Map<String, String>> materialTextEditingController =
      List.empty(growable: true);
  final _formKey = GlobalKey<FormState>();
  Set<int> _usedWeekIds = {};

  String? _capaianPembelajaran;
  String? _rencanaPembelajaran;
  bool _isLoadingRps = false;

  // MS Teams integration
  int _selectedCollegeType = 1;
  final _linkMeetController = TextEditingController();
  bool _isCreatingMeeting = false;
  final _msRepo = MicrosoftRepository();
  AppLinks? _appLinks;

  Future<void> _fetchRpsDetail(String weekId) async {
    setState(() {
      _isLoadingRps = true;
      _capaianPembelajaran = null;
      _rencanaPembelajaran = null;
    });

    try {
      final repo = RepositoryProvider.of<LectureRepository>(context);
      final res = await repo.getLectureRps(widget.subject.subjectId, weekId);
      if (res != null) {
        setState(() {
          _capaianPembelajaran = res['deskripsi_cp']?.toString();
          _rencanaPembelajaran = res['deskripsi_rp']?.toString();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRps = false;
        });
      }
    }
  }

  List<Week>? _teamWeeks;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StudyMaterialBloc>(context).add(const GetLecturerMaterial());
    // Baca minggu yang sudah ada laporannya dari LectureBloc
    final currentLectureState = BlocProvider.of<LectureBloc>(context).state;
    if (currentLectureState is LectureLoaded) {
      _usedWeekIds = currentLectureState.lectureReports
          .where((l) => l.weekID != null)
          .map((l) => l.weekID!)
          .toSet();
    }
    _fetchTeamWeeks();
    _initDeepLinkListener();
  }

  /// Mendengarkan deep link callback dari browser setelah OAuth
  void _initDeepLinkListener() {
    _appLinks = AppLinks();
    _appLinks!.uriLinkStream.listen((uri) async {
      if (uri.scheme == 'classroom-itats' &&
          uri.host == 'auth' &&
          uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']!;
        try {
          // Kirim code ke backend untuk ditukar token
          await _msRepo.handleCallback(code);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Akun Microsoft berhasil dihubungkan!'),
                backgroundColor: Color(0xFF16A34A),
              ),
            );
            // Setelah terhubung, langsung buat meeting
            await _createTeamsMeeting();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menghubungkan akun: $e'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        }
      }
    });
  }

  /// Membuat meeting MS Teams (dengan auto-login jika belum terhubung)
  Future<void> _createTeamsMeeting() async {
    if (!mounted) return;
    setState(() => _isCreatingMeeting = true);

    try {
      // Cek apakah sudah terhubung ke Microsoft
      final isLinked = await _msRepo.checkLinkedStatus();

      if (!isLinked) {
        // Belum terhubung — arahkan ke halaman OAuth Microsoft
        final result = await _msRepo.getAuthUrl();
        final authUrl = result['auth_url'] as String;
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        // Deep link listener akan menangkap callback dan memanggil _createTeamsMeeting() lagi
        return;
      }

      // Sudah terhubung — langsung buat meeting
      final subjectName = widget.subject.subjectName;
      final now = DateTime.now();
      // Waktu meeting default: sekarang + 30 menit selama 100 menit
      final start = now.add(const Duration(minutes: 30));
      final end = start.add(const Duration(minutes: 100));

      final joinUrl = await _msRepo.createMeeting(
        subject: 'Perkuliahan $subjectName - ${widget.subject.subjectClass}',
        startTime: start.toUtc().toIso8601String(),
        endTime: end.toUtc().toIso8601String(),
      );

      if (mounted) {
        setState(() {
          _linkMeetController.text = joinUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Link meeting berhasil dibuat!'),
            ]),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Jika error karena perlu login ulang
        final needsReauth = e.toString().contains('need_auth') ||
            e.toString().contains('login ulang');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              needsReauth ? 'Sesi berakhir, silakan hubungkan ulang akun Microsoft.' : 'Gagal membuat meeting: $e',
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        if (needsReauth) {
          // Reset status & minta login ulang
          final result = await _msRepo.getAuthUrl();
          final authUrl = result['auth_url'] as String;
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isCreatingMeeting = false);
    }
  }

  Future<void> _fetchTeamWeeks() async {
    try {
      final repo = RepositoryProvider.of<LectureRepository>(context);
      final weeks = await repo.getTeamWeeks(
        widget.subject.academicPeriodId,
        widget.subject.subjectId,
        widget.subject.subjectClass,
      );
      if (mounted) {
        setState(() {
          _teamWeeks = weeks;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    collegeDateTextEditingController.dispose();
    weekTextEditingController.dispose();
    timeRealizationTextEditingController.dispose();
    presenceLimitTextEditingController.dispose();
    collegeTypeEditingController.dispose();
    materialRealizationTextEditingController.dispose();
    _linkMeetController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1E5AD6)),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF1E5AD6), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyMaterialBloc, StudyMaterialState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is StudyMaterialLoaded) {
          return BlocConsumer<LectureBloc, LectureState>(
            listener: (context, lectureState) {
              if (lectureState is LectureCreateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Pelaporan berhasil disimpan'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              } else if (lectureState is LectureCreateFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Gagal menyimpan pelaporan'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, lectureState) {
              return _buildForm(context, state, lectureState);
            },
          );
        } else {
          return RefreshIndicator(
            color: const Color(0xFF1E5AD6),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 800));
              BlocProvider.of<StudyMaterialBloc>(context)
                  .add(const GetLecturerMaterial());
            },
            child: const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: Color(0xFF1E5AD6), strokeWidth: 3),
                        Gap(16),
                        Text("Memuat data materi...",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildForm(BuildContext context, StudyMaterialLoaded state, LectureState lectureState) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: RefreshIndicator(
        color: const Color(0xFF1E5AD6),
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          BlocProvider.of<StudyMaterialBloc>(context)
              .add(const GetLecturerMaterial());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject info header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF1E5AD6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF1E5AD6).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "[${widget.subject.collegeType}] ${widget.subject.subjectName}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              "Kelas ${widget.subject.subjectClass}  •  ${widget.subject.timeStart} - ${widget.subject.timeEnd}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),

                      // Form title
                      const Text(
                        "Buat Pelaporan Baru",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        "Isi semua form di bawah ini dengan benar",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Gap(20),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal Perkuliahan
                            _sectionLabel("Tanggal Perkuliahan"),
                            const Gap(8),
                            TextFormField(
                              controller: collegeDateTextEditingController,
                              readOnly: true,
                              decoration: _inputDecoration(
                                  "Pilih tanggal perkuliahan",
                                  Icons.calendar_today_outlined),
                              onTap: () async {
                                DateTime? pickdate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 90)),
                                );
                                if (pickdate != null) {
                                  setState(() {
                                    collegeDateTextEditingController.text =
                                        DateFormat("yyyy-MM-dd")
                                            .format(pickdate);
                                  });
                                }
                              },
                            ),
                            const Gap(16),

                            // Minggu
                            _sectionLabel("Minggu Perkuliahan"),
                            const Gap(8),
                            DropdownMenu<String>(
                              width: double.infinity,
                              label: const Text("Pilih Minggu"),
                              initialSelection:
                                  weekTextEditingController.text.isEmpty
                                      ? null
                                      : weekTextEditingController.text,
                              onSelected: (value) {
                                weekTextEditingController.text = value ?? "";
                                if (value != null && value.isNotEmpty) {
                                  _fetchRpsDetail(value);
                                }
                              },
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E5AD6), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              menuStyle: const MenuStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                fixedSize: WidgetStatePropertyAll(
                                    Size.fromHeight(200)),
                              ),
                              dropdownMenuEntries: (_teamWeeks ?? state.weekMaterials).map((week) {
                                final isUsed = _usedWeekIds.contains(week.weekId);
                                return DropdownMenuEntry<String>(
                                  value: "${week.weekId}",
                                  label: "Minggu Ke - ${week.weekId}${week.note.isNotEmpty ? '  •  ${week.note}' : ''}",
                                  enabled: !isUsed,
                                  trailingIcon: isUsed
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "Sudah ada",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF059669),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              }).toList(),
                            ),
                            
                            // RPS Display (Capaian & Rencana)
                            if (_isLoadingRps)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            if (!_isLoadingRps && (_capaianPembelajaran != null || _rencanaPembelajaran != null)) ...[
                              const Gap(16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.auto_stories_outlined, color: Color(0xFF16A34A), size: 18),
                                        const Gap(8),
                                        const Text(
                                          "Target Pembelajaran (RPS)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF166534),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(12),
                                    if (_capaianPembelajaran != null && _capaianPembelajaran!.isNotEmpty) ...[
                                      const Text(
                                        "Capaian Pembelajaran:",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF166534), fontSize: 13),
                                      ),
                                      const Gap(4),
                                      Text(
                                        _capaianPembelajaran!,
                                        style: const TextStyle(color: Color(0xFF14532D), fontSize: 13, height: 1.4),
                                      ),
                                      const Gap(8),
                                    ],
                                    if (_rencanaPembelajaran != null && _rencanaPembelajaran!.isNotEmpty) ...[
                                      const Text(
                                        "Rencana Pembelajaran:",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF166534), fontSize: 13),
                                      ),
                                      const Gap(4),
                                      Text(
                                        _rencanaPembelajaran!,
                                        style: const TextStyle(color: Color(0xFF14532D), fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            const Gap(16),

                            // Realisasi Waktu
                            _sectionLabel("Realisasi Waktu (menit)"),
                            const Gap(8),
                            TextFormField(
                              controller: timeRealizationTextEditingController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                  "Realisasi Waktu", Icons.timer_outlined),
                            ),
                            const Gap(16),

                            // Pilih Materi
                            _sectionLabel("Materi yang Disampaikan"),
                            const Gap(8),
                            MultiDropdown<String>(
                              items: _materialMap(state.studyMaterials),
                              controller: multiSelectController,
                              enabled: true,
                              searchEnabled: true,
                              chipDecoration: ChipDecoration(
                                backgroundColor:
                                    const Color(0xFF1E5AD6).withOpacity(0.1),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF1E5AD6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                wrap: true,
                                runSpacing: 4,
                                spacing: 6,
                              ),
                              fieldDecoration: FieldDecoration(
                                padding: const EdgeInsets.all(14),
                                hintText: "Pilih Materi",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 14),
                                prefixIcon: const Icon(Icons.book_outlined,
                                    size: 18, color: Color(0xFF1E5AD6)),
                                showClearIcon: false,
                                backgroundColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E5AD6), width: 1.5),
                                ),
                              ),
                              dropdownDecoration: const DropdownDecoration(
                                maxHeight: 300,
                                marginTop: 4,
                                header: Padding(padding: EdgeInsets.all(8)),
                              ),
                              dropdownItemDecoration: const DropdownItemDecoration(
                                selectedIcon: Icon(Icons.check_box,
                                    color: Color(0xFF1E5AD6)),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? "Pilih materi"
                                      : null,
                              onSelectionChange: (selectedItems) {
                                materialTextEditingController =
                                    List.empty(growable: true);
                                for (var element in selectedItems) {
                                  materialTextEditingController
                                      .add({"material_id": element});
                                }
                              },
                            ),
                            const Gap(16),

                            // Batas Presensi
                            _sectionLabel("Batas Waktu Presensi"),
                            const Gap(8),
                            TextFormField(
                              controller: presenceLimitTextEditingController,
                              readOnly: true,
                              decoration: _inputDecoration(
                                  "Pilih batas presensi",
                                  Icons.schedule_outlined),
                              onTap: () async {
                                DateTime? pickdate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 90)),
                                );
                                if (pickdate != null) {
                                  TimeOfDay? picktime = await showTimePicker(
                                    context: context,
                                    initialEntryMode:
                                        TimePickerEntryMode.input,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picktime != null) {
                                    setState(() {
                                      presenceLimitTextEditingController.text =
                                          DateFormat("yyyy-MM-dd HH:mm:ss")
                                              .format(DateTime(
                                        pickdate.year,
                                        pickdate.month,
                                        pickdate.day,
                                        picktime.hour,
                                        picktime.minute,
                                      ));
                                    });
                                  }
                                }
                              },
                            ),
                            const Gap(16),

                            // Jenis Perkuliahan
                            _sectionLabel("Jenis Perkuliahan"),
                            const Gap(8),
                            DropdownMenu<int>(
                              width: double.infinity,
                              label: const Text("Jenis Perkuliahan"),
                              initialSelection: int.tryParse(
                                  collegeTypeEditingController.text),
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E5AD6), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              menuStyle: MenuStyle(
                                shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                fixedSize: WidgetStatePropertyAll(
                                    Size.fromWidth(
                                        MediaQuery.of(context).size.width -
                                            80)),
                              ),
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(value: 1, label: "Offline (Tatap Muka)"),
                                DropdownMenuEntry(value: 2, label: "Hybrid (Online)"),
                              ],
                              onSelected: (value) {
                                collegeTypeEditingController.text =
                                    (value ?? 1).toString();
                                setState(() {
                                  _selectedCollegeType = value ?? 1;
                                });
                              },
                            ),

                            // ── Field Link Meeting (hanya jika Hybrid) ──────────
                            if (_selectedCollegeType == 2) ...[
                              const Gap(16),
                              _sectionLabel("Link Meeting"),
                              const Gap(8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _linkMeetController,
                                      decoration: InputDecoration(
                                        hintText: 'https://teams.microsoft.com/...',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13),
                                        prefixIcon: const Icon(
                                            Icons.video_call_outlined,
                                            size: 18,
                                            color: Color(0xFF0078D4)),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF0078D4),
                                              width: 1.5),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                      ),
                                      validator: (_selectedCollegeType == 2)
                                          ? (v) => (v == null || v.isEmpty)
                                              ? 'Link meeting wajib diisi untuk kelas Hybrid'
                                              : null
                                          : null,
                                    ),
                                  ),
                                  const Gap(10),
                                  // Tombol Buat via Teams
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isCreatingMeeting
                                          ? null
                                          : _createTeamsMeeting,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0078D4),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: _isCreatingMeeting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons.video_call_rounded,
                                                    size: 20),
                                                SizedBox(height: 2),
                                                Text('Teams',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Gap(16),

                            // Realisasi Materi
                            _sectionLabel("Realisasi Materi", isRequired: false),
                            const Gap(8),
                            TextFormField(
                              controller:
                                  materialRealizationTextEditingController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Tuliskan realisasi materi...",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 14),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 10, top: 14),
                                  child: Icon(Icons.notes_outlined,
                                      size: 18,
                                      color: const Color(0xFF1E5AD6)),
                                ),
                                prefixIconConstraints:
                                    const BoxConstraints(minWidth: 0),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E5AD6), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(20),

                      // Submit button
                      BlocBuilder<LectureBloc, LectureState>(
                        builder: (context, lectureState2) {
                          final isLoading = lectureState is LectureCreateLoading ||
                              lectureState2 is LectureCreateLoading;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (collegeDateTextEditingController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Tanggal perkuliahan harus diisi'),
                                            backgroundColor: const Color(0xFFF59E0B),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                        return;
                                      }
                                      if (weekTextEditingController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Minggu perkuliahan harus dipilih'),
                                            backgroundColor: const Color(0xFFF59E0B),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                        return;
                                      }
                                      BlocProvider.of<LectureBloc>(context)
                                          .add(CreateLectureReport(
                                        academicPeriodId:
                                            widget.subject.academicPeriodId,
                                        subjectId: widget.subject.subjectId,
                                        majorId: widget.subject.majorId,
                                        lecturerId: widget.subject.lecturerId,
                                        subjectClass:
                                            widget.subject.subjectClass,
                                        lectureSchedule:
                                            "${collegeDateTextEditingController.text}T00:00:00Z",
                                        lectureType:
                                            widget.subject.collegeType,
                                        subjectCredit:
                                            widget.subject.subjectCredits,
                                        hourId: widget.subject.hourId,
                                        material: materialTextEditingController,
                                        entryTime:
                                            "${DateTime.now().toString().replaceAll(" ", "T")}Z",
                                        approvalStatus: 0,
                                        weekId: int.tryParse(
                                                weekTextEditingController
                                                    .text) ??
                                            0,
                                        timeRealization: int.tryParse(
                                                timeRealizationTextEditingController
                                                    .text) ??
                                            0,
                                        materialRealization:
                                            materialRealizationTextEditingController
                                                .text,
                                        presenceLimit:
                                            "${presenceLimitTextEditingController.text.replaceAll(" ", "T")}Z",
                                         collegeType: int.tryParse(
                                                collegeTypeEditingController
                                                    .text) ??
                                            1,
                                        linkMeet: _linkMeetController.text,
                                      ));
                                      multiSelectController.clearAll();
                                      collegeDateTextEditingController.text =
                                          "";
                                      weekTextEditingController.text = "";
                                      timeRealizationTextEditingController
                                          .text = "";
                                      materialTextEditingController =
                                          List.empty(growable: true);
                                      presenceLimitTextEditingController.text =
                                          "";
                                      collegeTypeEditingController.text = "1";
                                      materialRealizationTextEditingController
                                          .text = "";
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.check_circle_outline,
                                      size: 18),
                              label: Text(
                                isLoading ? "Menyimpan..." : "Simpan Pelaporan",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E5AD6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool isRequired = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          if (!isRequired)
             TextSpan(
               text: ' (Opsional)',
               style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
             ),
        ],
      ),
    );
  }
}

List<DropdownItem<String>> _materialMap(List<StudyMaterial> materials) {
  // Pisahkan materi yang belum pernah dipakai dan yang sudah pernah dipakai
  final unused = materials.where((m) => m.lectureID.isEmpty).toList()
    ..sort((a, b) => a.materialTitle.compareTo(b.materialTitle));
  final used = materials.where((m) => m.lectureID.isNotEmpty).toList()
    ..sort((a, b) => a.materialTitle.compareTo(b.materialTitle));

  final items = <DropdownItem<String>>[];

  if (unused.isNotEmpty) {
    // Header grup: Belum Digunakan
    items.add(DropdownItem(
      value: '__header_unused__',
      label: '📚  Belum Pernah Dipakai  (${unused.length})',
      disabled: true,
    ));
    items.addAll(unused.map((e) => DropdownItem(
          label: e.materialTitle,
          value: e.materialId,
        )));
  }

  if (used.isNotEmpty) {
    // Header grup: Sudah Pernah Dipakai
    items.add(DropdownItem(
      value: '__header_used__',
      label: '🔖  Pernah Dipakai  (${used.length})',
      disabled: true,
    ));
    items.addAll(used.map((e) => DropdownItem(
          label: e.materialTitle,
          value: e.materialId,
        )));
  }

  return items;
}
