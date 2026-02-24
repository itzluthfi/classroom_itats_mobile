import 'package:classroom_itats_mobile/models/active_presence.dart';
import 'package:classroom_itats_mobile/user/repositories/presensi_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'presensi_event.dart';
part 'presensi_state.dart';

class PresensiBloc extends Bloc<PresensiEvent, PresensiState> {
  final PresensiRepository presensiRepository;

  PresensiBloc({required this.presensiRepository}) : super(PresensiInitial()) {
    on<LoadActivePresences>((event, emit) async {
      emit(PresensiLoading());
      try {
        final presences =
            await presensiRepository.getActivePresences(event.academicPeriod);

        final belumAbsen = presences
            .where((p) => !p.sudahPresensi && !p.isHabisWaktu)
            .toList();
        final sudahAbsen = presences.where((p) => p.sudahPresensi).toList();
        final habisWaktu =
            presences.where((p) => !p.sudahPresensi && p.isHabisWaktu).toList();

        emit(PresensiLoaded(
          allPresences: presences,
          belumAbsen: belumAbsen,
          sudahAbsen: sudahAbsen,
          habisWaktu: habisWaktu,
        ));
      } catch (e) {
        emit(PresensiError(e.toString()));
      }
    });
  }
}
