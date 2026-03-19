import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';

// 1. Criamos o Repository
final profileRepositoryProvider = Provider((ref) => ProfileRepository());

// 2. Criamos o Notifier que gerencia a lógica
class ProfileNotifier extends StateNotifier<String> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super('') {
    _init(); // Carrega a foto assim que o provider é criado
  }

  Future<void> _init() async {
    final savedPath = await _repository.getPhotoPath();
    if (savedPath != null) state = savedPath;
  }

  Future<void> updateProfilePhoto(String newPath) async {
    state = newPath; // Atualiza a UI na hora (optimistic update)
    await _repository.savePhotoPath(newPath); // Persiste no banco
  }
}

// 3. Expomos o Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, String>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo);
});