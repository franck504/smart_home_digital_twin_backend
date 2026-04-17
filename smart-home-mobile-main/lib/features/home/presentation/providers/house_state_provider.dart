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
  
  try {
    // Ping HTTP avec timeout de 5 secondes pour vérifier l'IP
    final url = Uri.parse('http://$ip:8000/state');
    await http.get(url).timeout(const Duration(seconds: 5));
    
    // Si la requête HTTP réussit, on ouvre le WebSocket
    final wsService = ref.watch(websocketServiceProvider);
    yield* wsService.connect();
  } catch (e) {
    throw Exception('Connexion au serveur locale impossible ($e)');
  }
});
