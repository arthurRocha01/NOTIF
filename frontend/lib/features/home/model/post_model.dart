import 'package:file_picker/file_picker.dart';

class CommentModel {
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({required this.userName, required this.content, required this.createdAt});
}

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
  final List<CommentModel> comments; // 👈 Adicionado
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
    this.comments = const [], // 👈 Inicializado vazio
    required this.isLiked,
    required this.isOwn,
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    int? likesCount,
    bool? isLiked,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId,
      userName: userName,
      userRole: userRole,
      userAvatar: userAvatar,
      content: content,
      image: image,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isOwn: isOwn,
      createdAt: createdAt,
    );
  }
}