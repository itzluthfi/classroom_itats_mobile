import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/subject_member/subject_member_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../models/subject_member.dart';
import 'package:flutter/services.dart';

class SubjectMemberBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const SubjectMemberBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<SubjectMemberBody> createState() => _SubjectMemberBodyState();
}

class _SubjectMemberBodyState extends State<SubjectMemberBody> {
  // Subject? _subject;
  String? _role;
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  _getUserRole() async {
    _role = await storage.read(key: "role");
  }

  static const platform = MethodChannel('com.itats.classroom/whatsapp');

  Future<void> _launchInBrowser(String phone) async {
    final urlString = "https://wa.me/$phone";

    try {
      // First try the custom native channel for Android
      final bool result =
          await platform.invokeMethod('launchWhatsApp', {'url': urlString});
      if (!result) {
        debugPrint('Could not launch via custom channel');
      }
    } on PlatformException catch (e) {
      debugPrint(
          "Failed to launch WhatsApp via MethodChannel: '${e.message}'.");
      // Fallback if needed but we assume Android will handle it
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _checkLoad();
  }

  _checkLoad() async {
    bool loaded = await widget.userRepository.getWidgetState('subject_member');
    if (!loaded) {
      setState(() {
        BlocProvider.of<SubjectMemberBloc>(context).add(
          GetSubjectMember(
            academicPeriodId: widget.subject.academicPeriodId,
            subjectId: widget.subject.subjectId,
            subjectClass: widget.subject.subjectClass,
            majorId: widget.subject.majorId,
          ),
        );
      });
      await widget.userRepository.setWidgetState('subject_member', true);
    }
  }

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<SubjectMemberBloc, SubjectMemberState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SubjectMemberLoaded) {
          // Identify members
          var dosenList = state.subjectMembers
              .where((m) =>
                  m.name == widget.subject.lecturerName || m.userId.length < 13)
              .toList();
          var mahasiswaList =
              state.subjectMembers.where((m) => m.userId.length >= 13).toList();

          // Current User (assuming first mahasiswa is the current user since the original code mapped index 1 to 'Anda')
          var currentUser =
              mahasiswaList.isNotEmpty ? mahasiswaList.first : null;
          var otherStudents =
              mahasiswaList.length > 1 ? mahasiswaList.sublist(1) : [];

          // Filter other students based on search query
          var filteredStudents = otherStudents.where((student) {
            final nameLower = student.name.toLowerCase();
            final nimLower = student.userId.toLowerCase();
            final searchLower = _searchQuery.toLowerCase();
            return nameLower.contains(searchLower) ||
                nimLower.contains(searchLower);
          }).toList();

          return Placeholder(
            color: Colors.transparent,
            child: RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                setState(() {
                  _getUserRole();
                  BlocProvider.of<SubjectMemberBloc>(context).add(
                    GetSubjectMember(
                      academicPeriodId: widget.subject.academicPeriodId,
                      subjectId: widget.subject.subjectId,
                      subjectClass: widget.subject.subjectClass,
                      majorId: widget.subject.majorId,
                    ),
                  );
                });
              },
              child: Container(
                color: const Color(0xFFF7F8FA), // Light grey background
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    // Header List Mahasiswa handled by AppBar natively, but if needed:
                    // const Center(
                    //   child: Text(
                    //     "List Mahasiswa",
                    //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    // const Gap(20),

                    // --- SECTION: DOSEN WALI ---
                    if (dosenList.isNotEmpty) ...[
                      const Text(
                        "DOSEN WALI",
                        style: TextStyle(
                            color: Color(0xFF8692A6),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                      const Gap(12),
                      ...dosenList
                          .map((dosen) => _buildDosenCard(dosen))
                          .toList(),
                      const Gap(24),
                    ],

                    // --- SECTION: PROFIL ANDA ---
                    if (currentUser != null && _role == "Mahasiswa") ...[
                      const Text(
                        "PROFIL ANDA",
                        style: TextStyle(
                            color: Color(0xFF8692A6),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                      const Gap(12),
                      _buildProfileCard(currentUser, screenWidth),
                      const Gap(24),
                    ],

                    // --- SECTION: DAFTAR MAHASISWA ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "DAFTAR MAHASISWA",
                          style: TextStyle(
                              color: Color(0xFF8692A6),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                        Text(
                          "${otherStudents.length} Mahasiswa",
                          style: const TextStyle(
                            color: Color(0xFF8692A6),
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    const Gap(16),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Cari nama atau NIM...",
                          hintStyle: TextStyle(color: Color(0xFFA0AABF)),
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xFFA0AABF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const Gap(16),

                    // List of Students
                    ...filteredStudents
                        .map((student) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildStudentCard(student),
                            ))
                        .toList(),

                    if (filteredStudents.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Tidak ada mahasiswa ditemukan",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    const Gap(40), // Bottom padding
                  ],
                ),
              ),
            ),
          );
        }

        if (state is SubjectMemberLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            _getUserRole();
            BlocProvider.of<SubjectMemberBloc>(context).add(
              GetSubjectMember(
                academicPeriodId: widget.subject.academicPeriodId,
                subjectId: widget.subject.subjectId,
                subjectClass: widget.subject.subjectClass,
                majorId: widget.subject.majorId,
              ),
            );
          },
          child: ListView(
            children: const [
              Gap(30),
              Center(
                child:
                    Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget for Dosen
  Widget _buildDosenCard(SubjectMember dosen) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar Placeholder
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey.shade100,
            child: const Icon(Icons.person, color: Colors.blueGrey, size: 30),
            // backgroundImage: AssetImage('assets/images/placeholder_dosen.jpg'), // Jika ada gambar asli
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dosen.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  "NIDN: ${dosen.userId}",
                  style:
                      const TextStyle(color: Color(0xFF8692A6), fontSize: 13),
                ),
              ],
            ),
          ),
          const Gap(10),
          // WhatsApp Button Blue
          InkWell(
            onTap: () {
              if (dosen.phoneNumber.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nomor WhatsApp Dosen belum terdaftar')),
                );
                return;
              }

              var phone = dosen.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Format nomor WhatsApp tidak valid')),
                );
                return;
              }

              if (phone.startsWith('0')) {
                phone = '62${phone.substring(1)}';
              }

              _launchInBrowser(phone);
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: const Color(0xFF1E5AD6), // Blue background
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E5AD6).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]),
              child: const Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper Widget for Current Selected Profil
  Widget _buildProfileCard(SubjectMember user, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.teal.shade100,
                child: const Icon(Icons.person, color: Colors.teal, size: 40),
                // backgroundImage: AssetImage('assets/images/placeholder_mahasiswa.jpg'),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      "NIM: ${user.userId}",
                      style: const TextStyle(
                          color: Color(0xFF1E5AD6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),
          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progress Akademik",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF4A5568))),
              Text("${((user.presence / 16) * 100).toInt()}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E5AD6))),
            ],
          ),
          const Gap(8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 12.0,
            percent: (user.presence / 16).clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF1F4F9),
            progressColor: const Color(0xFF1E5AD6),
            barRadius: const Radius.circular(10),
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }

  // Helper Widget for Other Mahasiswa
  Widget _buildStudentCard(SubjectMember student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.person, color: Colors.orange, size: 30),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  student.userId,
                  style:
                      const TextStyle(color: Color(0xFF8692A6), fontSize: 12),
                ),
              ],
            ),
          ),
          const Gap(10),
          // WhatsApp Button Outlined
          InkWell(
            onTap: () {
              if (student.phoneNumber.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Nomor WhatsApp Mahasiswa belum terdaftar')),
                );
                return;
              }

              var phone = student.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Format nomor WhatsApp tidak valid')),
                );
                return;
              }

              if (phone.startsWith('0')) {
                phone = '62${phone.substring(1)}';
              }

              _launchInBrowser(phone);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FE), // Light blue background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF1E5AD6), // Blue icon
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
