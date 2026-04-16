import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/house_state_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final websocketServiceProvider = Provider((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final houseStateProvider = StreamProvider<HouseState>((ref) {
  final wsService = ref.watch(websocketServiceProvider);
  return wsService.connect();
});
