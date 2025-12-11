import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef StringCallback = void Function(String message);
typedef DynamicCallback = void Function(dynamic error);

class WebSocketServer {
  final StringCallback? onMessage;
  final DynamicCallback? onError;
  final int port;

  HttpServer? _server;
  final List<WebSocket> _clients = [];

  WebSocketServer({this.onMessage, this.onError, this.port = 4040});

  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      print('WebSocket server started on port $port');
      _server!.transform(WebSocketTransformer()).listen(_handleConnection);
    } catch (e) {
      onError?.call(e);
    }
  }

  void _handleConnection(WebSocket socket) {
    print('🔗 New client connected');
    _clients.add(socket);

    socket.listen(
      (message) {
        print('📩 Received from client: $message');
        onMessage?.call(message);
        // Példa: válasz küldése vissza a kliensnek
        socket.add(jsonEncode({'echo': message}));
      },
      onError: (e) {
        onError?.call(e);
      },
      onDone: () {
        print('❌ Client disconnected');
        _clients.remove(socket);
      },
    );
  }

  void broadcast(String message) {
    for (var client in _clients) {
      client.add(message);
    }
  }

  Future<void> stop() async {
    for (var client in _clients) {
      await client.close();
    }
    _clients.clear();
    await _server?.close();
    _server = null;
    print('🛑 Server stopped');
  }
}

void main() async {
  final server = WebSocketServer(
    onMessage: (msg) => print('Server got: $msg'),
    onError: (err) => print('Error: $err'),
  );

  await server.start();
}
