import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';

class ReelModel extends ReelEntity {
  const ReelModel({
    required super.id,
    required super.caption,
    required super.posterUrl,
    required super.videoUrl,
    required super.duration,
    required super.formattedDuration,
    required super.tags,
    required super.views,
    super.likes = 0,
    super.shares = 0,
    super.isLiked = false,
    required super.createdAt,
    required super.createdBy,
    super.blend,
    super.blendSnapshot,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['_id'] ?? '',
      caption: json['caption'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      duration: json['duration'] ?? 0,
      formattedDuration: json['formatted_duration'] ?? '0:00',
      tags: List<String>.from(json['tags'] ?? []),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: ReelCreatorModel.fromJson(json['createdBy'] ?? {}),
      blend: json['blend'] != null
          ? ReelBlendModel.fromJson(json['blend'])
          : null,
      blendSnapshot: json['blendSnapshot'] != null
          ? BlendSnapshotModel.fromJson(json['blendSnapshot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'poster_url': posterUrl,
      'video_url': videoUrl,
      'duration': duration,
      'formatted_duration': formattedDuration,
      'tags': tags,
      'views': views,
      'likes': likes,
      'shares': shares,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': (createdBy as ReelCreatorModel).toJson(),
      'blend': blend != null ? (blend! as ReelBlendModel).toJson() : null,
      'blendSnapshot': blendSnapshot != null
          ? (blendSnapshot! as BlendSnapshotModel).toJson()
          : null,
    };
  }
}

class ReelCreatorModel extends ReelCreatorEntity {
  const ReelCreatorModel({required super.name});

  factory ReelCreatorModel.fromJson(Map<String, dynamic> json) {
    return ReelCreatorModel(name: json['name'] ?? 'Unknown');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class ReelBlendModel extends ReelBlendEntity {
  const ReelBlendModel({
    required super.id,
    required super.name,
    required super.shareCode,
    super.isPublic,
  });

  factory ReelBlendModel.fromJson(Map<String, dynamic> json) {
    return ReelBlendModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      shareCode: json['share_code'] ?? '',
      isPublic: json['is_public'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'share_code': shareCode,
      'is_public': isPublic,
    };
  }
}

class BlendSnapshotModel extends BlendSnapshotEntity {
  const BlendSnapshotModel({
    required super.name,
    required super.additives,
    required super.pricePerKg,
    required super.shareCode,
  });

  factory BlendSnapshotModel.fromJson(Map<String, dynamic> json) {
    return BlendSnapshotModel(
      name: json['name'] ?? '',
      additives:
          (json['additives'] as List<dynamic>?)
              ?.map((item) => AdditiveModel.fromJson(item))
              .toList() ??
          [],
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      shareCode: json['share_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'additives': additives
          .map((additive) => (additive as AdditiveModel).toJson())
          .toList(),
      'price_per_kg': pricePerKg,
      'share_code': shareCode,
    };
  }
}

class AdditiveModel extends AdditiveEntity {
  const AdditiveModel({
    required super.percentage,
    required super.originalDetails,
  });

  factory AdditiveModel.fromJson(Map<String, dynamic> json) {
    return AdditiveModel(
      percentage: (json['percentage'] ?? 0).toDouble(),
      originalDetails: OriginalDetailsModel.fromJson(
        json['original_details'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'original_details': (originalDetails as OriginalDetailsModel).toJson(),
    };
  }
}

class OriginalDetailsModel extends OriginalDetailsEntity {
  const OriginalDetailsModel({
    required super.name,
    required super.sku,
    required super.pricePerKg,
  });

  factory OriginalDetailsModel.fromJson(Map<String, dynamic> json) {
    return OriginalDetailsModel(
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'sku': sku, 'price_per_kg': pricePerKg};
  }
}

class ReelDetailModel extends ReelDetailEntity {
  const ReelDetailModel({
    required super.id,
    required super.createdBy,
    required super.status,
    required super.videoUrl,
    required super.posterUrl,
    required super.duration,
    required super.formattedDuration,
    required super.caption,
    required super.tags,
    required super.visibility,
    required super.views,
    super.blend,
    required super.createdAt,
    required super.updatedAt,
    super.blendDetails,
  });

  factory ReelDetailModel.fromJson(Map<String, dynamic> json) {
    return ReelDetailModel(
      id: json['id'] ?? '',
      createdBy: ReelCreatorModel.fromJson(json['createdBy'] ?? {}),
      status: json['status'] ?? '',
      videoUrl: json['video_url'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      duration: json['duration'] ?? 0,
      formattedDuration: json['formatted_duration'] ?? '0:00',
      caption: json['caption'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      visibility: json['visibility'] ?? 'public',
      views: json['views'] ?? 0,
      blend: json['blend'] != null
          ? ReelBlendModel.fromJson(json['blend'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      blendDetails: json['blendDetails'] != null
          ? BlendDetailsModel.fromJson(json['blendDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': (createdBy as ReelCreatorModel).toJson(),
      'status': status,
      'video_url': videoUrl,
      'poster_url': posterUrl,
      'duration': duration,
      'formatted_duration': formattedDuration,
      'caption': caption,
      'tags': tags,
      'visibility': visibility,
      'views': views,
      'blend': blend != null ? (blend! as ReelBlendModel).toJson() : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'blendDetails': blendDetails != null
          ? (blendDetails! as BlendDetailsModel).toJson()
          : null,
    };
  }
}

class BlendDetailsModel extends BlendDetailsEntity {
  const BlendDetailsModel({
    required super.name,
    required super.ingredients,
    required super.totalPricePerKg,
    required super.shareCode,
  });

  factory BlendDetailsModel.fromJson(Map<String, dynamic> json) {
    return BlendDetailsModel(
      name: json['name'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((item) => IngredientModel.fromJson(item))
              .toList() ??
          [],
      totalPricePerKg: (json['totalPricePerKg'] ?? 0).toDouble(),
      shareCode: json['shareCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': ingredients
          .map((ingredient) => (ingredient as IngredientModel).toJson())
          .toList(),
      'totalPricePerKg': totalPricePerKg,
      'shareCode': shareCode,
    };
  }
}

class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.name,
    required super.percentage,
    required super.pricePerKg,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'percentage': percentage, 'pricePerKg': pricePerKg};
  }
}

class ReelsFeedModel extends ReelsFeedEntity {
  const ReelsFeedModel({
    required super.reels,
    super.nextCursor,
    required super.hasMore,
  });

  factory ReelsFeedModel.fromJson(Map<String, dynamic> json) {
    return ReelsFeedModel(
      reels:
          (json['reels'] as List<dynamic>?)
              ?.map((item) => ReelModel.fromJson(item))
              .toList() ??
          [],
      nextCursor: json['nextCursor'],
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reels': reels.map((reel) => (reel as ReelModel).toJson()).toList(),
      'nextCursor': nextCursor,
      'hasMore': hasMore,
    };
  }
}

class ReelSearchResultModel extends ReelSearchResultEntity {
  const ReelSearchResultModel({
    required super.reels,
    required super.searchQuery,
    required super.count,
  });

  factory ReelSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ReelSearchResultModel(
      reels:
          (json['reels'] as List<dynamic>?)
              ?.map((item) => ReelModel.fromJson(item))
              .toList() ??
          [],
      searchQuery: json['searchQuery'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reels': reels.map((reel) => (reel as ReelModel).toJson()).toList(),
      'searchQuery': searchQuery,
      'count': count,
    };
  }
}

class ReelLikeResponse {
  final bool isLiked;
  final int likesCount;
  final String reelId;

  const ReelLikeResponse({
    required this.isLiked,
    required this.likesCount,
    required this.reelId,
  });

  factory ReelLikeResponse.fromJson(Map<String, dynamic> json) {
    return ReelLikeResponse(
      isLiked: json['isLiked'] as bool,
      likesCount: json['likesCount'] as int,
      reelId: json['reelId'] as String,
    );
  }
}

class ReelShareResponse {
  final String shareUrl;
  final int sharesCount;
  final String shareType;
  final String reelId;
  final String sharedAt;

  const ReelShareResponse({
    required this.shareUrl,
    required this.sharesCount,
    required this.shareType,
    required this.reelId,
    required this.sharedAt,
  });

  factory ReelShareResponse.fromJson(Map<String, dynamic> json) {
    return ReelShareResponse(
      shareUrl: json['shareUrl'] as String,
      sharesCount: json['sharesCount'] as int,
      shareType: json['shareType'] as String,
      reelId: json['reelId'] as String,
      sharedAt: json['sharedAt'] as String,
    );
  }
}
