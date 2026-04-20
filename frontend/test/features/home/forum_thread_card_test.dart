import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/home/model/post_model.dart';
import 'package:notif_app/features/home/widgets/post_card.dart';

PostModel _makePost({
  String title = 'Título do tópico',
  String content = 'Conteúdo de exemplo para o tópico do fórum.',
  int likesCount = 5,
  int commentsCount = 3,
  bool isLiked = false,
  bool isOwn = false,
}) =>
    PostModel(
      id: 'test-1',
      userId: 'user-1',
      userName: 'João Silva',
      userRole: 'Técnico · Manutenção',
      title: title,
      content: content,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked,
      isOwn: isOwn,
      createdAt: DateTime(2026, 4, 20, 10, 0),
    );

Widget _buildCard(PostModel post) => MaterialApp(
      home: Scaffold(
        body: PostCard(
          post: post,
          onLike: () {},
          onDelete: () {},
        ),
      ),
    );

void main() {
  group('ForumThreadCard', () {
    testWidgets('exibe o título do tópico', (tester) async {
      await tester.pumpWidget(_buildCard(_makePost(title: 'Reunião de alinhamento')));
      expect(find.text('Reunião de alinhamento'), findsOneWidget);
    });

    testWidgets('exibe o excerpt do conteúdo', (tester) async {
      await tester.pumpWidget(_buildCard(_makePost(content: 'Texto de exemplo do tópico')));
      expect(find.text('Texto de exemplo do tópico'), findsOneWidget);
    });

    testWidgets('exibe o nome do autor', (tester) async {
      await tester.pumpWidget(_buildCard(_makePost()));
      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('exibe a contagem de comentários', (tester) async {
      await tester.pumpWidget(_buildCard(_makePost(commentsCount: 7)));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('exibe a contagem de curtidas', (tester) async {
      await tester.pumpWidget(_buildCard(_makePost(likesCount: 12)));
      expect(find.text('12'), findsOneWidget);
    });
  });
}
