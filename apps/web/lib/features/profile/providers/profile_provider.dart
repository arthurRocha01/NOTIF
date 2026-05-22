import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final Uint8List? avatarBytes;

  const ProfileState({this.avatarBytes});

  ProfileState copyWith({Uint8List? avatarBytes, bool clearAvatar = false}) {
    return ProfileState(
      avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
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
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
