import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../data/models/house_state_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';
import 'ip_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final ip = ref.watch(ipProvider);
  return ApiService(baseUrl: ApiConstants.baseUrl(ip));
});

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final ip = ref.watch(ipProvider);
  final service = WebSocketService(wsUrl: ApiConstants.wsUrl(ip));
  ref.onDispose(() => service.dispose());
  return service;
});

final houseStateProvider = StreamProvider<HouseState>((ref) async* {
  final ip = ref.watch(ipProvider);
  final baseUrl = ApiConstants.baseUrl(ip);
  debugPrint('🔌 [houseStateProvider] Tentative de connexion avec IP = $ip ($baseUrl)');

  try {
    // Ping HTTP préalable pour vérifier l'accessibilité du serveur avant WebSocket
    final url = Uri.parse('$baseUrl/state');
    debugPrint('🌐 [houseStateProvider] Ping HTTP vers: $url');

    final response = await http.get(url).timeout(const Duration(seconds: 5));
    debugPrint('✅ [houseStateProvider] Réponse HTTP Reçue: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Serveur accessible mais statut anormal: ${response.statusCode}');
    }

    // Initialisation et écoute du flux WebSocket temps réel
    debugPrint('🚀 [houseStateProvider] Initialisation du flux WebSocket...');
    final wsService = ref.watch(websocketServiceProvider);
    yield* wsService.connect();
  } catch (e) {
    debugPrint('❌ [houseStateProvider] Échec de connexion: $e');
    throw Exception('Connexion au serveur locale impossible ($e)');
  }
});
