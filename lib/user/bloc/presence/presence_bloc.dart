import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/presence.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:classroom_itats_mobile/user/repositories/presence_repository.dart';
import 'package:equatable/equatable.dart';

part 'presence_event.dart';
part 'presence_state.dart';

class PresenceBloc extends Bloc<PresenceEvent, PresenceState> {
  final PresenceRepository presenceRepository;
  PresenceBloc({required this.presenceRepository}) : super(PresenceInitial()) {
    on<GetPresenceQuestion>((event, emit) async {
      emit(PresenceLoading());
      try {
        var presenceQuestions =
            await presenceRepository.getPresenceQuestion(event.academicPeriod);
        emit(PresenceLoaded(
            presences: List<Presence>.empty(),
            presenceQuestions: presenceQuestions));
      } catch (e) {
        emit(PresenceLoadFailed());
      }
    });

    on<SetStudentPresence>((event, emit) async {
      emit(CreatePresenceLoading());
      try {
        int responseCode =
            await presenceRepository.setStudentPresence(event.studentPresence);
        if (responseCode != 201) {
          await NotificationService().showNotification(
              title: "Failed",
              body: "Mohon maaf, sistem gagal menyimpan absensi anda");
          emit(CreatePresenceFailed());
        } else {
          await NotificationService().showNotification(
              title: "Success", body: "Sukses menyimpan absensi anda");
          emit(CreatePresenceSuccess());
        }
      } catch (e) {
        await NotificationService().showNotification(
            title: "Failed",
            body: "Mohon maaf, sistem gagal menyimpan absensi anda");
        emit(CreatePresenceFailed());
      }
    });
  }
}
