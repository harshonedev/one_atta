import 'package:one_atta/features/faq/domain/entities/faq_entity.dart';

class FaqModel extends FaqEntity {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.category,
    required super.order,
    required super.isActive,
    required super.viewCount,
    required super.helpfulCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      viewCount: json['viewCount'] as int? ?? 0,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isActive': isActive,
      'viewCount': viewCount,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FaqEntity toEntity() {
    return FaqEntity(
      id: id,
      question: question,
      answer: answer,
      category: category,
      order: order,
      isActive: isActive,
      viewCount: viewCount,
      helpfulCount: helpfulCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class FaqHelpfulMarkedResponseModel extends FaqHelpfulMarkedResponse {
  const FaqHelpfulMarkedResponseModel({
    required super.message,
    required super.faqId,
    required super.newHelpfulCount,
    required super.question,
  });

  factory FaqHelpfulMarkedResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FaqHelpfulMarkedResponseModel(
      message: json['message'] as String,
      faqId: data['_id'] as String,
      newHelpfulCount: data['helpfulCount'] as int,
      question: data['question'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      '_id': faqId,
      'helpfulCount': newHelpfulCount,
      'question': question,
    };
  }
}
