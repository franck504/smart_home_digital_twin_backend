import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/house_state_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';

import 'package:http/http.dart' as http;
import 'ip_provider.dart';

final apiServiceProvider = Provider((ref) {
  final ip = ref.watch(ipProvider);
  return ApiService(baseUrl: 'http://$ip:8000');
});

final websocketServiceProvider = Provider((ref) {
  final ip = ref.watch(ipProvider);
  final service = WebSocketService(wsUrl: 'ws://$ip:8000/ws');
  ref.onDispose(() => service.dispose());
  return service;
});

final houseStateProvider = StreamProvider<HouseState>((ref) async* {
  final ip = ref.watch(ipProvider);
  debugPrint('🔌 [houseStateProvider] Tentative de connexion avec IP = $ip');
  
  try {
    // Ping HTTP avec timeout de 5 secondes pour vérifier l'IP
    final url = Uri.parse('http://$ip:8000/state');
    debugPrint('🌐 [houseStateProvider] Ping HTTP vers : $url');
    
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    debugPrint('✅ [houseStateProvider] Réponse HTTP Reçue : ${response.statusCode}');
    
    if (response.statusCode != 200) {
      throw Exception('Réseau accessible mais erreur serveur : ${response.statusCode}');
    }
    
    // Si la requête HTTP réussit, on ouvre le WebSocket
    debugPrint('🚀 [houseStateProvider] HTTP OK, Initialisation du WebSocket...');
    final wsService = ref.watch(websocketServiceProvider);
    yield* wsService.connect();
  } catch (e) {
    debugPrint('❌ [houseStateProvider] Échec de connexion : $e');
    throw Exception('Connexion au serveur locale impossible ($e)');
  }
});

