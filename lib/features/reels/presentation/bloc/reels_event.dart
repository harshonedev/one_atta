import 'package:equatable/equatable.dart';

abstract class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReelsFeed extends ReelsEvent {
  final bool refresh;

  const LoadReelsFeed({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreReels extends ReelsEvent {
  const LoadMoreReels();
}

class IncrementReelView extends ReelsEvent {
  final String reelId;

  const IncrementReelView(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

class ToggleReelLike extends ReelsEvent {
  final String reelId;

  const ToggleReelLike(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

class ShareReel extends ReelsEvent {
  final String reelId;
  final String shareType;

  const ShareReel(this.reelId, {this.shareType = 'link'});

  @override
  List<Object?> get props => [reelId, shareType];
}

class ReelLikedStatusRequested extends ReelsEvent {
  final String reelId;

  const ReelLikedStatusRequested(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

class ClearErrorMessage extends ReelsEvent {
  const ClearErrorMessage();

  @override
  List<Object?> get props => [];
}
