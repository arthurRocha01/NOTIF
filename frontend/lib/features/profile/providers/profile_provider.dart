import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final Uint8List? avatarBytes;
  final String displayName;
  final int followersCount;
  final int followingCount;

  const ProfileState({
    this.avatarBytes,
    this.displayName = '',
    this.followersCount = 12,
    this.followingCount = 5,
  });

  ProfileState copyWith({
    Uint8List? avatarBytes,
    bool clearAvatar = false,
    String? displayName,
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileState(
      avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
      displayName: displayName ?? this.displayName,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  void setAvatar(Uint8List? bytes) {
    if (bytes == null) {
      state = state.copyWith(clearAvatar: true);
    } else {
      state = state.copyWith(avatarBytes: bytes);
    }
  }

  void setDisplayName(String name) {
    if (name.isEmpty) return;
    state = state.copyWith(displayName: name);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
