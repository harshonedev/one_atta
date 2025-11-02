import 'package:equatable/equatable.dart';

/// Represents a short-form video reel with Cloudflare Stream integration.
///
/// ## Cloudflare Stream Integration
///
/// All videos are powered by **Cloudflare Stream** providing:
/// - ✅ **Adaptive Bitrate Streaming**: Automatic quality adjustment (360p-1080p)
/// - ✅ **Global CDN**: Fast delivery from 200+ locations worldwide
/// - ✅ **HLS & DASH**: Industry-standard streaming protocols
/// - ✅ **Auto-generated Thumbnails**: Multiple quality thumbnails
///
/// ### Video URL Fields:
/// - `playbackUrl`: HLS manifest URL (primary, use this for playback)
/// - `dashUrl`: DASH manifest URL (alternative format)
/// - `thumbnailUrl`: Auto-generated video thumbnail/poster
/// - `embedUrl`: Embeddable iframe player URL
/// - `width`/`height`: Video dimensions in pixels
///
/// ### Usage:
/// ```dart
/// // Use playbackUrl for HLS streaming
/// VideoPlayerController.networkUrl(Uri.parse(reel.playbackUrl))
///
/// // Use thumbnailUrl for poster/preview
/// Image.network(reel.thumbnailUrl)
/// ```
class ReelEntity extends Equatable {
  final String id;
  final String caption;
  // Cloudflare Stream video URLs
  final String playbackUrl; // HLS manifest URL (primary)
  final String? dashUrl; // DASH manifest URL (alternative)
  final String thumbnailUrl; // Auto-generated thumbnail/poster
  final String? embedUrl; // Embeddable iframe player URL
  final int? width; // Video width in pixels
  final int? height; // Video height in pixels
  // Legacy fields (for backward compatibility)
  final String? posterUrl;
  final String? videoUrl;
  final int duration;
  final String formattedDuration;
  final List<String> tags;
  final int views;
  final int likes;
  final int shares;
  final bool isLiked;
  final DateTime createdAt;
  final ReelCreatorEntity createdBy;
  final ReelBlendEntity? blend;
  final BlendSnapshotEntity? blendSnapshot;

  const ReelEntity({
    required this.id,
    required this.caption,
    required this.playbackUrl,
    this.dashUrl,
    required this.thumbnailUrl,
    this.embedUrl,
    this.width,
    this.height,
    this.posterUrl,
    this.videoUrl,
    required this.duration,
    required this.formattedDuration,
    required this.tags,
    required this.views,
    this.likes = 0,
    this.shares = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.createdBy,
    this.blend,
    this.blendSnapshot,
  });

  @override
  List<Object?> get props => [
    id,
    caption,
    playbackUrl,
    dashUrl,
    thumbnailUrl,
    embedUrl,
    width,
    height,
    posterUrl,
    videoUrl,
    duration,
    formattedDuration,
    tags,
    views,
    likes,
    shares,
    isLiked,
    createdAt,
    createdBy,
    blend,
    blendSnapshot,
  ];

  ReelEntity copyWith({
    String? id,
    String? caption,
    String? playbackUrl,
    String? dashUrl,
    String? thumbnailUrl,
    String? embedUrl,
    int? width,
    int? height,
    String? posterUrl,
    String? videoUrl,
    int? duration,
    String? formattedDuration,
    List<String>? tags,
    int? views,
    int? likes,
    int? shares,
    bool? isLiked,
    DateTime? createdAt,
    ReelCreatorEntity? createdBy,
    ReelBlendEntity? blend,
    BlendSnapshotEntity? blendSnapshot,
  }) {
    return ReelEntity(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      dashUrl: dashUrl ?? this.dashUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      embedUrl: embedUrl ?? this.embedUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      posterUrl: posterUrl ?? this.posterUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      blend: blend ?? this.blend,
      blendSnapshot: blendSnapshot ?? this.blendSnapshot,
    );
  }
}

class ReelCreatorEntity extends Equatable {
  final String name;

  const ReelCreatorEntity({required this.name});

  @override
  List<Object?> get props => [name];
}

class ReelBlendEntity extends Equatable {
  final String id;
  final String name;
  final String shareCode;
  final bool? isPublic;

  const ReelBlendEntity({
    required this.id,
    required this.name,
    required this.shareCode,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, name, shareCode, isPublic];
}

class BlendSnapshotEntity extends Equatable {
  final String name;
  final List<AdditiveEntity> additives;
  final double pricePerKg;
  final String shareCode;

  const BlendSnapshotEntity({
    required this.name,
    required this.additives,
    required this.pricePerKg,
    required this.shareCode,
  });

  @override
  List<Object?> get props => [name, additives, pricePerKg, shareCode];
}

class AdditiveEntity extends Equatable {
  final double percentage;
  final OriginalDetailsEntity originalDetails;

  const AdditiveEntity({
    required this.percentage,
    required this.originalDetails,
  });

  @override
  List<Object?> get props => [percentage, originalDetails];
}

class OriginalDetailsEntity extends Equatable {
  final String name;
  final String sku;
  final double pricePerKg;

  const OriginalDetailsEntity({
    required this.name,
    required this.sku,
    required this.pricePerKg,
  });

  @override
  List<Object?> get props => [name, sku, pricePerKg];
}

class ReelDetailEntity extends Equatable {
  final String id;
  final ReelCreatorEntity createdBy;
  final String status;
  // Cloudflare Stream video URLs
  final String playbackUrl; // HLS manifest URL (primary)
  final String? dashUrl; // DASH manifest URL (alternative)
  final String thumbnailUrl; // Auto-generated thumbnail/poster
  final String? embedUrl; // Embeddable iframe player URL
  final int? width; // Video width in pixels
  final int? height; // Video height in pixels
  // Legacy fields (for backward compatibility)
  final String? videoUrl;
  final String? posterUrl;
  final int duration;
  final String formattedDuration;
  final String caption;
  final List<String> tags;
  final String visibility;
  final int views;
  final ReelBlendEntity? blend;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BlendDetailsEntity? blendDetails;

  const ReelDetailEntity({
    required this.id,
    required this.createdBy,
    required this.status,
    required this.playbackUrl,
    this.dashUrl,
    required this.thumbnailUrl,
    this.embedUrl,
    this.width,
    this.height,
    this.videoUrl,
    this.posterUrl,
    required this.duration,
    required this.formattedDuration,
    required this.caption,
    required this.tags,
    required this.visibility,
    required this.views,
    this.blend,
    required this.createdAt,
    required this.updatedAt,
    this.blendDetails,
  });

  @override
  List<Object?> get props => [
    id,
    createdBy,
    status,
    playbackUrl,
    dashUrl,
    thumbnailUrl,
    embedUrl,
    width,
    height,
    videoUrl,
    posterUrl,
    duration,
    formattedDuration,
    caption,
    tags,
    visibility,
    views,
    blend,
    createdAt,
    updatedAt,
    blendDetails,
  ];
}

class BlendDetailsEntity extends Equatable {
  final String name;
  final List<IngredientEntity> ingredients;
  final double totalPricePerKg;
  final String shareCode;

  const BlendDetailsEntity({
    required this.name,
    required this.ingredients,
    required this.totalPricePerKg,
    required this.shareCode,
  });

  @override
  List<Object?> get props => [name, ingredients, totalPricePerKg, shareCode];
}

class IngredientEntity extends Equatable {
  final String name;
  final double percentage;
  final double pricePerKg;

  const IngredientEntity({
    required this.name,
    required this.percentage,
    required this.pricePerKg,
  });

  @override
  List<Object?> get props => [name, percentage, pricePerKg];
}

class ReelsFeedEntity extends Equatable {
  final List<ReelEntity> reels;
  final String? nextCursor;
  final bool hasMore;

  const ReelsFeedEntity({
    required this.reels,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [reels, nextCursor, hasMore];
}

class ReelSearchResultEntity extends Equatable {
  final List<ReelEntity> reels;
  final String searchQuery;
  final int count;

  const ReelSearchResultEntity({
    required this.reels,
    required this.searchQuery,
    required this.count,
  });

  @override
  List<Object?> get props => [reels, searchQuery, count];
}

class ReelLikeEntity {
  final bool isLiked;
  final int likesCount;
  final String reelId;

  const ReelLikeEntity({
    required this.isLiked,
    required this.likesCount,
    required this.reelId,
  });
}

class ReelShareEntity {
  final String shareUrl;
  final int sharesCount;
  final String shareType;
  final String reelId;
  final String sharedAt;

  const ReelShareEntity({
    required this.shareUrl,
    required this.sharesCount,
    required this.shareType,
    required this.reelId,
    required this.sharedAt,
  });
}
