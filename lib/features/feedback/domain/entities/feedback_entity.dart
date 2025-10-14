class FeedbackEntity {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String category;
  final String status;
  final String priority;
  final List<FeedbackAttachment> attachments;
  final String? adminResponse;
  final String? respondedById;
  final String? respondedByName;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedbackEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    required this.priority,
    required this.attachments,
    this.adminResponse,
    this.respondedById,
    this.respondedByName,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}

class FeedbackAttachment {
  final String url;
  final String type;

  const FeedbackAttachment({required this.url, required this.type});
}
