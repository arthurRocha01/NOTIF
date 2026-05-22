import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final Uint8List? avatarBytes;
  final String displayName;

  const ProfileState({this.avatarBytes, this.displayName = ''});

  ProfileState copyWith({
    Uint8List? avatarBytes,
    bool clearAvatar = false,
    String? displayName,
  }) {
    return ProfileState(
      avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
      displayName: displayName ?? this.displayName,
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
    state = state.copyWith(displayName: name);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
