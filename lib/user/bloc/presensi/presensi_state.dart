part of 'presensi_bloc.dart';

abstract class PresensiState extends Equatable {
  const PresensiState();

  @override
  List<Object> get props => [];
}

class PresensiInitial extends PresensiState {}

class PresensiLoading extends PresensiState {}

class PresensiLoaded extends PresensiState {
  final List<ActivePresence> allPresences;
  final List<ActivePresence> belumAbsen;
  final List<ActivePresence> sudahAbsen;
  final List<ActivePresence> habisWaktu;

  const PresensiLoaded({
    required this.allPresences,
    required this.belumAbsen,
    required this.sudahAbsen,
    required this.habisWaktu,
  });

  @override
  List<Object> get props => [allPresences, belumAbsen, sudahAbsen, habisWaktu];
}

class PresensiError extends PresensiState {
  final String message;

  const PresensiError(this.message);

  @override
  List<Object> get props => [message];
}
