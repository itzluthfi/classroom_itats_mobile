import 'dart:io';

import 'package:classroom_itats_mobile/models/profile.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/profile/profile_bloc.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const ProfileBody({super.key, required this.academicPeriodRepository});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  File? image;
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final Color primaryColor = const Color(0xFF14307E);
  final Color placeholderColor = const Color(0xFFF0B384);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  List<Subject> _fullSubjects = [];

  void _loadProfile() async {
    final period = await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    if (mounted) {
      context.read<ProfileBloc>().add(GetStudentProfile(academicPeriod: period));
      
      // Fetch full subjects to enable redirection
      final subjects = await SubjectRepository().getSubjects(period: period);
      if (mounted) {
        setState(() {
          _fullSubjects = subjects;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (emailController.text == "" && phoneNumberController.text == "") {
            emailController.text = state.profile.email;
            phoneNumberController.text = state.profile.phoneNumber;
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              _loadProfile();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildHeader(state.profile),
                const Gap(32),
                _buildStats(state.profile),
                const Gap(32),
                _buildSubjectList(state.profile.studentSubjectPresences),
              ],
            ),
          );
        }

        if (state is ProfileLoadFailed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const Gap(16),
                const Text("Gagal memuat profil mahasiswa"),
                TextButton(
                  onPressed: _loadProfile,
                  child: const Text("Coba Lagi"),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildHeader(Profile profile) {
    // Build the base URL correctly
    String webUrl = dotenv.get("WEB_URL");
    String webProtocol = dotenv.get("WEB_PROTOCOL");
    String baseUrl = webUrl.startsWith("http") ? webUrl : "$webProtocol$webUrl";
    String photoUrl = "$baseUrl/storage/img_mhs/${profile.photo}";

    bool hasPhoto = profile.photo.isNotEmpty && 
                   profile.photo != "null" && 
                   profile.photo != "undefined" &&
                   profile.photo != "default.png";

    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: placeholderColor,
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          headers: const {"Connection": "Keep-Alive"},
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                size: 80, color: Colors.white);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            );
                          },
                        )
                      : const Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditProfileModal(profile),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const Gap(24),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(4),
        Text(
          profile.userId,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Profile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Kehadiran",
            percent: profile.totalPresence > 0 ? profile.presence / profile.totalPresence : 0.0,
            color: Colors.blue.shade700,
          ),
        ),
        const Gap(16),
        Expanded(
          child: _buildStatCard(
            title: "Tugas Selesai",
            percent: profile.totalAssignment > 0 ? profile.assignmentSubmited / profile.totalAssignment : 0.0,
            color: Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required double percent, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 8,
            percent: percent,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
            center: Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const Gap(12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(List<StudentSubjectPresence> presences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "Riwayat Kehadiran",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primaryColor,
            ),
          ),
        ),
        const Gap(16),
        ...presences.map((p) => _buildSubjectItem(p)),
      ],
    );
  }

  Widget _buildSubjectItem(StudentSubjectPresence presence) {
    final double percent = presence.totalPresence > 0 ? presence.presence / presence.totalPresence : 0.0;
    
    return GestureDetector(
      onTap: () {
        // Find the full subject object
        final subject = _fullSubjects.firstWhere(
          (s) => s.subjectId == presence.subjectId && s.subjectClass == presence.subjectClass,
          orElse: () => Subject(
            subjectId: presence.subjectId,
            subjectName: presence.subjectName,
            subjectClass: presence.subjectClass,
            activityMasterId: presence.activityMasterId,
            academicPeriodId: "", 
            lecturerId: "", 
            lecturerName: "", 
            majorId: "", 
            majorName: "", 
            subjectCredits: 0, 
            subjectSchedule: [], 
            totalStudent: 0,
          ),
        );
        
        // Set tab to Presensi (Index 1) and navigate
        context.read<PageIndexCubit>().pageClicked(1);
        Navigator.pushNamed(context, "/student/subject", arguments: subject);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 24,
              lineWidth: 5,
              percent: percent,
              animation: true,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: primaryColor,
              backgroundColor: primaryColor.withOpacity(0.1),
              center: Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presence.subjectName,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Kelas ${presence.subjectClass}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showEditProfileModal(Profile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(24),
                const Text(
                  "Update Profile",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const Gap(8),
                Text(
                  "Perbarui informasi kontak dan foto profil Anda",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Gap(32),
                
                // Photo Picker
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await showModalBottomSheet<XFile>(
                            context: context,
                            builder: (context) => _buildImageSourcePicker(context, picker),
                          );
                          
                          if (pickedFile != null) {
                            setState(() => image = File(pickedFile.path));
                            setModalState(() {}); // Refresh modal UI
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: image != null ? FileImage(image!) : null,
                              child: image == null ? const Icon(Icons.add_a_photo_rounded, size: 32, color: Colors.grey) : null,
                            ),
                            if (image != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => image = null);
                                    setModalState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      const Text("Klik untuk ganti foto", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                const Gap(32),
                CustomTextField(
                  label: "Email",
                  controller: emailController,
                  isPassword: false,
                  width: double.infinity,
                  height: 60,
                ),
                const Gap(20),
                CustomTextField(
                  label: "Nomor Telpon",
                  controller: phoneNumberController,
                  isPassword: false,
                  width: double.infinity,
                  height: 60,
                ),
                const Gap(32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    var path = "";
                    var filename = "";
                    if (image != null) {
                      path = image!.path;
                      filename = image!.path.split('/').last;
                    }
                    
                    context.read<ProfileBloc>().add(UpdateStudentProfile(
                      email: emailController.text,
                      phoneNumber: phoneNumberController.text,
                      filepath: path,
                      filename: filename,
                    ));
                    
                    Navigator.pop(context);
                    
                    // Show success snackbar (simplified)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil berhasil diperbarui!")),
                    );
                    
                    // Reload profile
                    final academicPeriod = await widget.academicPeriodRepository.getCurrentAcademicPeriod();
                    if (mounted) {
                      context.read<ProfileBloc>().add(GetStudentProfile(academicPeriod: academicPeriod));
                    }
                    
                    image = null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Terapkan Perubahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSourcePicker(BuildContext context, ImagePicker picker) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Pilih Sumber Gambar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceButton(
                icon: Icons.camera_alt_rounded,
                label: "Kamera",
                color: Colors.orange,
                onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.camera)),
              ),
              _buildSourceButton(
                icon: Icons.photo_library_rounded,
                label: "Galeri",
                color: Colors.blue,
                onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery)),
              ),
            ],
          ),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildSourceButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 120,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const Gap(8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
