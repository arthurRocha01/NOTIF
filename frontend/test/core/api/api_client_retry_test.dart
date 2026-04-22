import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notif_app/core/api/api_client.dart';

http.Response _response(int statusCode, {String body = '{}'}) =>
    http.Response(body, statusCode);

void main() {
  tearDown(() {
    ApiClient.httpClient = null;
    ApiClient.retryDelays = null;
  });

  group('ApiClient retry em 500', () {
    test('sucesso na primeira tentativa não retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(200, body: '{"ok":true}');
      });
      ApiClient.retryDelays = [];

      final result = await ApiClient.get('/test');

      expect(calls, 1);
      expect(result, {'ok': true});
    });

    test('500 seguido de 200 retorna sucesso após retry', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return calls == 1 ? _response(500) : _response(200, body: '{"ok":true}');
      });
      ApiClient.retryDelays = [Duration.zero];

      final result = await ApiClient.get('/test');

      expect(calls, 2);
      expect(result, {'ok': true});
    });

    test('500 persistente esgota tentativas e lança ApiException', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(500, body: '{"message":"Internal Server Error"}');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      await expectLater(
        ApiClient.get('/test'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', 'Internal Server Error'),
        ),
      );

      expect(calls, 3);
    });

    test('retenta exatamente maxRetries vezes em 500 contínuo', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(503);
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero, Duration.zero];

      await expectLater(ApiClient.post('/test', {}), throwsA(isA<ApiException>()));
      expect(calls, 4);
    });

    test('401 não retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(401, body: '{"message":"Unauthorized"}');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      await expectLater(ApiClient.get('/test'), throwsA(isA<ApiException>()));
      expect(calls, 1);
    });

    test('404 não retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(404, body: '{"message":"Not Found"}');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      await expectLater(ApiClient.get('/test'), throwsA(isA<ApiException>()));
      expect(calls, 1);
    });

    test('400 não retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return _response(400, body: '{"message":"Bad Request"}');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      await expectLater(ApiClient.patch('/test', {}), throwsA(isA<ApiException>()));
      expect(calls, 1);
    });

    test('SocketException não retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        throw const SocketException('no network');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      await expectLater(
        ApiClient.get('/test'),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Sem conexão com a internet',
        )),
      );
      expect(calls, 1);
    });

    test('patch com 500 retenta e retorna sucesso', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return calls < 3 ? _response(500) : _response(200, body: '{"updated":true}');
      });
      ApiClient.retryDelays = [Duration.zero, Duration.zero];

      final result = await ApiClient.patch('/test', {'key': 'value'});

      expect(calls, 3);
      expect(result, {'updated': true});
    });

    test('delete com 500 retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return calls == 1 ? _response(500) : _response(200, body: 'null');
      });
      ApiClient.retryDelays = [Duration.zero];

      await ApiClient.delete('/test');
      expect(calls, 2);
    });

    test('502 é tratado como erro de servidor e retenta', () async {
      int calls = 0;
      ApiClient.httpClient = MockClient((_) async {
        calls++;
        return calls == 1 ? _response(502) : _response(200, body: '{}');
      });
      ApiClient.retryDelays = [Duration.zero];

      await ApiClient.get('/test');
      expect(calls, 2);
    });
  });
}
