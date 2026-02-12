part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];

  @override
  String toString() => "Student Profile Loaded";
}

final class ProfileLoadFailed extends ProfileState {}

final class UpdateProfileLoading extends ProfileState {}

final class UpdateProfileSuccess extends ProfileState {}

final class UpdateProfileFailed extends ProfileState {}
