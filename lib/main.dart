import 'dart:developer';
import 'dart:io';

import 'package:classroom_itats_mobile/auth/bloc/auth/auth.dart';
import 'package:classroom_itats_mobile/auth/bloc/login/login.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/firebase_options.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/forum/forum_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/list_subject/list_subject_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/major/major_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/percentage_score/percentage_score_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/presence/presence_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/profile/profile_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/student_score/student_score_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_achievement/study_achievement_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject_member/subject_member_bloc.dart';
import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/forum_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/presence_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/profile_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/study_achievement_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/study_material_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_member_repository.dart';
import 'package:classroom_itats_mobile/views/create_forum_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/assignments/assignment_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/assignments/create_assignment_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/college_report_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/create_college_report_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/detail_college_report_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/edit_college_report_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/assigment_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/percentage_score_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/score_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/detail_subject/subject_page.dart';
import 'package:classroom_itats_mobile/views/lecturer/subjects/subject_score_page.dart';
import 'package:classroom_itats_mobile/views/login_page.dart';
import 'package:classroom_itats_mobile/classroom_itats_mobile_observer.dart';
import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/subject/subject_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:classroom_itats_mobile/views/lecturer/home/home_page.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/assigment_page.dart';
import 'package:classroom_itats_mobile/views/student/home/home_page.dart';
import 'package:classroom_itats_mobile/views/student/profile/profile_page.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/subject_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  await _initFirebase();

  HttpOverrides.global = MyHttpOverrides();

  Bloc.observer = const ClassroomItatsMobileObserver();

  final UserRepository userRepository = UserRepository();
  final SubjectRepository subjectRepository = SubjectRepository();
  final AcademicPeriodRepository academicPeriodRepository =
      AcademicPeriodRepository();
  final MajorRepository majorRepository = MajorRepository();
  final ForumRepository forumRepository = ForumRepository();
  final LectureRepository lectureRepository = LectureRepository();
  final PresenceRepository presenceRepository = PresenceRepository();
  final StudyAchievementRepository studyAchievementRepository =
      StudyAchievementRepository();
  final StudyMaterialRepository studyMaterialRepository =
      StudyMaterialRepository();
  final AssignmentRepository assignmentRepository = AssignmentRepository();
  final SubjectMemberRepository subjectMemberRepository =
      SubjectMemberRepository();
  final ProfileRepository profileRepository = ProfileRepository();

  final prefs = await SharedPreferences.getInstance();

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();

  await initializeDateFormatting("id_ID", null);

  if (prefs.getStringList("application_images") == null) {
    _storeImage(prefs);
  }

  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) {
            return AuthBloc(userRepository: userRepository)..add(AppStarted());
          }),
          BlocProvider<LoginBloc>(create: (context) {
            return LoginBloc(
                userRepository: userRepository,
                authBloc: AuthBloc(userRepository: userRepository));
          }),
          BlocProvider<SubjectBloc>(
            create: (context) {
              return SubjectBloc(
                  subjectRepository: subjectRepository,
                  academicPeriodRepository: academicPeriodRepository);
            },
          ),
          BlocProvider<AcademicPeriodBloc>(
            create: (context) {
              return AcademicPeriodBloc(
                  academicPeriodRepository: academicPeriodRepository);
            },
          ),
          BlocProvider<MajorBloc>(
            create: (context) {
              return MajorBloc(
                  majorRepository: majorRepository,
                  academicPeriodRepository: academicPeriodRepository);
            },
          ),
          BlocProvider<PageIndexCubit>(
            create: (context) {
              return PageIndexCubit();
            },
          ),
          BlocProvider<ForumBloc>(
            create: (context) {
              return ForumBloc(forumRepository: forumRepository);
            },
          ),
          BlocProvider<LectureBloc>(
            create: (context) {
              return LectureBloc(
                lectureRepository: lectureRepository,
                presenceRepository: presenceRepository,
              );
            },
          ),
          BlocProvider<PresenceBloc>(
            create: (context) {
              return PresenceBloc(presenceRepository: presenceRepository);
            },
          ),
          BlocProvider<StudyAchievementBloc>(
            create: (context) {
              return StudyAchievementBloc(
                studyAchievementRepository: studyAchievementRepository,
                assignmentRepository: assignmentRepository,
                lectureRepository: lectureRepository,
              );
            },
          ),
          BlocProvider<StudyMaterialBloc>(
            create: (context) {
              return StudyMaterialBloc(
                studyMaterialRepository: studyMaterialRepository,
                assignmentRepository: assignmentRepository,
              );
            },
          ),
          BlocProvider<AssignmentBloc>(
            create: (context) => AssignmentBloc(
                assignmentRepository: assignmentRepository,
                subjectRepository: subjectRepository),
          ),
          BlocProvider<SubjectMemberBloc>(
            create: (context) => SubjectMemberBloc(
                subjectMemberRepository: subjectMemberRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(profileRepository: profileRepository),
          ),
          BlocProvider<StudentScoreBloc>(
            create: (context) =>
                StudentScoreBloc(subjectRepository: subjectRepository),
          ),
          BlocProvider<PercentageScoreBloc>(
            create: (context) =>
                PercentageScoreBloc(subjectRepository: subjectRepository),
          ),
          BlocProvider<ListSubjectBloc>(
            create: (context) =>
                ListSubjectBloc(subjectRepository: subjectRepository),
          ),
        ],
        child: MyApp(
          userRepository: userRepository,
          subjectRepository: subjectRepository,
          academicPeriodRepository: academicPeriodRepository,
          majorRepository: majorRepository,
        )),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final SubjectRepository subjectRepository;
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.subjectRepository,
    required this.academicPeriodRepository,
    required this.majorRepository,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) => {
          if (state is AuthAuthenticated)
            {
              if (state.authenticatedAs == AuthenticatedAs.student)
                {Navigator.of(context).pushNamed("/student/home")}
              else if (state.authenticatedAs == AuthenticatedAs.lecturer)
                {Navigator.of(context).pushNamed("/lecturer/home")}
            }
          else if (state is AuthUnauthenticated)
            {Navigator.of(context).pushNamed("/login")}
          else if (state is AuthLoading)
            {
              const Scaffold(
                body: Placeholder(
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            }
        },
        builder: (context, state) {
          return const Scaffold(
            body: Placeholder(
              color: Colors.transparent,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
      title: 'Classroom ITATS mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0072BB)),
        useMaterial3: true,
      ),
      routes: {
        "/login": (context) => LoginPage(userRepository: userRepository),
        "/student/home": (context) =>
            StudentHomePage(academicPeriodRepository: academicPeriodRepository),
        "/student/subject": (context) => StudentSubjectPage(
              subjectRepository: subjectRepository,
              userRepository: userRepository,
            ),
        "/student/assignments": (context) => const StudentAssignmentPage(),
        "/student/profile": (context) =>
            ProfilePage(academicPeriodRepository: academicPeriodRepository),
        "/forum/create": (context) => const CreateForumPage(),
        "/lecturer/subject": (context) => LecturerSubjectPage(
              userRepository: userRepository,
            ),
        "/lecturer/home": (context) => LecturerHomePage(
            academicPeriodRepository: academicPeriodRepository,
            majorRepository: majorRepository),
        "/lecturer/subject_score": (context) => LecturerSubjectScorePage(
              academicPeriodRepository: academicPeriodRepository,
              majorRepository: majorRepository,
            ),
        "/lecturer/score": (context) => LecturerStudentScorePage(
            academicPeriodRepository: academicPeriodRepository,
            majorRepository: majorRepository),
        "/lecturer/percentage": (context) => const LecturerPercentagePage(),
        "/lecturer/assignment": (context) => LecturerAssignmentPage(
              academicPeriodRepository: academicPeriodRepository,
              majorRepository: majorRepository,
            ),
        "/lecturer/assignment/create": (context) =>
            const LecturerCreateAssignmentPage(),
        "/lecturer/college_report": (context) => LecturerCollegeReportPage(
              academicPeriodRepository: academicPeriodRepository,
              majorRepository: majorRepository,
            ),
        "/lecturer/college_report/create": (context) =>
            const LecturerCreateCollegeReportPage(),
        "/lecturer/college_report/detail": (context) =>
            const LecturerDetailCollegeReportPage(),
        "/lecturer/college_report/edit": (context) =>
            const LecturerEditCollegeReportPage(),
        "/lecturer/subject/assignments": (context) =>
            const LecturerSubjectAssignmentPage(),
      },
    );
  }
}

void _storeImage(SharedPreferences prefs) async {
  prefs.setStringList(
      "application_images", ["B2", "H2", "K2", "T2", "U2", "Y2"]);
}

Future<void> _initFirebase() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // try {
  //   var notif = FlutterNotificationChannel();
  //   var _ = await notif.registerNotificationChannel(
  //     description: 'Classroom Itats Notification',
  //     id: 'classroom_itats_notification',
  //     importance: NotificationImportance.IMPORTANCE_HIGH,
  //     name: 'Classroom Itats Notification',
  //   );
  // } catch (e, stackTrace) {
  //   log(e.toString());
  //   log(stackTrace.toString());
  // }
  // Inisialisasi Firebase
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: dotenv.get("VAPID_KEY"),
          appId: dotenv.get("ANDROID_APP_ID"),
          messagingSenderId: dotenv.get("SENDER_ID"),
          projectId: "classroomitats"));

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Minta izin notifikasi
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // Setup notifikasi lokal
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/classroom_logo');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Buat channel notifikasi
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'classroom_itats_notification', // ID channel
    'Classroom Itats Notification', // Nama channel
    description: 'Classroom Itats Notification', // Deskripsi channel
    importance: Importance.high,
  );

  // Daftarkan channel di notifikasi lokal
  final AndroidFlutterLocalNotificationsPlugin?
      androidPlatformChannelSpecifics =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlatformChannelSpecifics?.createNotificationChannel(channel);

  // Setup notifikasi saat aplikasi berada di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'classroom_itats_notification', // Harus sama dengan channel ID
            'Classroom Itats Notification',
            channelDescription: 'Classroom Itats Notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // Background notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

Future<void> _requestPermision() async {
  final permissionStatus = await Permission.storage.status;
  if (permissionStatus.isDenied) {
    // Here just ask for the permission for the first time
    await Permission.storage.request();

    // I noticed that sometimes popup won't show after user press deny
    // so I do the check once again but now go straight to appSettings
    if (permissionStatus.isDenied) {
      await openAppSettings();
    }
  } else if (permissionStatus.isPermanentlyDenied) {
    // Here open app settings for user to manually enable permission in case
    // where permission was permanently denied
    await openAppSettings();
  } else {
    // Do stuff that require permission here
  }
}
