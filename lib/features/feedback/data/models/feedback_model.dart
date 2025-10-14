import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.userId,
    required super.subject,
    required super.message,
    required super.category,
    required super.status,
    required super.priority,
    required super.attachments,
    super.adminResponse,
    super.respondedById,
    super.respondedByName,
    super.respondedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['_id'] as String,
      userId: json['user'] is String
          ? json['user']
          : (json['user'] as Map<String, dynamic>)['_id'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      attachments:
          (json['attachments'] as List?)
              ?.map((a) => FeedbackAttachmentModel.fromJson(a))
              .toList() ??
          [],
      adminResponse: json['adminResponse'] as String?,
      respondedById: json['respondedBy'] is String
          ? json['respondedBy']
          : (json['respondedBy'] as Map<String, dynamic>?)?['_id'] as String?,
      respondedByName: json['respondedBy'] is Map
          ? (json['respondedBy'] as Map<String, dynamic>)['name'] as String?
          : null,
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'subject': subject,
      'message': message,
      'category': category,
      'status': status,
      'priority': priority,
      'attachments': attachments
          .map((a) => (a as FeedbackAttachmentModel).toJson())
          .toList(),
      'adminResponse': adminResponse,
      'respondedBy': respondedById,
      'respondedAt': respondedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FeedbackEntity toEntity() {
    return FeedbackEntity(
      id: id,
      userId: userId,
      subject: subject,
      message: message,
      category: category,
      status: status,
      priority: priority,
      attachments: attachments,
      adminResponse: adminResponse,
      respondedById: respondedById,
      respondedByName: respondedByName,
      respondedAt: respondedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class FeedbackAttachmentModel extends FeedbackAttachment {
  const FeedbackAttachmentModel({required super.url, required super.type});

  factory FeedbackAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FeedbackAttachmentModel(
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type};
  }
}
