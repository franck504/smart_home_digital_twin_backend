import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/house_state_model.dart';

/// Service gérant le flux bidirectionnel WebSocket pour la synchronisation temps réel.
class WebSocketService {
  final String wsUrl;
  WebSocketChannel? _channel;
  StreamController<HouseState>? _controller;

  WebSocketService({required this.wsUrl});

  /// Ouvre le canal WebSocket et retourne un flux typé de HouseState.
  Stream<HouseState> connect() {
    _controller?.close();
    _controller = StreamController<HouseState>.broadcast();

    try {
      debugPrint('🔌 [WebSocketService] Connexion vers: $wsUrl');
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (dynamic message) {
          try {
            final Map<String, dynamic> data =
                json.decode(message.toString()) as Map<String, dynamic>;
            final state = HouseState.fromJson(data);
            if (!_controller!.isClosed) {
              _controller!.add(state);
            }
          } catch (e, stackTrace) {
            debugPrint('⚠️ [WebSocketService] Erreur de parsing JSON: $e\n$stackTrace');
          }
        },
        onError: (dynamic error) {
          debugPrint('❌ [WebSocketService] Erreur stream: $error');
          if (!_controller!.isClosed) {
            _controller!.addError(error);
          }
        },
        onDone: () {
          debugPrint('ℹ️ [WebSocketService] Connexion WebSocket fermée');
          if (!_controller!.isClosed) {
            _controller!.close();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('❌ [WebSocketService] Exception lors de la connexion: $e');
      _controller!.addError(e);
    }

    return _controller!.stream;
  }

  /// Ferme les canaux et libère les ressources.
  void dispose() {
    try {
      _channel?.sink.close();
      _controller?.close();
    } catch (e) {
      debugPrint('Erreur lors de la fermeture WebSocket: $e');
    }
  }
}

