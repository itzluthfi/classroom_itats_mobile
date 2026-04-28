class NotificationItem {
  final int id;
  final String recipientId;
  final String recipientRole;
  final String senderName;
  final String title;
  final String body;
  final String type; // 'assignment' | 'presence' | 'announcement' | 'general'
  final String referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationItem({
    required this.id,
    required this.recipientId,
    required this.recipientRole,
    required this.senderName,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      recipientId: json['recipient_id'] ?? '',
      recipientRole: json['recipient_role'] ?? '',
      senderName: json['sender_name'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      referenceId: json['reference_id'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
    );
  }

  NotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationItem(
      id: id,
      recipientId: recipientId,
      recipientRole: recipientRole,
      senderName: senderName,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
