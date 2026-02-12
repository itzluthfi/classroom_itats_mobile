import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/subject_member.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_member_repository.dart';
import 'package:equatable/equatable.dart';

part 'subject_member_event.dart';
part 'subject_member_state.dart';

class SubjectMemberBloc extends Bloc<SubjectMemberEvent, SubjectMemberState> {
  final SubjectMemberRepository subjectMemberRepository;

  SubjectMemberBloc({required this.subjectMemberRepository})
      : super(SubjectMemberInitial()) {
    on<GetSubjectMember>((event, emit) async {
      emit(SubjectMemberLoading());
      try {
        final subjectMembers = await subjectMemberRepository.getSubjectMember(
          event.academicPeriodId,
          event.subjectId,
          event.subjectClass,
          event.majorId,
        );

        emit(SubjectMemberLoaded(subjectMembers: subjectMembers));
      } catch (e) {
        emit(SubjectMemberLoadFailed());
      }
    });
  }
}
