import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/house_state_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';

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

final houseStateProvider = StreamProvider<HouseState>((ref) {
  final wsService = ref.watch(websocketServiceProvider);
  return wsService.connect();
});
