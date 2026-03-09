import 'package:file_picker/file_picker.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final PlatformFile? userAvatar;
  final String content;
  final PlatformFile? image;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isOwn;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.userAvatar,
    required this.content,
    this.image,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isOwn,
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    PlatformFile? userAvatar,
    String? content,
    PlatformFile? image,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isOwn,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      image: image ?? this.image,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isOwn: isOwn ?? this.isOwn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}