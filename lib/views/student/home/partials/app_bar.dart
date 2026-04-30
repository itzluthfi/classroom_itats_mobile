import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/notification/notification_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/notification_repository.dart';
import 'package:classroom_itats_mobile/utils/semester_helper.dart';
import 'package:classroom_itats_mobile/views/notification/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const StudentAppBar({
    super.key,
    required this.academicPeriodRepository,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  State<StudentAppBar> createState() => _StudentAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20.0);
}

class _StudentAppBarState extends State<StudentAppBar> {
  bool shadowColor = false;
  double? scrolledUnderElevation;
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AcademicPeriodBloc>(context).add(GetAcademicPeriod());
    // Bloc notifikasi milik AppBar sendiri agar tidak bergantung parent
    _notificationBloc = NotificationBloc(repo: NotificationRepository())
      ..add(RefreshUnreadCount());
  }

  @override
  void dispose() {
    _notificationBloc.close();
    super.dispose();
  }

  _onButtonFilterPressed() async {
    final prefs = await SharedPreferences.getInstance();

    final academicPeriod = prefs.getString("current_academic_period");

    setState(() {
      BlocProvider.of<SubjectBloc>(context)
          .add(GetSubject(period: academicPeriod ?? "", context: context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kiri: Logo & Text
            Row(
              children: [
                if (widget.showBackButton)
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF14307E)),
                    onPressed: widget.onBackPressed ??
                        () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (widget.showBackButton) const SizedBox(width: 8),
                Image.asset(
                  "assets/application_images/Logo_Classroom_Square-no_bg.png",
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            // Kanan: Filter Icon & Profile Avatar
            Row(
              children: [
                // Filter Icon Custom
                InkWell(
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14307E)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.filter_list_rounded,
                                    color: Color(0xFF14307E),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Filter Semester',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF14307E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Content
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                String userNpm = "";
                                if (authState is AuthAuthenticated) {
                                  userNpm = authState.user.name;
                                }
                                return BlocConsumer<AcademicPeriodBloc,
                                    AcademicPeriodState>(
                                  listener: (context, state) {
                                    if (state is AcademicPeriodLoadFailed) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Gagal Menampilkan Periode Akademik'),
                                          duration: Duration(milliseconds: 1500),
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Pilih Periode Akademik",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            return DropdownMenu<String>(
                                              width: constraints.maxWidth,
                                              initialSelection:
                                                  state is AcademicPeriodLoaded
                                                      ? state.currentAcademicPeriod
                                                      : "",
                                              requestFocusOnTap: false,
                                              onSelected: (String? value) {
                                                widget.academicPeriodRepository
                                                    .setAcademicPeriod(value ?? "");
                                              },
                                              menuStyle: MenuStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white),
                                                elevation: MaterialStateProperty.all(8),
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              inputDecorationTheme:
                                                  InputDecorationTheme(
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey.shade300),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey.shade300),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF14307E), width: 1.5),
                                                ),
                                              ),
                                              dropdownMenuEntries: state
                                                      is AcademicPeriodLoaded
                                                  ? state.academicPeriod.map((value) {
                                                      final semNum = SemesterHelper
                                                          .calculateSemester(
                                                              userNpm,
                                                              value.yearStart,
                                                              value.oddEven);
                                                      final calYear = SemesterHelper
                                                          .calculateCalendarYear(
                                                              value.yearStart,
                                                              value.oddEven);
                                                      return DropdownMenuEntry(
                                                          value:
                                                              value.academicPeriodId,
                                                          label:
                                                              "Semester $semNum $calYear",
                                                          style: MenuItemButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                          ));
                                                    }).toList()
                                                  : [],
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      BlocProvider.of<AcademicPeriodBloc>(
                                              context)
                                          .add(GetAcademicPeriod());
                                      _onButtonFilterPressed();
                                      Navigator.pop(context, 'OK');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF14307E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Terapkan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/application_images/filter.png",
                      height: 24, // Reasonable size for filter icon
                      color: const Color(0xFF14307E), // Match logo color
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Bell notifikasi dengan badge ──
                BlocBuilder<NotificationBloc, NotificationState>(
                  bloc: _notificationBloc,
                  builder: (context, state) {
                    final unread =
                        state is NotificationLoaded ? state.unreadCount : 0;
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => NotificationBloc(
                                  repo: NotificationRepository())
                                ..add(LoadNotifications()),
                              child: const NotificationPage(),
                            ),
                          ),
                        );
                        if (mounted) {
                          _notificationBloc.add(RefreshUnreadCount());
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF14307E),
                              size: 26,
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(width: 4),

                // Profile Avatar (Clickable for logout/profile)
                GestureDetector(
                  onTap: () {
                    // Show simple bottom sheet or navigation
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      isScrollControlled: true,
                      builder: (context) {
                        return BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            String userName = "Mahasiswa";
                            String userNpm = "-";

                            if (authState is AuthAuthenticated) {
                              userNpm = authState.user.name;
                            }

                            return Container(
                              margin: EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                MediaQuery.of(context).padding.bottom + 80,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // User Info Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xFFF0B384),
                                          child: Icon(Icons.person,
                                              size: 35, color: Colors.white),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF14307E),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "NPM. $userNpm",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  // Menu Items
                                  _buildProfileMenuItem(
                                    context: context,
                                    icon: Icons.person_outline_rounded,
                                    title: 'Profil Saya',
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                          context, "/student/profile");
                                    },
                                  ),
                                  _buildProfileMenuItem(
                                    context: context,
                                    icon: Icons.logout_rounded,
                                    title: 'Keluar',
                                    isDestructive: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      BlocProvider.of<AuthBloc>(context)
                                          .add(LoggedOut());
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Color(0xFFF0B384), // Skin tone base color from image
                    child: Icon(Icons.person,
                        color: Colors.white), // Placeholder if no real image
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF14307E);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
