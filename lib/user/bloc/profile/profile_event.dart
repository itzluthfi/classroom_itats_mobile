part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetStudentProfile extends ProfileEvent {
  final String academicPeriod;

  const GetStudentProfile({
    required this.academicPeriod,
  });

  @override
  List<Object> get props => [academicPeriod];

  @override
  String toString() => "GetStudentProfile {academicPeriod: $academicPeriod}";
}

class UpdateStudentProfile extends ProfileEvent {
  final String email;
  final String phoneNumber;
  final String filepath;
  final String filename;

  const UpdateStudentProfile({
    required this.email,
    required this.phoneNumber,
    required this.filepath,
    required this.filename,
  });

  @override
  List<Object> get props => [email, phoneNumber, filepath, filename];

  @override
  String toString() =>
      "UpdateStudentProfile {email: $email, phoneNumber: $phoneNumber, filepath: $filepath, filename: $filename}";
}
