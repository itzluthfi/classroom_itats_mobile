import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:classroom_itats_mobile/models/profile.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:classroom_itats_mobile/user/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<ProfileEvent>(
      (ProfileEvent event, Emitter<ProfileState> emit) async {
        if (event is UpdateStudentProfile) {
          emit(UpdateProfileLoading());
          try {
            var status = await profileRepository.updateStudentProfile(
                event.email, event.phoneNumber, event.filepath, event.filename);

            if (status != 200) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menyimpan profil anda");

              emit(UpdateProfileFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses menyimpan profil anda");

              emit(UpdateProfileSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body: "Mohon maaf, sistem gagal menyimpan profil anda");
            emit(UpdateProfileFailed());
          }
        } else if (event is GetStudentProfile) {
          emit(ProfileLoading());
          try {
            var profile =
                await profileRepository.getStudentProfile(event.academicPeriod);

            emit(ProfileLoaded(profile: profile));
          } catch (e) {
            emit(ProfileLoadFailed());
          }
        }
      },
      transformer: sequential(),
    );
  }
}
