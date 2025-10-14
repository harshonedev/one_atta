import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isActive;
  final int viewCount;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    required this.isActive,
    required this.viewCount,
    required this.helpfulCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // copy
  FaqEntity copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isActive,
    int? viewCount,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    question,
    answer,
    category,
    order,
    isActive,
    viewCount,
    helpfulCount,
    createdAt,
    updatedAt,
  ];
}

class FaqHelpfulMarkedResponse extends Equatable {
  final String message;
  final String faqId;
  final int newHelpfulCount;
  final String question;

  const FaqHelpfulMarkedResponse({
    required this.message,
    required this.faqId,
    required this.newHelpfulCount,
    required this.question,
  });

  @override
  List<Object> get props => [message, faqId, newHelpfulCount, question];
}
