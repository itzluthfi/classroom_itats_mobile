import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/notification_item.dart';
import 'package:classroom_itats_mobile/user/repositories/notification_repository.dart';
import 'package:equatable/equatable.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final int id;
  const MarkNotificationRead(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsRead extends NotificationEvent {}

class RefreshUnreadCount extends NotificationEvent {}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  final int unreadCount;
  const NotificationLoaded({required this.notifications, required this.unreadCount});
  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repo;

  NotificationBloc({required NotificationRepository repo})
      : _repo = repo,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkOne);
    on<MarkAllNotificationsRead>(_onMarkAll);
    on<RefreshUnreadCount>(_onRefreshCount);
  }

  Future<void> _onLoad(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifs = await _repo.getNotifications();
      final count = notifs.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications: notifs, unreadCount: count));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkOne(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;
    try {
      await _repo.markOneRead(event.id);
      final updated = current.notifications
          .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationLoaded(
        notifications: updated,
        unreadCount: updated.where((n) => !n.isRead).length,
      ));
    } catch (_) {}
  }

  Future<void> _onMarkAll(MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;
    try {
      await _repo.markAllRead();
      final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationLoaded(notifications: updated, unreadCount: 0));
    } catch (_) {}
  }

  Future<void> _onRefreshCount(RefreshUnreadCount event, Emitter<NotificationState> emit) async {
    try {
      final count = await _repo.getUnreadCount();
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        emit(NotificationLoaded(notifications: current.notifications, unreadCount: count));
      } else {
        emit(NotificationLoaded(notifications: const [], unreadCount: count));
      }
    } catch (e) {
      // Jika gagal fetch count, pertahankan state lama agar badge tidak hilang mendadak
      // ignore: avoid_print
      print('[NotificationBloc] Gagal refresh unread count: $e');
    }
  }
}
