import 'package:file_picker/file_picker.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/home/model/post_model.dart';

class PostService {
  static final List<PostModel> _posts = _seedPosts();

  static List<PostModel> _seedPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        id: 'mock-1',
        userId: 'user-sup-01',
        userName: 'Roberta Lima',
        userRole: 'Supervisora · Operações',
        content:
            'Atenção a todos os colaboradores: o protocolo de segurança foi atualizado. '
            'Por favor, revisem o documento fixado no mural e confirmem o recebimento até sexta-feira.',
        likesCount: 14,
        commentsCount: 3,
        comments: [
          CommentModel(
            userName: 'Carlos Mendes',
            content: 'Recebido, obrigado!',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          CommentModel(
            userName: 'Ana Souza',
            content: 'Já lí e confirmei.',
            createdAt: now.subtract(const Duration(minutes: 40)),
          ),
        ],
        isLiked: false,
        isOwn: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      PostModel(
        id: 'mock-2',
        userId: 'user-emp-02',
        userName: 'Carlos Mendes',
        userRole: 'Técnico · Manutenção',
        content:
            'Concluí a revisão preventiva das máquinas do setor B. '
            'Tudo dentro do esperado. Relatório disponível no sistema.',
        likesCount: 6,
        commentsCount: 0,
        isLiked: true,
        isOwn: false,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      PostModel(
        id: 'mock-3',
        userId: 'user-emp-03',
        userName: 'Ana Souza',
        userRole: 'Analista · Qualidade',
        content:
            'Lembrete: amanhã às 9h temos a reunião de alinhamento de metas do trimestre. '
            'Sala 3, presença obrigatória para todos do setor.',
        likesCount: 9,
        commentsCount: 1,
        comments: [
          CommentModel(
            userName: 'Carlos Mendes',
            content: 'Confirmado!',
            createdAt: now.subtract(const Duration(hours: 5)),
          ),
        ],
        isLiked: false,
        isOwn: false,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      PostModel(
        id: 'mock-4',
        userId: 'user-sup-02',
        userName: 'Marcos Ferreira',
        userRole: 'Gestor · Logística',
        content:
            'Parabéns ao time de logística pelo recorde de entregas no mês! '
            'Resultado direto do esforço de cada um. Continuem assim!',
        likesCount: 31,
        commentsCount: 5,
        isLiked: false,
        isOwn: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<List<PostModel>> fetchPosts() async {
    return List.from(_posts);
  }

  Future<PostModel> createPost({
    required String content,
    required List<PlatformFile> attachments,
    required UserModel? user,
  }) async {
    final post = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.id ?? '0',
      userName: user?.name ?? 'Utilizador',
      userRole: user?.roleLabel ?? 'Colaborador',
      content: content,
      image: attachments.isNotEmpty ? attachments.first : null,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isOwn: true,
      createdAt: DateTime.now(),
    );

    _posts.insert(0, post);
    return post;
  }

  Future<void> toggleLike(String id) async {}
  Future<void> deletePost(String id) async {}
}
